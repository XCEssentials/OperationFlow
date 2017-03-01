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
extension OFL
{
    enum Defaults
    {
        static
        var targetQueue = OperationQueue()
        
        static
        var maxRetries: UInt = 3
    }
}
