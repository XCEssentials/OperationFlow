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
        ) -> Connector<Output>
    {
        flow.core.operations.append { flow, input in
            
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
        
        //===
        
        return Connector<Output>(flow)
    }
    
    func then<Input, Output>(
        _ op: @escaping OFLOperation<Input, Output>
        ) -> Connector<Output>
    {
        return then { (_: OperationFlow.ActiveProxy, input) in try op(input) }
    }
}

//===

public
extension OperationFlow
{
    public
    typealias InfoProxy =
    (
        name: String,
        targetQueue: OperationQueue,
        maxRetries: UInt,
        totalOperationsCount: UInt,
        
        failedAttempts: UInt,
        targetOperationIndex: UInt
    )
    
    var infoProxy: InfoProxy {
        
        return (
        
            core.name,
            core.targetQueue,
            core.maxRetries,
            UInt(core.operations.count),
            
            failedAttempts,
            targetOperationIndex
        )
    }
}

//===

public
extension Connector
{
    func onFailure(
        _ handler: @escaping FailureGeneric
        ) -> Connector<Input>
    {
        flow.core
            .failureHandlers
            .append(handler)
        
        //===
        
        return self
    }
    
    func onFailure<E: Error>(
        _ handler: @escaping Failure<E>
        ) -> Connector<Input>
    {
        return onFailure { flow, error, shouldRetry in
            
            if
                let e = error as? E
            {
                handler(flow, e, &shouldRetry)
            }
        }
    }
    
    func onFailure(
        _ handlers: [FailureGeneric]
        ) -> Connector<Input>
    {
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
        ) -> OperationFlow
    {
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
                            expected: Input.self,
                            actual: type(of: input))
                }
            }
        
        //===
        
        return start()
    }
    
    @discardableResult
    func finally<Input>(
        _ handler: @escaping Completion<Input>
        ) -> OperationFlow
    {
        return finally { (_: OperationFlow.InfoProxy, input) in handler(input) }
    }
    
    @discardableResult
    public
    func start() -> OperationFlow
    {
        return OperationFlow(flow.core)
    }
}
