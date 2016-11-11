//
//  Errors.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct InvalidInputType: Error
{
    let expectedType: Any.Type
    let actualType: Any.Type
}
