//
//  Core.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

struct FlowCore
{
    let name: String
    let targetQueue: OperationQueue
    let maxRetries: UInt // how many times to retry on failure

    var operations: [GenericOperation]
    var completion: GenericCompletion?
    var failureHandlers: [FailureGeneric]
}
