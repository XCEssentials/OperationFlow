//
//  Main.swift
//  MKHOperationFlow
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import UIKit

//===

private
func runOnMain(_ block: @escaping () -> Void)
{
    OperationQueue
        .main
        .addOperation(block)
}

//===

public
enum SequenceState: String
{
    case
        pending,
        processing,
        failed,
        completed,
        cancelled
}

//===

public
final
class OperationFlow<Input>
{
    // MARK: Properties - Private
    
    fileprivate
    var input: Input? = nil
    
    fileprivate
    var tasks: [Task] = []
    
    fileprivate
    var onComplete: CompletionHandler?
    
    fileprivate
    var onFailure: FailureHandler?
    
    fileprivate
    var isCancelled: Bool // calculated helper property
    {
        return status == .cancelled
    }
    
    fileprivate
    var targetTaskIndex = 0
    
    // MARK: Nested types and aliases
    
    public
    typealias Task = (_: Sequence, _ previousResult: Any?) throws -> Any?
    
    public
    typealias FailureHandler = (_: Sequence, _ error: Error) -> Void
    
    public
    typealias CompletionHandler = (_: Sequence, _ lastResult: Any?) -> Void
    
    // MARK: Properties - Public
    
    public fileprivate(set)
    var name: String?
    
    public
    var targetQueue: OperationQueue!
    
    public fileprivate(set)
    var status: Status = .pending
    
    public fileprivate(set)
    var failedAttempts: UInt = 0
    
    // MARK: Init
    
    public
    init(name: String? = nil, targetQueue: OperationQueue = OperationQueue())
    {
        self.name = name
        self.targetQueue = targetQueue
    }
}

// MARK: Methods - Private

private
extension Sequence
{
    func shouldProceed() -> Bool
    {
        return (targetTaskIndex < self.tasks.count)
    }
    
    func executeNext(_ previousResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if
            shouldProceed()
        {
            // regular block
            
            let task = tasks[targetTaskIndex]
            
            //===
            
            targetQueue
                .addOperation({ () -> Void in
                    
                    do
                    {
                        let result = try task(self, previousResult)
                        
                        //===
                        
                        // everything seems to be good,
                        // lets continue execution
                        
                        self.proceed(result)
                    }
                    catch let error
                    {
                        // the task trown an error
                        
                        self.reportFailure(error)
                    }
                })
        }
        else
        {
            executeCompletion(previousResult)
        }
    }
    
    func reportFailure(_ error: Error)
    {
        runOnMain {
            
            if self.status == .processing
            {
                self.status = .failed
                
                //===
                
                self.failedAttempts += 1
                
                //===
                
                if let failureHandler = self.onFailure
                {
                    failureHandler(self, error)
                }
            }
        }
    }
    
    func proceed(_ previousResult: Any? = nil)
    {
        runOnMain { 
            
            if self.status == .processing
            {
                self.targetTaskIndex += 1
                
                //===
                
                self.executeNext(previousResult)
            }
        }
    }
    
    func executeCompletion(_ finalResult: Any? = nil)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        status = .completed
        
        //===
        
        if
            let completionHandler = self.onComplete
        {
            completionHandler(self, finalResult);
        }
    }
    
    func reset() -> Bool
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        var result = false
        
        //===
        
        switch status
        {
            case .failed, .completed, .cancelled:
                
                targetTaskIndex = 0
                status = .pending
                
                //===
                
                result = true
                
            default:
                break // ignore
        }
        
        //===
        
        return result
    }
}

// MARK: Methods - Public

public
extension Sequence
{
    @discardableResult
    func input(_ data: Any) -> Self
    {
        if status == .pending
        {
            self.inputData = data
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func beginWith<InputDataType>(_ preparation: () -> InputDataType?) -> Self
    {
        if status == .pending
        {
            self.inputData = preparation()
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func add<PreviousResultType, ResultType>(
        _ task: @escaping (_: Sequence, _: PreviousResultType?) throws -> ResultType?
        ) -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if status == .pending
        {
            let genericTask: Task = { (genSeq, genPrevRes) throws -> Any? in
                
                return
                    try task(
                        genSeq,
                        genPrevRes as? PreviousResultType)
            }
            
            //===
            
            tasks.append(genericTask)
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func then<PreviousResultType, ResultType>(
        _ task: @escaping (_: Sequence, _: PreviousResultType?) throws -> ResultType?
        ) -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        return add(task)
    }
    
    @discardableResult
    func onFailure(_ failureHandler: @escaping FailureHandler) -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if status == .pending
        {
            onFailure = failureHandler
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func finally<LastResultType: Any>(
        _ completion: @escaping (_ sequence: Sequence, _ lastResult: LastResultType?) -> Void
        ) -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if status == .pending
        {
            let genericCompletion: CompletionHandler = { sequence, lastResult in
                
                return completion(sequence, lastResult as? LastResultType)
            }
            
            //===
            
            onComplete = genericCompletion
            
            //===
            
            start()
        }
        
        //===
        
        return self
    }
    
    @discardableResult
    func start() -> Self
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if status == .pending
        {
            status = .processing
            
            //===
            
            executeNext(self.inputData)
        }
        
        //===
        
        return self
    }
    
    func cancel()
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        switch status
        {
            case .pending, .processing:
                status = .cancelled
            
            default:
                break // ignore
        }
    }
    
    func executeAgain() // (after: NSTimeInterval = 0)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        if reset()
        {
            start()
        }
    }
    
    func executeAgain(after interval: TimeInterval)
    {
        // NOTE: this mehtod is supposed to be called on main queue
        
        //===
        
        let delay = DispatchTime.now() + Double(Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue
            .main
            .asyncAfter(deadline: delay) { self.executeAgain() }
    }
}
