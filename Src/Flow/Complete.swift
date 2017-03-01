//
//  Complete.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/24/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
final
class OperationFlow
{
    let core: FlowCore
    
    //===
    
    public
    enum State: String
    {
        case
            ready,
            processing,
            failed,
            completed,
            cancelled
    }
    
    //===
    
    public internal(set)
    var state: State
    
    public internal(set)
    var failedAttempts: UInt = 0
    
    //===
    
    var targetOperationIndex: UInt = 0
    
    //===
    
    var isCancelled: Bool { return state == .cancelled }
    
    //===
    
    init(_ core: FlowCore)
    {
        self.core = core
        self.state = .ready
        
        //===
        
        OFL.ensureOnMain { try! self.start() }
    }
}

//===

public
extension OperationFlow
{
    static
    func new(
        _ name: String = NSUUID().uuidString,
        on targetQueue: OperationQueue = FlowDefaults.targetQueue,
        maxRetries: UInt = FlowDefaults.maxRetries
        ) -> PendingOperationFlow
    {
        return PendingOperationFlow(name,
                                    on: targetQueue,
                                    maxRetries: maxRetries)
    }
}

//=== Alternative ways to start new Flow with default params

public
extension OperationFlow
{
    static
    func take<Input>(
        _ input: Input
        ) -> FirstConnector<Input>
    {
        return new().take(input)
    }
    
    static
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) -> Connector<Output>
    {
        return new().first(op)
    }
    
    static
    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        ) -> Connector<Output>
    {
        return new().first(op)
    }
}

//===

public
extension OperationFlow
{
    public
    typealias ActiveProxy =
    (
        name: String,
        targetQueue: OperationQueue,
        maxRetries: UInt,
        totalOperationsCount: UInt,
        
        failedAttempts: UInt,
        targetOperationIndex: UInt,
        
        cancel: () throws -> Void
    )
    
    var proxy: ActiveProxy {
        
        return (
            
            core.name,
            core.targetQueue,
            core.maxRetries,
            UInt(core.operations.count),
            
            failedAttempts,
            targetOperationIndex,
            
            cancel
        )
    }
}

//===

extension OperationFlow
{
    func cancel() throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .cancelled
    }
    
    func executeAgain(after delay: TimeInterval = 0) throws
    {
        try OFL.checkFlowState(self, OperationFlow.validStatesBeforeReset)
        
        //===
        
        // use 'ensure...' here only because of the delay
        
        OFL.ensureOnMain(after: delay) {
            
            try! self.reset()
        }
    }
}

//===

extension OperationFlow
{
    func start() throws
    {
        try OFL.checkFlowState(self, [.ready])
        
        //===
        
        self.state = .processing
        
        //===
        
        try self.executeNext()
    }
    
    func shouldProceed() throws -> Bool
    {
        try OFL.checkCurrentQueueIsMain()
        
        //===
        
        return (Int(targetOperationIndex) < self.core.operations.count)
    }
    
    func executeNext(_ previousResult: Any? = nil) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        if
            try shouldProceed()
        {
            // regular block
            
            let task = core.operations[Int(targetOperationIndex)]
            
            //===
            
            core.targetQueue
                .addOperation {
                    
                    do
                    {
                        let result = try task(self.proxy, previousResult)
                        
                        //===
                        
                        // everything seems to be good,
                        // lets continue execution
                        
                        self.proceed(result)
                    }
                    catch
                    {
                        // the task thrown an error
                        
                        OFL.asyncOnMain { try! self.processFailure(error) }
                    }
                }
        }
        else
        {
            try! executeCompletion(previousResult)
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        // NOTE: use 'async...' here,
        // as we call this function from background queue
        
        OFL.asyncOnMain {
            
            if
                self.state == .cancelled
            {
                // process cancellation somehow???
            }
            else
            if self.state == .processing
            {
                self.targetOperationIndex += 1
                
                //===
                
                try! self.executeNext(previousResult)
            }
        }
    }
    
    func executeCompletion(_ finalResult: Any?) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .completed
        
        //===
        
        if
            let completion = self.core.completion
        {
            do
            {
                try completion(self.infoProxy, finalResult)
            }
            catch
            {
                // the task thrown an error
                
                try! self.processFailure(error)
            }
        }
    }
    
    func processFailure(_ error: Error) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .failed
        
        //===
        
        failedAttempts += 1
        
        //===
        
        var shouldRetry = (failedAttempts - 1) < core.maxRetries
        
        for handler in core.failureHandlers
        {
            handler(self.infoProxy, error, &shouldRetry)
        }
        
        //===
        
        if
            shouldRetry
        {
            try! executeAgain(after: 0.25 * Double(failedAttempts))
        }
    }
    
    static
    var validStatesBeforeReset: [State] = [.failed, .completed, .cancelled]
    
    func reset() throws
    {
        try OFL.checkFlowState(self, OperationFlow.validStatesBeforeReset)
        
        //===
        
        targetOperationIndex = 0
        state = .ready
        
        try start()
    }
}
