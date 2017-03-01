//
//  Proxy.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 3/1/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
extension OFL
{
    typealias InfoProxy =
    (
        name: String,
        targetQueue: OperationQueue,
        maxRetries: UInt,
        totalOperationsCount: UInt,
        
        failedAttempts: UInt,
        targetOperationIndex: UInt
    )
    
    var infoProxy: InfoProxy {
        
        return (
            
            core.name,
            core.targetQueue,
            core.maxRetries,
            UInt(core.operations.count),
            
            failedAttempts,
            targetOperationIndex
        )
    }
}

//===

public
extension OFL
{
    typealias ActiveProxy =
    (
        name: String,
        targetQueue: OperationQueue,
        maxRetries: UInt,
        totalOperationsCount: UInt,
        
        failedAttempts: UInt,
        targetOperationIndex: UInt,
        
        cancel: () throws -> Void
    )
    
    var proxy: ActiveProxy {
        
        return (
            
            core.name,
            core.targetQueue,
            core.maxRetries,
            UInt(core.operations.count),
            
            failedAttempts,
            targetOperationIndex,
            
            cancel
        )
    }
}
