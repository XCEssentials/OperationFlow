//
//  Core.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 2/23/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

typealias FlowCore = (

    name: String,
    targetQueue: OperationQueue,
    maxRetries: UInt, // how many times to retry on failure

    operations: [GenericOperation],
    completion: GenericCompletion?,
    failureHandlers: [FailureGeneric]
)
