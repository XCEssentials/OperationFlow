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
struct FirstConnector<InitialInput>
{
    private
    let flow: PendingOperationFlow
    
    private
    let initialInput: InitialInput
    
    //===
    
    init(_ flow: PendingOperationFlow, _ initialInput: InitialInput)
    {
        self.flow = flow
        self.initialInput = initialInput
    }
    
    //===
    
    public
    func add<Output>(_ op: @escaping ManagingOperation<InitialInput, Output>) -> Connector<Output>
    {
        flow.enq { [input = self.initialInput] (fl, _: Void) in
            
            return try op(fl, input)
        }
        
        //===
        
        return Connector<Output>(flow)
    }
}
