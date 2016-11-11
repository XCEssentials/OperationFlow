//
//  Flow.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
final
class OperationFlow
{
    // MARK: Types - Public
    
    public
    enum State: String
    {
        case
        pending,
        processing,
        failed,
        completed,
        cancelled
    }
    
    // MARK: Types - Private
    
    public
    typealias CommonOperation = (_ flow: OperationFlow, _ input: Any?) throws -> Any?
    
    public
    typealias CommonCompletion = (_ flow: OperationFlow, _ input: Any?) throws -> Void
    
    // MARK: Properties - Public
    
    public
    let name: String?
    
    public
    let targetQueue: OperationQueue
    
    public
    let maxAttempts: UInt // how many times to retry on failure
    
    // MARK: Properties - Semi-Private
    
    public fileprivate(set)
    var status: State = .pending
    
    public fileprivate(set)
    var failedAttempts: UInt = 0
    
    // MARK: Properties - Private
    
    private
    var operations: [CommonOperation] = []
    
    private
    var completion: CommonCompletion?
    
    private
    var failureHandler: CommonFailure?
    
    //===
    
    fileprivate
    var isCancelled: Bool // calculated helper property
    {
        return status == .cancelled
    }
    
    fileprivate
    var targetTaskIndex = 0
    
    //===
    
    public
    init(_ name: String? = nil,
         targetQueue: OperationQueue = FlowDefaults.targetQueue,
         maxAttempts: UInt = FlowDefaults.maxAttempts)
    {
        self.name = name
        self.targetQueue = targetQueue
        self.maxAttempts = maxAttempts
    }
    
    //===
    
    public
    func input<Input>(_ value: Input) -> FirstConnector<Input>
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        return FirstConnector(self, initialInput: value)
    }
    
    public
    func add<Output>(_ op: @escaping OperationShort<Output>) -> Connector<Output>
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        operations
            .append({ (flow, _) throws -> Any? in
                
                return try op(flow)
            })
        
        //===
        
        return Connector<Output>(self)
    }
    
    public
    func cancel()
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        switch status
        {
        case .pending, .processing:
            status = .cancelled
            
        default:
            break // ignore
        }
    }
    
    public
    func executeAgain() // (after: NSTimeInterval = 0)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            reset()
        {
            start()
        }
    }
    
    public
    func executeAgain(after interval: TimeInterval)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        let delay =
            DispatchTime.now() +
                Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue
            .main
            .asyncAfter(deadline: delay) { self.executeAgain() }
    }
    
    //===
    
    func add<Input, Output>(_ op: @escaping Operation<Input, Output>)
    {
        operations
            .append({ (flow, input) throws -> Any? in
                
                if
                    let typedInput = input as? Input
                {
                    return try op(flow, typedInput)
                }
                else
                {
                    throw InvalidInputType(expectedType: Input.self, actualType: type(of: input))
                }
            })
    }
    
    func onFailure(_ handler: @escaping CommonFailure)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            status == .pending
        {
            failureHandler = handler
        }
    }
    
    func finally<Input>(_ handler: @escaping Completion<Input>) -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            status == .pending
        {
            completion = { (flow, input) throws in
                
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
            
            start()
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func start() -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            status == .pending
        {
            status = .processing
            
            //===
            
            executeNext()
        }
        
        //===
        
        return self
    }
    
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
        runOnMain {
            
            if
                self.status == .processing
            {
                self.status = .failed
                
                //===
                
                self.failedAttempts += 1
                
                //===
                
                if
                    let failureHandler = self.failureHandler
                {
                    failureHandler(self, error)
                }
            }
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        runOnMain {
            
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
