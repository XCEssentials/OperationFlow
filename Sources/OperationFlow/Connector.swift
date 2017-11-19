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
    let flow: OFL.Pending
    
    //===
    
    init(_ flow: OFL.Pending)
    {
        self.flow = flow
    }
}

//===

public
extension Connector
{
    func then<Input, Output>(
        _ op: @escaping OFL.ManagingOperation<Input, Output>
        ) -> Connector<Output>
    {
        flow.core.then(op)
        
        //===
        
        return Connector<Output>(flow)
    }
    
    func then<Input, Output>(
        _ op: @escaping OFL.Operation<Input, Output>
        ) -> Connector<Output>
    {
        flow.core.then { _, input in

            try op(input)
        }

        //===

        return Connector<Output>(flow)
    }
}

//===

public
extension Connector
{
    func thenAsync<Input, Output>(
        _ op: @escaping OFL.ManagingOperation<Input, Promise<Output>>
        ) -> Connector<Output>
    {
        flow.core.then(op)
        
        //===
        
        return Connector<Output>(flow)
    }
    
    func thenAsync<Input, Output>(
        _ op: @escaping OFL.Operation<Input, Promise<Output>>
        ) -> Connector<Output>
    {
        flow.core.then { _, input in

            try op(input)
        }

        //===

        return Connector<Output>(flow)
    }
}

//===

public
extension Connector
{
    func onFailure(
        _ handler: @escaping OFL.FailureGeneric
        ) -> Connector<Input>
    {
        flow.core.onFailure(handler)
        
        //===
        
        return self
    }
    
    func onFailure<E: Error>(
        _ handler: @escaping OFL.Failure<E>
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
        _ handlers: [OFL.FailureGeneric]
        ) -> Connector<Input>
    {
        flow.core.onFailure(handlers)
        
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
        _ handler: @escaping OFL.ManagingCompletion<Input>
        ) -> OperationFlow
    {
        flow.core.finally(handler)
        
        //===
        
        return start()
    }
    
    @discardableResult
    func finally<Input>(
        _ handler: @escaping OFL.Completion<Input>
        ) -> OperationFlow
    {
        flow.core.finally { _, input in

            handler(input)
        }

        //===

        return start()
    }
    
    @discardableResult
    public
    func start() -> OperationFlow
    {
        return OperationFlow(flow.core)
    }
}
