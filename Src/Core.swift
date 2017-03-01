//
//  Core.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

extension OperationFlow
{
    struct Core
    {
        let name: String
        let targetQueue: OperationQueue
        let maxRetries: UInt // how many times to retry on failure
        
        fileprivate(set)
        var operations: [GenericOperation]
        
        fileprivate(set)
        var completion: GenericCompletion?
        
        fileprivate(set)
        var failureHandlers: [FailureGeneric]
    }
}

//===

extension OperationFlow.Core
{
    mutating
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) // -> Connector<Output>
    {
        operations.removeAll()
        
        //===
        
        operations.append { flow, _ in try op(flow) }
    }
    
    //===
    
    mutating
    func then<Input, Output>(
        _ op: @escaping ManagingOperation<Input, Output>
        )
    {
        operations.append { flow, input in
            
            guard
                let typedInput = input as? Input
            else
            {
                throw
                    InvalidInputType(
                        expected: Input.self,
                        actual: type(of: input))
            }
            
            //===
            
            return try op(flow, typedInput)
        }
    }
    
    //===
    
    mutating
    func onFailure(
        _ handler: @escaping FailureGeneric
        )
    {
        failureHandlers.append(handler)
    }
    
    mutating
    func onFailure(
        _ handlers: [FailureGeneric]
        )
    {
        failureHandlers.append(contentsOf: handlers)
    }

    //===
    
    mutating
    func finally<Input>(
        _ handler: @escaping ManagingCompletion<Input>
        )
    {
        completion = { flow, input in
                
            if
                let typedInput = input as? Input
            {
                return handler(flow, typedInput)
            }
            else
            {
                throw
                    InvalidInputType(
                        expected: Input.self,
                        actual: type(of: input))
            }
        }
    }
}
