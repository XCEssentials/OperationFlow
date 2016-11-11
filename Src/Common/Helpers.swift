//
//  Helpers.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

func runOnMain(_ block: @escaping () -> Void)
{
    OperationQueue
        .main
        .addOperation(block)
}
