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

//===

enum TestError: ErrorType
{
    case One, Two(code: Int)
}

//===

class MKHSequenceTests: XCTestCase
{
    func testSimpleCase()
    {
        // how we test async calls: http://stackoverflow.com/a/24705283
        
        //===
        
        let expectation =
            expectationWithDescription("SimpleCase Sequence")
        
        //===
        
        let res1 = "SimpleCase - 1st result"
        let res2 = "SimpleCase - 2nd result"
        
        var task1Completed = false
        var task2Completed = false
        
        //===
        
        let seq = Sequence()
        
        seq.add { (_, previousResult: Any?) -> Any? in
            
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
        
        seq.add { (_, previousResult: String?) -> Any? in
            
            XCTAssertTrue(task1Completed)
            XCTAssertFalse(task2Completed)
            XCTAssertNotNil(previousResult)
            XCTAssertEqual(previousResult, res1)
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
        
        seq.finally { (_, lastResult: String?) in
            
            XCTAssertTrue(task1Completed)
            XCTAssertTrue(task2Completed)
            XCTAssertNotNil(lastResult)
            XCTAssertEqual(lastResult, res2)
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
        let expectation =
            expectationWithDescription("CaseWithError Sequence")
        
        //===
        
        let res1 = "CaseWithError - 1st result"
        let errCode = 1231481 // just random number
        
        var task1Completed = false
        
        //===
        
        Sequence()
            .add { (_, previousResult: Any?) -> Any? in
                
                XCTAssertFalse(task1Completed)
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
            .add { (_, previousResult: String?) -> Any? in
            
                XCTAssertTrue(task1Completed)
                XCTAssertNotNil(previousResult)
                XCTAssertEqual(previousResult, res1)
                XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                for i in 0...10000
                {
                    print("CaseWithError task 2, step \(i)")
                }
                
                //===
                
                // lets return error here
                
                throw TestError.Two(code: errCode)
            }
            .onFailure({ (_, error) -> Void in
                
                XCTAssertTrue(task1Completed)
                XCTAssertEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                XCTAssertTrue(error is TestError)
                
                switch error
                {
                    case TestError.Two(let code):
                        XCTAssertEqual(code, errCode)
                    
                    default:
                        XCTAssert(false, "Received wrong error type")
                }
                
                //===
                
                print("CaseWithError - FAILURE REPORTED")
                
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
        
        //===
        
        Sequence()
            .add { (sequence, previousResult: Any?) -> Any? in
                
                XCTAssertFalse(task1Started)
                XCTAssertFalse(task1Completed)
                XCTAssertNotEqual(sequence.status, Sequence.Status.Cancelled)
                XCTAssertNil(previousResult)
                XCTAssertNotEqual(NSOperationQueue.currentQueue(), NSOperationQueue.mainQueue())
                
                //===
                
                task1Started = true
                
                //===
                
                NSOperationQueue.mainQueue()
                    .addOperationWithBlock {
                        
                        XCTAssertTrue(task1Started)
                        XCTAssertFalse(task1Completed)
                        XCTAssertNotEqual(sequence.status, Sequence.Status.Cancelled)
                        
                        //===
                        
                        sequence.cancel()
                        
                        //===
                        
                        XCTAssertEqual(sequence.status, Sequence.Status.Cancelled)
                    }
                
                //===
                
                for i in 0...10000
                {

                    print("CaseWithCancel task 1, step \(i)")
                }
                
                task1Completed = true
                
                //===
                
                XCTAssertEqual(sequence.status, Sequence.Status.Cancelled)
                
                //===
                
                return res1
            }
            .finally { (_, lastResult: Any?) in
                
                XCTAssert(false, "This blok should NOT be called ever.")
            }
        
        //===
        
        // make sure the sequence has not started execution yet
        
        XCTAssertFalse(task1Started)
        XCTAssertFalse(task1Completed)
    }
    
    func testCaseWithErrorAndRepeat()
    {
        let expectation =
            expectationWithDescription("CaseWithErrorAndRepeat Sequence")
        
        //===
        
        let res1 = "CaseWithErrorAndRepeat - 1st result"
        let errCode = 1231481 // just random number
        
        var failureReported = false
        var shouldReportFailure = true
        
        //===
        
        Sequence()
            .add { (_, previousResult: Any?) -> Any? in
                
                for i in 0...1000
                {
                    print("SimpleCase task 1, step \(i)")
                }
                
                //===
                
                if shouldReportFailure
                {
                    throw TestError.Two(code: errCode)
                }
                else
                {
                    return res1
                }
            }
            .onFailure({ (sequence, error) -> Void in
                
                XCTAssertFalse(failureReported)
                
                //===
                
                XCTAssertTrue(error is TestError)
                
                switch error
                {
                    case TestError.Two(let code):
                        XCTAssertEqual(code, errCode)
                        
                    default:
                        XCTAssert(false, "Received wrong error type")
                }
                
                //===
                
                failureReported = true
                shouldReportFailure = false
                
                //===
                
                // re-try after 1.5 seconds
                
                sequence.executeAgain(after: 1.5)
            })
            .finally { (_, lastResult: Any?) in
                
                XCTAssertTrue(failureReported)
                XCTAssertNotNil(lastResult)
                XCTAssertTrue(lastResult is String)
                XCTAssertEqual((lastResult as! String), res1)
                
                //===
                
                print("CaseWithErrorAndRepeat - DONE")
                
                //===
                
                // this error block has been executed as expected
                
                expectation.fulfill()
            }
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithErrorAndDefault()
    {
        let expectation =
            expectationWithDescription("CaseWithErrorAndDefault Sequence")
        
        //===
        
        Sequence()
            .add { (_, previousResult: Any?) -> Any? in
                
                throw TestError.One
            }
            .onFailure({ (_, error) -> Void in
                
                XCTAssertTrue(error is TestError)
                
                switch error
                {
                    case TestError.One:
                        XCTAssert(true)
                        
                    default:
                        XCTAssert(false, "Received wrong error type")
                }
                
                //===
                
                print("CaseWithError - FAILURE REPORTED")
                
                //===
                
                expectation.fulfill()
            })
            .start()
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithBegin()
    {
        let expectation =
            expectationWithDescription("CaseWithBegin Sequence")
        
        //===
        
        let res0 = "CaseWithBegin - input"
        
        //===
        
        let seq = Sequence()
        
        seq.beginWith { () -> Any? in
            
            return res0
        }
        
        seq.add { (_, previousResult: String?) -> Any? in
            
            XCTAssertEqual(res0, previousResult)
            
            //===
            
            for i in 0...1000
            {
                print("CaseWithBegin task 1, step \(i)")
            }
            
            //===
            
            return nil
        }
        
        seq.finally { (_, previousResult: Any?) in
            
            expectation.fulfill()
        }
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithBegin2()
    {
        let expectation =
            expectationWithDescription("CaseWithBegin2 Sequence")
        
        //===
        
        let res0 = "CaseWithBegin2 - input"
        
        //===
        
        let seq = Sequence()
        
        seq.input(res0)
        
        seq.add { (_, previousResult: String?) -> Any? in
            
            XCTAssertEqual(res0, previousResult)
            
            //===
            
            for i in 0...1000
            {
                print("CaseWithBegin2 task 1, step \(i)")
            }
            
            //===
            
            return nil
        }
        
        seq.finally { (_, previousResult: Any?) in
            
            expectation.fulfill()
        }
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
