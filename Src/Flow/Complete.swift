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
        
        self.start()
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
    func take<Input>(_ input: Input) -> FirstConnector<Input>
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
    func start()
    {
        ensureOnMain {
            
            if
                self.state == .ready
            {
                self.state = .processing
                
                //===
                
                self.executeNext()
            }
        }
    }
    
    func cancel()
    {
        ensureOnMain {
            
            if
                self.state == .processing
            {
                self.state = .cancelled
            }
        }
    }
    
    func executeAgain(after delay: TimeInterval = 0)
    {
        ensureOnMain(after: delay) {
            
            self.reset()
        }
    }
}

//===

extension OperationFlow
{
    func shouldProceed() -> Bool
    {
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
                        
                        asyncOnMain { self.processFailure(error) }
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
        
        asyncOnMain {
            
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
        if
            state == .processing
        {
            state = .failed
            
            //===
            
            failedAttempts += 1
            
            //===
            
            if
                failedAttempts > core.maxRetries
            {
                for handler in core.failureHandlers
                {
                    handler(self, error)
                }
            }
            else
            {
                executeAgain(after: 0.25 * Double(failedAttempts))
            }
        }
    }
    
    func reset()
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        switch state
        {
            case .failed,
                 .completed,
                 .cancelled:
                
                targetTaskIndex = 0
                state = .ready
                
                start()
                
            default:
                break // ignore
        }
    }
}
