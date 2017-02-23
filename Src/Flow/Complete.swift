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
class CompleteFlow // just CompleteOperationFlow later
{
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
    
    let core: FlowCore
    
    //===
    
    public internal(set)
    var status: State
    
    var targetTaskIndex = 0
    
    public internal(set)
    var failedAttempts: UInt = 0
    
    //===
    
    var isCancelled: Bool { return status == .cancelled }
    
    //===
    
    init(_ core: FlowCore)
    {
        self.core = core
        self.status = .ready
        
        //===
        
        self.start()
    }
}

//===

public
extension CompleteFlow
{
    func start()
    {
        ensureOnMain {
            
            if
                self.status == .ready
            {
                self.status = .processing
                
                //===
                
                self.executeNext()
            }
        }
    }
    
    func cancel()
    {
        ensureOnMain {
            
            if
                self.status == .processing
            {
                self.status = .cancelled
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

extension CompleteFlow
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
                self.status == .processing
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
        
        status = .completed
        
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
            status == .processing
        {
            status = .failed
            
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
        
        switch status
        {
        case .failed,
             .completed,
             .cancelled:
            
            targetTaskIndex = 0
            status = .ready
            
            start()
            
        default:
            break // ignore
        }
    }
}
