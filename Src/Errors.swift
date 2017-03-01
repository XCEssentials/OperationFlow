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
struct WrongQueue: OperationFlowError
{
    let context: String
    let expected: OperationQueue
    let actual: OperationQueue?
}

//===

public
struct InvalidInputType: OperationFlowError
{
    let expected: Any.Type
    let actual: Any.Type
}

//===

public
struct InvalidFlowState: OperationFlowError
{
    let flow: String
    let context: String
    let expected: [OFL.State]
    let actual: OFL.State
}
