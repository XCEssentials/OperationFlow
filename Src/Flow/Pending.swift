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
    
    init(_ name: String,
         on targetQueue: OperationQueue,
         maxRetries: UInt)
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
extension PendingOperationFlow
{
    func take<Input>(_ input: Input) -> FirstConnector<Input>
    {
        return FirstConnector(self, input)
    }
}

//===

public
extension PendingOperationFlow
{
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) -> Connector<Output>
    {
        core.operations.removeAll()
        
        //===
        
        core.operations.append { flow, _ in
            
            return try op(flow)
        }
        
        //===
        
        return Connector<Output>(self)
    }

    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        ) -> Connector<Output>
    {
        return first { (_: OperationFlow) in try op() }
    }
}

/*
 
 OperationFlow
     .new("Fetching something from Yelp API", on: theQueue, retry: 3)
     .new()
 
     // --- Pending ---
 
     .first(step1(initialInput)) // @autoclosure version
     .then(step2)
     .add(step2)
     .add { step2() }
 
 '.first' (or '.begin') should reset the list of operations on the flow
 and set the passed operation as the very first one
 
 add 'shouldRetry' inout param in the failure handler
 
 */

//===

extension PendingOperationFlow
{
//    func enq<Input, Output>(_ op: @escaping ManagingOperation<Input, Output>)
//    {
//        ensureOnMain {
//            
//            self.core
//                .operations
//                .append { flow, input in
//                    
//                    guard
//                        let typedInput = input as? Input
//                        else
//                    {
//                        throw
//                            InvalidInputType(
//                                expectedType: Input.self,
//                                actualType: type(of: input))
//                    }
//                    
//                    //===
//                    
//                    return try op(flow, typedInput)
//            }
//        }
//    }
//    
//    func onFailure<E: Error>(_ handler: @escaping Failure<E>) throws
//    {
//        guard
//            OperationQueue.current == OperationQueue.main
//        else
//        {
//            throw UsedNotOnMainQueue()
//        }
//        
//        //===
//        
//        core.failureHandlers
//            .append({ (flow, error) in
//                
//                if
//                    let e = error as? E
//                {
//                    handler(flow, e)
//                }
//            })
//    }
//    
//    func onFailure(_ handler: @escaping FailureGeneric) throws
//    {
//        guard
//            OperationQueue.current == OperationQueue.main
//        else
//        {
//            throw UsedNotOnMainQueue()
//        }
//        
//        //===
//        
//        core.failureHandlers
//            .append(handler)
//    }
//    
//    func onFailure(_ handlers: [FailureGeneric]) throws
//    {
//        guard
//            OperationQueue.current == OperationQueue.main
//        else
//        {
//            throw UsedNotOnMainQueue()
//        }
//        
//        //===
//        
//        core.failureHandlers
//            .append(contentsOf: handlers)
//    }
//    
//    func finally<Input>(_ handler: @escaping ManagingCompletion<Input>) throws -> OperationFlow
//    {
//        guard
//            OperationQueue.current == OperationQueue.main
//        else
//        {
//            throw UsedNotOnMainQueue()
//        }
//        
//        //===
//        
//        core.completion = { (flow, input) throws in
//            
//            if
//                let typedInput = input as? Input
//            {
//                return handler(flow, typedInput)
//            }
//            else
//            {
//                throw
//                    InvalidInputType(
//                        expectedType: Input.self,
//                        actualType: type(of: input))
//            }
//        }
//        
//        //===
//        
//        return start()
//    }
//    
//    func start() -> OperationFlow
//    {
//        // NOTE: this mehtod is supposed to be called on main queue
//        
//        //===
//        
//        return OperationFlow(core)
//    }
}
