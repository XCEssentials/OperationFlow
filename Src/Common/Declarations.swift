//
//  Declarations.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias Operation<Input, Output> = (_ flow: OperationFlow, _ input: Input) throws -> Output

public
typealias OperationShort<Output> = (_ flow: OperationFlow) throws -> Output // no input

public
typealias CommonFailure = (_ flow: OperationFlow, _ error: Error) -> Void

//public
//typealias Failure<Err> = (_ flow: OperationFlow, _ error: Err) -> Void

public
typealias Completion<Input> = (_ flow: OperationFlow, _ input: Input) -> Void
