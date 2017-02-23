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
typealias ManagingOperation<Input, Output> = (CompleteFlow, Input) throws -> Output

public
typealias ManagingOperationNoInput<Output> = (CompleteFlow) throws -> Output // no input

public
typealias Operation<Input, Output> = (Input) throws -> Output

public
typealias OperationNoInput<Output> = () throws -> Output // no input

public
typealias Failure<E: Error> = (CompleteFlow, E) -> Void

public
typealias FailureGeneric = (CompleteFlow, Error) -> Void

public
typealias ManagingCompletion<Input> = (CompleteFlow, Input) -> Void

public
typealias ManagingCompletionNoInput = (CompleteFlow) -> Void

public
typealias Completion<Input> = (Input) -> Void

public
typealias CompletionNoInput = () -> Void

//===

typealias GenericOperation = (CompleteFlow, Any?) throws -> Any?

typealias GenericCompletion = (CompleteFlow, Any?) throws -> Void
