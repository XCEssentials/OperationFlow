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
struct Connector<NextInput>
{
    private
    let flow: PendingOperationFlow
    
    //===
    
    public
    init(_ flow: PendingOperationFlow)
    {
        self.flow = flow
    }
    
    //===
    
    public
    func add<NextOutput>(_ op: @escaping ManagingOperation<NextInput, NextOutput>) -> Connector<NextOutput>
    {
        flow.enq(op)
        
        //===
        
        return Connector<NextOutput>(flow)
    }
    
    public
    func onFailure<E: Error>(_ handler: @escaping Failure<E>) -> Connector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    public
    func onFailure(_ handler: @escaping FailureGeneric) -> Connector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    public
    func onFailure(_ handlers: [FailureGeneric]) -> Connector<NextInput>
    {
        flow.onFailure(handlers)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func finally(_ handler: @escaping ManagingCompletion<NextInput>) -> OperationFlow
    {
        return flow.finally(handler)
    }
    
    @discardableResult
    public
    func start() -> OperationFlow
    {
        return flow.start()
    }
}
