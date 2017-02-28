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
    
    var targetTaskIndex = 0
    
    //===
    
    var isCancelled: Bool { return state == .cancelled }
    
    //===
    
    init(_ core: FlowCore)
    {
        self.core = core
        self.state = .ready
        
        //===
        
        try! start()
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
        ) throws -> PendingOperationFlow
    {
        try OFL.checkMainQueue()
        
        //===
        
        return
            PendingOperationFlow(name,
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
        ) throws -> FirstConnector<Input>
    {
        return try new().take(input)
    }
    
    static
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        )throws -> Connector<Output>
    {
        return try new().first(op)
    }
    
    static
    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        )throws -> Connector<Output>
    {
        return try new().first(op)
    }
}

//===

public
extension OperationFlow
{
    func start() throws
    {
        try OFL.checkMainQueue()
        
        //===
        
        try OFL.checkFlowState(self, [.ready])
        
        //===
        
        state = .processing
        
        //===
        
        executeNext()
    }
    
    func cancel() throws
    {
        try OFL.checkMainQueue()
        
        //===
        
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .cancelled
    }
    
    func executeAgain(after delay: TimeInterval = 0) throws
    {
        try OFL.checkFlowState(self, [.failed, .completed, .cancelled])
        
        //===
        
        OFL.ensureOnMain(after: delay) {
            
            try! self.reset()
        }
    }
}

//===

extension OperationFlow
{
    func shouldProceed() -> Bool
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        return (targetTaskIndex < self.core.operations.count)
    }
    
    func executeNext(_ previousResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            shouldProceed()
        {
            // regular block
            
            let task = core.operations[targetTaskIndex]
            
            //===
            
            core.targetQueue
                .addOperation {
                    
                    do
                    {
                        let result = try task(self, previousResult)
                        
                        //===
                        
                        // everything seems to be good,
                        // lets continue execution
                        
                        self.proceed(result)
                    }
                    catch
                    {
                        // the task thrown an error
                        
                        OFL.asyncOnMain { self.processFailure(error) }
                    }
            }
        }
        else
        {
            executeCompletion(previousResult)
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        // NOTE: use 'async...' here,
        // as we call this function from background queue
        
        //===
        
        OFL.asyncOnMain {
            
            if
                self.state == .processing
            {
                self.targetTaskIndex += 1
                
                //===
                
                self.executeNext(previousResult)
            }
        }
    }
    
    func executeCompletion(_ finalResult: Any?)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        state = .completed
        
        //===
        
        if
            let completion = self.core.completion
        {
            do
            {
                try completion(self, finalResult)
            }
            catch
            {
                // the task thrown an error
                
                self.processFailure(error)
            }
        }
    }
    
    func processFailure(_ error: Error)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            state == .processing
        {
            state = .failed
            
            //===
            
            failedAttempts += 1
            
            //===
            
            var shouldRetry = (failedAttempts - 1) < core.maxRetries
            
            for handler in core.failureHandlers
            {
                handler(self, error, &shouldRetry)
            }
            
            if
                shouldRetry
            {
                try! executeAgain(after: 0.25 * Double(failedAttempts))
            }
        }
    }
    
    func reset() throws
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        try OFL.checkFlowState(self, [.failed, .completed, .cancelled])
        
        //===
        
        targetTaskIndex = 0
        state = .ready
        
        try start()
    }
}
