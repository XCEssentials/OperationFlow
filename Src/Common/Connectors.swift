//
//  Connectors.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct FirstConnector<InitialInput> // NextInput - last Output and next Input at the same time
{
    private
    let flow: OperationFlow
    
    private
    let initialInput: InitialInput
    
    //===
    
    public
    init(_ flow: OperationFlow, initialInput: InitialInput)
    {
        self.flow = flow
        self.initialInput = initialInput
    }
    
    //===
    
    @discardableResult
    public
    func add<Output>(_ op: @escaping Operation<InitialInput, Output>) -> Connector<Output>
    {
        let input = self.initialInput
        
        //===
        
        return
            flow.add({ (fl) throws -> Output in
                
                return try op(fl, input)
            })
    }
}

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
    func add<NextOutput>(_ op: @escaping Operation<NextInput, NextOutput>) -> Connector<NextOutput>
    {
        flow.add(op)
        
        //===
        
        return Connector<NextOutput>(flow)
    }
    
    @discardableResult
    public
    func onFailure(_ handler: @escaping CommonFailure) -> Connector<NextInput>
    {
        flow.onFailure(handler)
        
        //===
        
        return self
    }
    
    @discardableResult
    public
    func finally(_ handler: @escaping Completion<NextInput>) -> OperationFlow
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
