//
//  Connector.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== MARK: -

public
struct Connector<NextInput> // NextInput - last Output and next Input at the same time
{
    private
    let flow: OperationFlow
    
    //===
    
    public
    init(_ flow: OperationFlow)
    {
        self.flow = flow
    }
    
    //===
    
    @discardableResult
    public
    func add<NextOutput>(_ op: @escaping OperationWithInput<NextInput, NextOutput>) -> Connector<NextOutput>
    {
        flow.add(op)
        
        //===
        
        return Connector<NextOutput>(flow)
    }
    
    @discardableResult
    public
    func onFailure<E: Error>(_ handler: @escaping FailureSpecialized<E>) -> Connector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func onFailure(_ handler: @escaping FailureGeneric) -> Connector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func onFailure(_ handlers: [FailureGeneric]) -> Connector<NextInput>
    {
        flow.onFailure(handlers)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func finally(_ handler: @escaping Completion<NextInput>) -> OperationFlow
    {
        flow.finally(handler)
        
        //===
        
        return flow
    }
    
    @discardableResult
    public
    func start() -> OperationFlow
    {
        flow.start()
        
        //===
        
        return flow
    }
}
