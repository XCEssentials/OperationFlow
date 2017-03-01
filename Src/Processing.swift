//
//  Processing.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 3/1/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

extension OperationFlow
{
    func start() throws
    {
        try OFL.checkFlowState(self, [.ready])
        
        //===
        
        self.state = .processing
        
        //===
        
        try self.executeNext()
    }
    
    func shouldProceed() throws -> Bool
    {
        try OFL.checkCurrentQueueIsMain()
        
        //===
        
        return (Int(targetOperationIndex) < self.core.operations.count)
    }
    
    func executeNext(_ previousResult: Any? = nil) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        if
            try shouldProceed()
        {
            // regular block
            
            let task = core.operations[Int(targetOperationIndex)]
            
            //===
            
            core.targetQueue
                .addOperation {
                    
                    do
                    {
                        let result = try task(self.proxy, previousResult)
                        
                        //===
                        
                        // everything seems to be good,
                        // lets continue execution
                        
                        self.proceed(result)
                    }
                    catch
                    {
                        // the task thrown an error
                        
                        OFL.asyncOnMain { try! self.processFailure(error) }
                    }
            }
        }
        else
        {
            try! executeCompletion(previousResult)
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        // NOTE: use 'async...' here,
        // as we call this function from background queue
        
        OFL.asyncOnMain {
            
            if
                self.state == .cancelled
            {
                // process cancellation somehow???
            }
            else
                if self.state == .processing
                {
                    self.targetOperationIndex += 1
                    
                    //===
                    
                    try! self.executeNext(previousResult)
            }
        }
    }
    
    func executeCompletion(_ finalResult: Any?) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .completed
        
        //===
        
        if
            let completion = self.core.completion
        {
            do
            {
                try completion(self.infoProxy, finalResult)
            }
            catch
            {
                // the task thrown an error
                
                try! self.processFailure(error)
            }
        }
    }
    
    func processFailure(_ error: Error) throws
    {
        try OFL.checkFlowState(self, [.processing])
        
        //===
        
        state = .failed
        
        //===
        
        failedAttempts += 1
        
        //===
        
        var shouldRetry = (failedAttempts - 1) < core.maxRetries
        
        for handler in core.failureHandlers
        {
            handler(self.infoProxy, error, &shouldRetry)
        }
        
        //===
        
        if
            shouldRetry
        {
            try! executeAgain(after: 0.25 * Double(failedAttempts))
        }
    }
    
    static
    var validStatesBeforeReset: [State] = [.failed, .completed, .cancelled]
    
    func reset() throws
    {
        try OFL.checkFlowState(self, OperationFlow.validStatesBeforeReset)
        
        //===
        
        targetOperationIndex = 0
        state = .ready
        
        try start()
    }
}
