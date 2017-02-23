//
//  Flow.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

//public
//final
//class OperationFlow
//{
//    // MARK: Types - Public
//    
//    public
//    enum State: String
//    {
//        case
//            pending,
//            processing,
//            failed,
//            completed,
//            cancelled
//    }
//    
//    // MARK: Types - Private
//    
//    public
//    typealias CommonOperation = (_ flow: OperationFlow, _ input: Any?) throws -> Any?
//    
//    public
//    typealias CommonCompletion = (_ flow: OperationFlow, _ input: Any?) throws -> Void
//    
//    // MARK: Properties - Public
//    
//    public
//    let name: String
//    
//    public
//    let targetQueue: OperationQueue
//    
//    public
//    let maxAttempts: UInt // how many times to retry on failure
//    
//    // MARK: Properties - Semi-Private
//    
//    public internal(set)
//    var status: State = .pending
//    
//    public internal(set)
//    var failedAttempts: UInt = 0
//    
//    // MARK: Properties - Private
//    
//    var operations: [CommonOperation] = []
//    
//    var completion: CommonCompletion?
//    
//    var failureHandlers: [FailureGeneric] = []
//    
//    //===
//    
//    var isCancelled: Bool // calculated helper property
//    {
//        return status == .cancelled
//    }
//    
//    var targetTaskIndex = 0
//    
//    //===
//    
//    public
//    init(_ name: String = NSUUID().uuidString,
//         targetQueue: OperationQueue = FlowDefaults.targetQueue,
//         maxAttempts: UInt = FlowDefaults.maxAttempts)
//    {
//        self.name = name
//        self.targetQueue = targetQueue
//        self.maxAttempts = maxAttempts
//    }
//}
