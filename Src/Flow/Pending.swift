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
        self.core = (
            
            name,
            targetQueue,
            maxRetries,
            [],
            nil,
            []
        )
    }
}

//===

public
extension PendingOperationFlow
{
    func take<Input>(_ input: Input) throws -> FirstConnector<Input>
    {
        try OFL.checkMainQueue()
        
        //===
        
        return FirstConnector(self, input)
    }
}

//===

public
extension PendingOperationFlow
{
    func first<Output>(
        _ op: @escaping ManagingOperationNoInput<Output>
        ) throws -> Connector<Output>
    {
        try OFL.checkMainQueue()
        
        //===
        
        core.operations.removeAll()
        
        //===
        
        core.operations.append { flow, _ in
            
            return try op(flow)
        }
        
        //===
        
        return Connector<Output>(self)
    }

    func first<Output>(
        _ op: @escaping OperationNoInput<Output>
        ) throws -> Connector<Output>
    {
        return try first { (_: OperationFlow) in try op() }
    }
}

/*
 
 OperationFlow
     .new("Fetching something from Yelp API", on: theQueue, retry: 3)
     .new()
 
     // --- Pending ---
 
     .first(step1(initialInput)) // @autoclosure version
     .then(step2)
     .add(step2)
     .add { step2() }
 
 '.first' (or '.begin') should reset the list of operations on the flow
 and set the passed operation as the very first one
 
 add 'shouldRetry' inout param in the failure handler
 
 */
