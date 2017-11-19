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
extension OFL
{
    final
    class Pending
    {
        var core: Core
        
        //===
        
        init(_ name: String,
             on targetQueue: OperationQueue,
             maxRetries: UInt)
        {
            self.core = Core(
                
                name: name,
                targetQueue: targetQueue,
                maxRetries: maxRetries,
                
                operations: [],
                completion: nil,
                failureHandlers: []
            )
        }
    }
}

//===

public
extension OFL.Pending
{
    func take<Input>(_ input: Input) -> FirstConnector<Input>
    {
        return FirstConnector(self, input)
    }
}

//===

public
extension OFL.Pending
{
    func first<Output>(
        _ op: @escaping OFL.ManagingOperationNoInput<Output>
        ) -> Connector<Output>
    {
        core.first(op)
        
        //===
        
        return Connector<Output>(self)
    }

    func first<Output>(
        _ op: @escaping OFL.OperationNoInput<Output>
        ) -> Connector<Output>
    {
        return first { (_: OFL.ActiveProxy) in
            
            try op()
        }
    }
}

//===

public
extension OFL.Pending
{
    func firstAsync<Output>(
        _ op: @escaping OFL.ManagingOperationNoInput<Promise<Output>>
        ) -> Connector<Output>
    {
        core.first(op)
        
        //===
        
        return Connector<Output>(self)
    }
    
    func firstAsync<Output>(
        _ op: @escaping OFL.OperationNoInput<Promise<Output>>
        ) -> Connector<Output>
    {
        return firstAsync { (_: OFL.ActiveProxy) in
            
            try op()
        }
    }
}
