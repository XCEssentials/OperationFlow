//
//  Pending.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
final
class PendingOperationFlow
{
    var core: FlowCore
    
    //===
    
    init(_ name: String,
         on targetQueue: OperationQueue,
         maxRetries: UInt)
    {
        self.core = FlowCore(
            
            name: name,
            targetQueue: targetQueue,
            maxRetries: maxRetries,
            
            operations: [],
            completion: nil,
            failureHandlers: []
        )
    }
}

//===

public
extension PendingOperationFlow
{
    func take<Input>(_ input: Input) -> FirstConnector<Input>
    {
        return FirstConnector(self, input)
    }
}

//===

public
extension PendingOperationFlow
{
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) -> Connector<Output>
    {
        core.first(op)
        
        //===
        
        return Connector<Output>(self)
    }

    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        ) -> Connector<Output>
    {
        return first { (_: OperationFlow.ActiveProxy) in try op() }
    }
}
