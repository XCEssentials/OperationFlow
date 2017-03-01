//
//  Aliases.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//=== Operation - managing (accepting link on the Flow)

public
typealias ManagingOperation<Input, Output> = (OperationFlow, Input) throws -> Output

public
typealias ManagingOperationNoInput<Output> = (OperationFlow) throws -> Output // no input

//=== Operation - NON-managing (NOT accepting link on the Flow)

public
typealias Operation<Input, Output> = (Input) throws -> Output

public
typealias OperationNoInput<Output> = () throws -> Output // no input

//=== Failure handlers

public
typealias Failure<E: Error> = (OperationFlow, E, inout Bool) -> Void

public
typealias FailureGeneric = (OperationFlow, Error, inout Bool) -> Void

//=== Completion - managing (accepting link on the Flow)

public
typealias ManagingCompletion<Input> = (OperationFlow.InfoProxy, Input) -> Void

public
typealias ManagingCompletionNoInput = (OperationFlow.InfoProxy) -> Void

//=== Completion - NON-managing (NOT accepting link on the Flow)

public
typealias Completion<Input> = (Input) -> Void

public
typealias CompletionNoInput = () -> Void

//===

typealias GenericOperation = (OperationFlow, Any?) throws -> Any?

typealias GenericCompletion = (OperationFlow.InfoProxy, Any?) throws -> Void
