//
//  New.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 3/1/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension OFL
{
    static
    func new(
        _ name: String = NSUUID().uuidString,
        on targetQueue: OperationQueue = Defaults.targetQueue,
        maxRetries: UInt = Defaults.maxRetries
        ) -> Pending
    {
        return Pending(name,
                       on: targetQueue,
                       maxRetries: maxRetries)
    }
}

//=== Alternative ways to start new Flow with default params

public
extension OFL
{
    static
    func take<Input>(
        _ input: Input
        ) -> FirstConnector<Input>
    {
        return new().take(input)
    }
    
    static
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) -> Connector<Output>
    {
        return new().first(op)
    }
    
    static
    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        ) -> Connector<Output>
    {
        return new().first(op)
    }
}
