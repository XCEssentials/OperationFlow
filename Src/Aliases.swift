//
//  Aliases.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===



//=== Operation - managing (accepting link on the Flow)

public
typealias ManagingOperation<Input, Output> = (OperationFlow.ActiveProxy, Input) throws -> Output

public
typealias ManagingOperationNoInput<Output> = (OperationFlow.ActiveProxy) throws -> Output // no input

//=== Operation - NON-managing (NOT accepting link on the Flow)

public
typealias OFLOperation<Input, Output> = (Input) throws -> Output

public
typealias OperationNoInput<Output> = () throws -> Output // no input

//=== Failure handlers

public
typealias Failure<E: Error> = (OperationFlow.InfoProxy, E, inout Bool) -> Void

public
typealias FailureGeneric = (OperationFlow.InfoProxy, Error, inout Bool) -> Void

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

typealias GenericOperation = (OperationFlow.ActiveProxy, Any?) throws -> Any?

typealias GenericCompletion = (OperationFlow.InfoProxy, Any?) throws -> Void
