//
//  Defaults.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
enum FlowDefaults
{
    public
    static
    var targetQueue = OperationQueue()
    
    public
    static
    var maxRetries: UInt = 3
}
