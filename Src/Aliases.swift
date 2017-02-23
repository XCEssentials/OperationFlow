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
typealias OperationWithInput<Input, Output> = (OperationFlow, Input) throws -> Output

public
typealias Operation<Output> = (_ flow: OperationFlow) throws -> Output // no input

public
typealias CommonFailure = (_ flow: OperationFlow, _ error: Error) -> Void

public
typealias Failure<E: Error> = (_ flow: OperationFlow, _ error: E) -> Void

public
typealias Completion<Input> = (_ flow: OperationFlow, _ input: Input) -> Void
