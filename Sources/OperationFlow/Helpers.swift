//
//  Helpers.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/12/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

extension OFL
{
    static
    func asyncOnMain(
        after delay: TimeInterval = 0,
        _ block: @escaping () -> Void
        )
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
    func ensureOnMain(
        after delay: TimeInterval = 0,
        _ block: @escaping () -> Void
        )
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
    func checkQueue(
        context: String = #function,
        _ actual: OperationQueue?,
        is expected: OperationQueue
        ) throws
    {
        guard
            let a = actual,
            expected == a
        else
        {
            throw
                WrongQueue(
                    context: context,
                    expected: expected,
                    actual: actual)
        }
    }

    static
    func checkCurrentQueue(
        context: String = #function,
        is expected: OperationQueue) throws
    {
        try checkQueue(
            context: context,
            OperationQueue.current,
            is: expected)
    }
    
    static
    func checkCurrentQueueIsMain(
        _ context: String = #function
        ) throws
    {
        try checkQueue(
            context: context,
            OperationQueue.current,
            is: OperationQueue.main)
    }
    
    static
    func checkFlowState(
        context: String = #function,
        _ flow: OperationFlow,
        _ expectedStates: [OFL.State]
        ) throws
    {
        try checkCurrentQueueIsMain()
        
        //===
        
        guard
            expectedStates.contains(flow.state)
        else
        {
            throw
                InvalidFlowState(
                    flow: flow.core.name,
                    context: context,
                    expected: expectedStates,
                    actual: flow.state)
        }
    }
}
