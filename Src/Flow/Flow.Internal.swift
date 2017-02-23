//
//  Flow.Internal.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: - Internal methods

extension OperationFlow
{
    func add<Input, Output>(_ op: @escaping Operation<Input, Output>)
    {
        ensureOnMain {
            
            self.operations
                .append { (flow, input) throws -> Any? in
                    
                    if
                        let typedInput = input as? Input
                    {
                        return try op(flow, typedInput)
                    }
                    else
                    {
                        throw InvalidInputType(expectedType: Input.self, actualType: type(of: input))
                    }
            }
        }
    }
    
    func onFailure<E: Error>(_ handler: @escaping Failure<E>)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            if
                self.status == .pending
            {
                self.failureHandlers
                    .append({ (flow, error) in
                        
                        if
                            let error = error as? E
                        {
                            handler(flow, error)
                        }
                    })
            }
        }
    }
    
    func onFailure(_ handler: @escaping CommonFailure)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            if
                self.status == .pending
            {
                self.failureHandlers
                    .append(handler)
            }
        }
    }
    
    func onFailure(_ handlers: [CommonFailure])
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            if
                self.status == .pending
            {
                self.failureHandlers
                    .append(contentsOf: handlers)
            }
        }
    }
    
    func finally<Input>(_ handler: @escaping Completion<Input>)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            if
                self.status == .pending
            {
                self.completion = { (flow, input) throws in
                    
                    if
                        let typedInput = input as? Input
                    {
                        return handler(flow, typedInput)
                    }
                    else
                    {
                        throw InvalidInputType(expectedType: Input.self, actualType: type(of: input))
                    }
                }
                
                //===
                
                self.start()
            }
        }
    }
    
    func start()
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        ensureOnMain {
            
            if
                self.status == .pending
            {
                self.status = .processing
                
                //===
                
                self.executeNext()
            }
        }
    }
}

//=== MARK: - Other internal methods

extension OperationFlow
{
    func shouldProceed() -> Bool
    {
        return (targetTaskIndex < self.operations.count)
    }
    
    func executeNext(_ previousResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            shouldProceed()
        {
            // regular block
            
            let task = operations[targetTaskIndex]
            
            //===
            
            targetQueue
                .addOperation({
                    
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
                        
                        self.reportFailure(error)
                    }
                })
        }
        else
        {
            executeCompletion(previousResult)
        }
    }
    
    func reportFailure(_ error: Error)
    {
        addToMain {
            
            if
                self.status == .processing
            {
                self.status = .failed
                
                //===
                
                self.failedAttempts += 1
                
                //===
                
                for handler in self.failureHandlers
                {
                    handler(self, error)
                }
            }
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        addToMain {
            
            if
                self.status == .processing
            {
                self.targetTaskIndex += 1
                
                //===
                
                self.executeNext(previousResult)
            }
        }
    }
    
    func executeCompletion(_ finalResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        status = .completed
        
        //===
        
        if
            let completion = self.completion
        {
            do
            {
                try completion(self, finalResult)
            }
            catch
            {
                // the task thrown an error
                
                self.reportFailure(error)
            }
        }
    }
    
    func reset() -> Bool
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        var result = false
        
        //===
        
        switch status
        {
        case .failed, .completed, .cancelled:
            
            targetTaskIndex = 0
            status = .pending
            
            result = true
            
        default:
            break // ignore
        }
        
        //===
        
        return result
    }
}
