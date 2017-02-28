//
//  Helpers.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

enum OFL
{
    static
    func asyncOnMain(after delay: TimeInterval = 0, _ block: @escaping () -> Void)
    {
        if
            delay > 0.0
        {
            let d =
                DispatchTime.now() +
                    Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue
                .main
                .asyncAfter(deadline: d, execute: block)
        }
        else
        {
            OperationQueue
                .main
                .addOperation(block)
        }
    }
    
    static
    func ensureOnMain(after delay: TimeInterval = 0, _ block: @escaping () -> Void)
    {
        if
            delay > 0.0
        {
            asyncOnMain(after: delay, block)
        }
        else
        if
            OperationQueue.current == OperationQueue.main
        {
            block()
        }
        else
        {
            asyncOnMain(block)
        }
    }

    static
    func checkMainQueue() throws
    {
        guard
            let cur = OperationQueue.current,
            cur == OperationQueue.main
        else
        {
            throw WrongQueueUsage.outOfMain(actual: OperationQueue.current)
        }
    }
}
