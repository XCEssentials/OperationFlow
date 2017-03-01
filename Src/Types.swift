//
//  Types.swift
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
    //=== Operation - managing (accepting link on the Flow)
    
    typealias ManagingOperation<Input, Output> =
        (ActiveProxy, Input) throws -> Output
    
    typealias ManagingOperationNoInput<Output> =
        (ActiveProxy) throws -> Output // no input
    
    //=== Operation - NON-managing (NOT accepting link on the Flow)
    
    typealias Operation<Input, Output> =
        (Input) throws -> Output
    
    typealias OperationNoInput<Output> =
        () throws -> Output // no input
    
    //=== Failure handlers
    
    typealias Failure<E: Error> =
        (OperationFlow.InfoProxy, E, inout Bool) -> Void
    
    typealias FailureGeneric =
        (OperationFlow.InfoProxy, Error, inout Bool) -> Void
    
    //=== Completion - managing (accepting link on the Flow)
    
    typealias ManagingCompletion<Input> =
        (OperationFlow.InfoProxy, Input) -> Void
    
    typealias ManagingCompletionNoInput =
        (OperationFlow.InfoProxy) -> Void
    
    //=== Completion - NON-managing (NOT accepting link on the Flow)
    
    typealias Completion<Input> =
        (Input) -> Void
    
    typealias CompletionNoInput =
        () -> Void

    //===

    typealias GenericOperation =
        (OperationFlow.ActiveProxy, Any?) throws -> Any?
    
    typealias GenericCompletion =
        (OperationFlow.InfoProxy, Any?) throws -> Void
}
