//
//  Aliases.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias ManagingOperation<Input, Output> = (OperationFlow, Input) throws -> Output

public
typealias ManagingOperationNoInput<Output> = (OperationFlow) throws -> Output // no input

public
typealias Operation<Input, Output> = (Input) throws -> Output

public
typealias OperationNoInput<Output> = () throws -> Output // no input

public
typealias Failure<E: Error> = (OperationFlow, E) -> Void

public
typealias FailureGeneric = (OperationFlow, Error) -> Void

public
typealias ManagingCompletion<Input> = (OperationFlow, Input) -> Void

public
typealias ManagingCompletionNoInput = (OperationFlow) -> Void

public
typealias Completion<Input> = (Input) -> Void

public
typealias CompletionNoInput = () -> Void

//===

typealias GenericOperation = (OperationFlow, Any?) throws -> Any?

typealias GenericCompletion = (OperationFlow, Any?) throws -> Void
