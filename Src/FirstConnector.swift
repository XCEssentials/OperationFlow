//
//  FirstConnector.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
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
