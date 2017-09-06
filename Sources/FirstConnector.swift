//
//  FirstConnector.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/28/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct FirstConnector<Input>
{
    fileprivate
    let flow: OFL.Pending
    
    fileprivate
    let input: Input
    
    //===
    
    init(_ flow: OFL.Pending, _ input: Input)
    {
        self.flow = flow
        self.input = input
    }
}

//===

public
extension FirstConnector
{
    func first<Output>(
        _ op: @escaping OFL.ManagingOperation<Input, Output>
        ) -> Connector<Output>
    {
        return flow.first { try op($0, self.input) }
    }
    
    func first<Output>(
        _ op: @escaping OFL.Operation<Input, Output>
        ) -> Connector<Output>
    {
        return flow.first { try op(self.input) }
    }
}

//===

public
extension FirstConnector
{
    func firstAsync<Output>(
        _ op: @escaping OFL.ManagingOperation<Input, Promise<Output>>
        ) -> Connector<Output>
    {
        return flow.firstAsync { try op($0, self.input) }
    }
    
    func firstAsync<Output>(
        _ op: @escaping OFL.Operation<Input, Promise<Output>>
        ) -> Connector<Output>
    {
        return firstAsync { (_: OFL.ActiveProxy, input) in
            
            try op(input)
        }
    }
}
