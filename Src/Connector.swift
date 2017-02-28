//
//  Connector.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct Connector<Input>
{
    fileprivate
    let flow: PendingOperationFlow
    
    //===
    
    init(_ flow: PendingOperationFlow)
    {
        self.flow = flow
    }
}

//===

public
extension Connector
{
    func then<Input, Output>(
        _ op: @escaping ManagingOperation<Input, Output>
        ) throws -> Connector<Output>
    {
        try OFL.checkMainQueue()
        
        //===
        
        flow.core.operations.append { flow, input in
            
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
        
        //===
        
        return Connector<Output>(flow)
    }
    
    func then<Input, Output>(
        _ op: @escaping Operation<Input, Output>
        ) throws -> Connector<Output>
    {
        return try then { (_: OperationFlow, input) in try op(input) }
    }
}

//===

public
extension Connector
{
    func onFailure(
        _ handler: @escaping FailureGeneric
        ) throws -> Connector<Input>
    {
        try OFL.checkMainQueue()
        
        //===
        
        flow.core
            .failureHandlers
            .append(handler)
        
        //===
        
        return self
    }
    
    func onFailure<E: Error>(
        _ handler: @escaping Failure<E>
        ) throws -> Connector<Input>
    {
        try OFL.checkMainQueue()
        
        //===
        
        flow.core
            .failureHandlers
            .append { flow, error, shouldRetry in
                
                if
                    let e = error as? E
                {
                    handler(flow, e, &shouldRetry)
                }
            }
        
        //===
        
        return self
    }
    
    func onFailure(
        _ handlers: [FailureGeneric]
        ) throws -> Connector<Input>
    {
        try OFL.checkMainQueue()
        
        //===
        
        flow.core
            .failureHandlers
            .append(contentsOf: handlers)
        
        //===
        
        return self
    }
}

//===

public
extension Connector
{
    @discardableResult
    func finally<Input>(
        _ handler: @escaping ManagingCompletion<Input>
        ) throws -> OperationFlow
    {
        try OFL.checkMainQueue()
        
        //===
        
        flow.core
            .completion = { flow, input in
                
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
        
        return try start()
    }
    
    @discardableResult
    public
    func start() throws -> OperationFlow
    {
        try OFL.checkMainQueue()
        
        //===
        
        return OperationFlow(flow.core)
    }
}
