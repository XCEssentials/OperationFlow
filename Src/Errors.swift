//
//  Errors.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
protocol OperationFlowError: Error {}

//===

public
struct WrongQueueUsage: OperationFlowError
{
    let expected: OperationQueue
    let actual: OperationQueue?
    
    //===
    
    static
    func outOfMain(actual: OperationQueue?) -> WrongQueueUsage
    {
        return
            WrongQueueUsage(
                expected: OperationQueue.main,
                actual: actual)
    }
}

//===

public
struct InvalidInputType: OperationFlowError
{
    let expectedType: Any.Type
    let actualType: Any.Type
}

//===

public
struct InvalidFlowState: OperationFlowError
{
    let expected: [OperationFlow.State]
    let actual: OperationFlow.State
}
