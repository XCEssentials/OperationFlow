//
//  Core.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

typealias FlowCore = (

    name: String,
    targetQueue: OperationQueue,
    maxRetries: UInt, // how many times to retry on failure

    operations: [GenericOperation],
    completion: GenericCompletion?,
    failureHandlers: [FailureGeneric]
)

//===

public
struct NewFirstConnector<InitialInput>
{
    private
    let flow: PendingFlow
    
    private
    let initialInput: InitialInput
    
    //===
    
    init(_ flow: PendingFlow, _ initialInput: InitialInput)
    {
        self.flow = flow
        self.initialInput = initialInput
    }
    
    //===
    
    public
    func add<Output>(_ op: @escaping ManagingOperation<InitialInput, Output>) -> NewConnector<Output>
    {
        flow.enq { [input = self.initialInput] (fl, _: Void) in
            
            return try op(fl, input)
        }
        
        //===
        
        return NewConnector<Output>(flow)
    }
}

//===

public
struct NewConnector<NextInput>
{
    private
    let flow: PendingFlow
    
    //===
    
    public
    init(_ flow: PendingFlow)
    {
        self.flow = flow
    }
    
    //===
    
    public
    func add<NextOutput>(_ op: @escaping ManagingOperation<NextInput, NextOutput>) -> NewConnector<NextOutput>
    {
        flow.enq(op)
        
        //===
        
        return NewConnector<NextOutput>(flow)
    }
    
    public
    func onFailure<E: Error>(_ handler: @escaping Failure<E>) -> NewConnector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    public
    func onFailure(_ handler: @escaping FailureGeneric) -> NewConnector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }

    public
    func onFailure(_ handlers: [FailureGeneric]) -> NewConnector<NextInput>
    {
        flow.onFailure(handlers)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func finally(_ handler: @escaping ManagingCompletion<NextInput>) -> CompleteFlow
    {
        return flow.finally(handler)
    }
    
    @discardableResult
    public
    func start() -> CompleteFlow
    {
        return flow.start()
    }
}

//===

public
final
class PendingFlow // just OperationFlow later
{
    var core: FlowCore
    
    //===
    
    public
    init(_ name: String = NSUUID().uuidString,
         on targetQueue: OperationQueue = FlowDefaults.targetQueue,
         maxRetries: UInt = FlowDefaults.maxAttempts)
    {
        self.core = (
            
            name,
            targetQueue,
            maxRetries,
            [],
            nil,
            []
        )
    }
}

//===

public
extension PendingFlow
{
    func input<Input>(_ value: Input) -> NewFirstConnector<Input>
    {
        return NewFirstConnector(self, value)
    }
    
    func add<Output>(_ op: @escaping ManagingOperationNoInput<Output>) -> NewConnector<Output>
    {
        enq { (flow, _: Void) in return try op(flow) }
        
        //===
        
        return NewConnector<Output>(self)
    }
}

//===

extension PendingFlow
{
    func enq<Input, Output>(_ op: @escaping ManagingOperation<Input, Output>)
    {
        ensureOnMain {
            
            self.core
                .operations
                .append { flow, input in
                    
                    guard
                        let typedInput = input as? Input
                    else
                    {
                        throw
                            InvalidInputType(
                                expectedType: Input.self,
                                actualType: type(of: input))
                    }
                    
                    //===
                    
                    return try op(flow, typedInput)
                }
        }
    }
    
    func onFailure<E: Error>(_ handler: @escaping Failure<E>)
    {
        ensureOnMain {
            
            self.core
                .failureHandlers
                .append({ (flow, error) in
                    
                    if
                        let e = error as? E
                    {
                        handler(flow, e)
                    }
                })
        }
    }
    
    func onFailure(_ handler: @escaping FailureGeneric)
    {
        ensureOnMain {
            
            self.core
                .failureHandlers
                .append(handler)
        }
    }
    
    func onFailure(_ handlers: [FailureGeneric])
    {
        ensureOnMain {
            
            self.core
                .failureHandlers
                .append(contentsOf: handlers)
        }
    }
    
    func finally<Input>(_ handler: @escaping ManagingCompletion<Input>) -> CompleteFlow
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        core.completion = { (flow, input) throws in
            
            if
                let typedInput = input as? Input
            {
                return handler(flow, typedInput)
            }
            else
            {
                throw
                    InvalidInputType(
                        expectedType: Input.self,
                        actualType: type(of: input))
            }
        }
        
        //===
        
        return start()
    }
    
    func start() -> CompleteFlow
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        return CompleteFlow(core)
    }
}

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
