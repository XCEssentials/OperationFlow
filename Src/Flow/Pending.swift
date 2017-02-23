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
