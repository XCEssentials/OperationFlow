//
//  Main.swift
//  MKHSequence
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit

//===

public
class Sequence
{
    // MARK: Nested types and aliases
    
    public
    typealias Task = (previousResult: Any?) -> Any?
    
    public
    typealias CompletionHandler = (previousResult: Any?) -> Void
    
    public
    typealias FailureHandler = (error: NSError?) -> Void
    
    // MARK: Properties - Private
    
    private
    var name: String?
    
    private
    var tasks: [Task] = []
    
    private
    var onComplete: CompletionHandler?
    
    private
    var onFailure: FailureHandler?
    
    private
    var isCancelled = false
    
    // MARK: Properties - Public
    
    public
    static
    var defaultTargetQueue = NSOperationQueue()
    
    public
    var targetQueue: NSOperationQueue!
    
    // MARK: Init
    
    init(name: String? = nil)
    {
        self.name = name
        
        //===
        
        targetQueue = Sequence.defaultTargetQueue
    }
    
    // MARK: Methods - Private
    
    private func executeNext(previousResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        if self.tasks.count != 0
        {
            // regular block
            
            if let queue = self.targetQueue
            {
                let task = tasks.removeFirst()
                
                //===
                
                queue.addOperationWithBlock({ () -> Void in
                    
                    let result = task(previousResult: previousResult)
                    
                    //===
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        
                        if !self.isCancelled
                        {
                            // return
                            
                            if let error = result as? NSError
                            {
                                // lets return error and stop execution
                                
                                if let failureHandler = self.onFailure
                                {
                                    failureHandler(error: error);
                                }
                            }
                            else
                            {
                                // continue execution
                                
                                self.executeNext(result)
                            }
                        }
                    })
                })
            }
        }
        else
        {
            // completion block
            
            if let completionHandler = self.onComplete
            {
                completionHandler(previousResult: previousResult);
            }
        }
    }
    
    // MARK: Methods - Public
    
    public func add(task: Task) -> Self
    {
        tasks.append(task)
        
        //===
        
        return self
    }
    
    public func onFailure(failureHandler: FailureHandler) -> Self
    {
        onFailure = failureHandler
        
        //===
        
        return self
    }
    
    public func finally(completionHandler: CompletionHandler) -> Self
    {
        onComplete = completionHandler
        
        //===
        
        start()
        
        //===
        
        return self
    }
    
    public func start() -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if self.tasks.count != 0
        {
            self.executeNext()
        }
        
        //===
        
        return self
    }
    
    public func cancel()
    {
        isCancelled = true
    }
}
