//
//  MKHSequenceTests.swift
//  MKHSequenceTests
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import XCTest

//@testable
import MKHSequence

class MKHSequenceTests: XCTestCase
{
    func testSimpleCase()
    {
        // how we test async calls: http://stackoverflow.com/a/24705283
        
        //===
        
        let expectation = self.expectationWithDescription("SimpleCase Sequence")
        
        //===
        
        let res1 = "SimpleCase - 1st result"
        let res2 = "SimpleCase - 2nd result"
        
        var task1Completed = false
        var task2Completed = false
        
        //===
        
        let seq = Sequence()
        
        seq.add { (previousResult) -> Any? in
            
            XCTAssertFalse(task1Completed)
            XCTAssertFalse(task2Completed)
            XCTAssertNil(previousResult)
            XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
            
            //===
            
            for i in 0...1000
            {
                print("SimpleCase task 1, step \(i)")
            }
            
            task1Completed = true
            
            //===
            
            return res1
        }
        
        seq.add { (previousResult) -> Any? in
            
            XCTAssertTrue(task1Completed)
            XCTAssertFalse(task2Completed)
            XCTAssertNotNil(previousResult)
            XCTAssertTrue(previousResult is String)
            XCTAssertEqual((previousResult as! String), res1)
            XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
            
            //===
            
            for i in 0...10000
            {
                print("SimpleCase task 2, step \(i)")
            }
            
            task2Completed = true
            
            //===
            
            return res2
        }
        
        seq.finally { (previousResult) -> Void in
            
            XCTAssertTrue(task1Completed)
            XCTAssertTrue(task2Completed)
            XCTAssertNotNil(previousResult)
            XCTAssertTrue(previousResult is String)
            XCTAssertEqual((previousResult as! String), res2)
            XCTAssertEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
            
            //===
            
            print("SimpleCase - DONE")
            
            //===
            
            // this sequence has been completed as expected
            
            expectation.fulfill()
        }
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithError()
    {
        let expectation = self.expectationWithDescription("CaseWithError Sequence")
        
        //===
        
        let res1 = "CaseWithError - 1st result"
        let errCode = 1231481 // just random number
        
        var task1Completed = false
        var task2Completed = false
        
        //===
        
        Sequence()
            .add { (previousResult) -> Any? in
                
                XCTAssertFalse(task1Completed)
                XCTAssertFalse(task2Completed)
                XCTAssertNil(previousResult)
                XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
            
                //===
                
                for i in 0...1000
                {
                    print("CaseWithError task 1, step \(i)")
                }
                
                task1Completed = true
                
                //===
                
                return res1
            }
            .add { (previousResult) -> Any? in
            
                XCTAssertTrue(task1Completed)
                XCTAssertFalse(task2Completed)
                XCTAssertNotNil(previousResult)
                XCTAssertTrue(previousResult is String)
                XCTAssertEqual((previousResult as! String), res1)
                XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                for i in 0...10000
                {
                    print("CaseWithError task 2, step \(i)")
                }
                
                task2Completed = true
                
                //===
                
                // lets return error here
                
                return
                    NSError(domain: "MKHSmapleError",
                        code: errCode,
                        userInfo:
                            ["reason": "Just for test",
                             "origin": "CaseWithError, task 2"])
            }
            .onFailure({ (error) -> Void in
                
                XCTAssertTrue(task1Completed)
                XCTAssertTrue(task2Completed)
                XCTAssertEqual(error.code, errCode)
                XCTAssertEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                print("CaseWithError - FAILED")
                
                //===
                
                // this error block has been executed as expected
                
                expectation.fulfill()
            })
            .start()
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithCancel()
    {
        let res1 = "CaseWithCancel - 1st result"
        
        var task1Started = false
        var task1Completed = false
        var completionExecuted = false
        
        //===
        
        let seq = Sequence()
            .add { (previousResult) -> Any? in
                
                XCTAssertFalse(task1Started)
                XCTAssertFalse(task1Completed)
                XCTAssertFalse(completionExecuted)
                XCTAssertNil(previousResult)
                XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                task1Started = true
                
                for i in 0...10000
                {

                    print("CaseWithCancel task 1, step \(i)")
                }
                
                task1Completed = true
                
                //===
                
                return res1
            }
            .finally { (previousResult) in
                
                XCTAssertTrue(task1Completed)
                XCTAssertFalse(completionExecuted)
                XCTAssertNotNil(previousResult)
                XCTAssertTrue(previousResult is String)
                XCTAssertEqual((previousResult as! String), res1)
                XCTAssertEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                completionExecuted = true
                
                //===
                
                XCTAssertFalse(completionExecuted, "This blok should not be called ever.")
            }
        
        //===
        
        // make sure the sequence has not started execution yet
        
        XCTAssertFalse(task1Started)
        XCTAssertFalse(task1Completed)
        XCTAssertFalse(completionExecuted)
        
        //===
        
        NSOperationQueue.mainQueue()
            .addOperationWithBlock {
                
                // lets dispatch this call on the same (main) queue,
                // but after this whole method to be completed,
                // to give the sequence some time to start execution
                
                seq.cancel()
                
                //===
                
                // we won't be doing assumptions on whaterver
                // 'task1Completed' has been reached by execution flow or not
                // at this moment, it will be reached anyway if the 1st task
                // in the sequence will be started (as 'cancel' does not
                // stop tasks that are being executed at the moment
                
                XCTAssertTrue(task1Started)
                XCTAssertFalse(completionExecuted)
        }
    }
}
