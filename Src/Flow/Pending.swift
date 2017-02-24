//
//  Pending.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
final
class PendingOperationFlow
{
    var core: FlowCore
    
    //===
    
    init(_ name: String = NSUUID().uuidString,
         on targetQueue: OperationQueue = FlowDefaults.targetQueue,
         maxRetries: UInt = FlowDefaults.maxRetries)
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

/*
 
 OperationFlow
     .new("Fetching something from Yelp API", on: theQueue, retry: 3)
     .new()
     .begin(step1(initialInput)) // @autoclosure version of 'add'
     .first(step1(initialInput)) // @autoclosure version of 'add'
     .then(step2)
     .add(step2)
 
 '.first' (or '.begin') should reset the list of operations on the flow
 and set the passed operation as the very first one
 
 add 'shouldRetry' inout param in the failure handler
 
 */

//===

public
extension PendingOperationFlow
{
    func input<Input>(_ value: Input) -> FirstConnector<Input>
    {
        return FirstConnector(self, value)
    }
    
    func add<Output>(_ op: @escaping ManagingOperationNoInput<Output>) -> Connector<Output>
    {
        enq { (flow, _: Void) in return try op(flow) }
        
        //===
        
        return Connector<Output>(self)
    }
}

//===

extension PendingOperationFlow
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
    
    func finally<Input>(_ handler: @escaping ManagingCompletion<Input>) -> OperationFlow
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
    
    func start() -> OperationFlow
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        return OperationFlow(core)
    }
}
