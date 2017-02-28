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
        ) -> Connector<Output>
    {
        return
            then { (_: OperationFlow, input) in try op(input) }
    }
}

//===

public
extension Connector
{
//    public
//    func onFailure<E: Error>(_ handler: @escaping Failure<E>) -> Connector<Input>
//    {
//        flow.onFailure(handler)
//        
//        //===
//        
//        return self
//    }
//    
//    public
//    func onFailure(_ handler: @escaping FailureGeneric) -> Connector<Input>
//    {
//        flow.onFailure(handler)
//        
//        //===
//        
//        return self
//    }
//    
//    public
//    func onFailure(_ handlers: [FailureGeneric]) -> Connector<Input>
//    {
//        flow.onFailure(handlers)
//        
//        //===
//        
//        return self
//    }
}

//===

public
extension Connector
{
//    @discardableResult
//    public
//    func finally(_ handler: @escaping ManagingCompletion<Input>) -> OperationFlow
//    {
//        return flow.finally(handler)
//    }
//    
//    @discardableResult
//    public
//    func start() -> OperationFlow
//    {
//        return flow.start()
//    }
}
