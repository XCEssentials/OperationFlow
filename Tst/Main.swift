//
//  Main.swift
//  MKHSequenceTst
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import XCTest

//@testable
import MKHOperationFlow

//===

enum TestError: Error
{
    case one, two(code: Int)
}

//===

class MKHOperationFlowTst: XCTestCase
{
    func testSimpleCase()
    {
        // how we test async calls: http://stackoverflow.com/a/24705283
        
        //===
        
        let expectation =
            self.expectation(description: "SimpleCase Sequence")
        
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
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
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
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
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
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            print("SimpleCase - DONE")
            
            //===
            
            // this sequence has been completed as expected
            
            expectation.fulfill()
        }
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithError()
    {
        let expectation =
            self.expectation(description: "CaseWithError Sequence")
        
        //===
        
        let res1 = "CaseWithError - 1st result"
        let errCode = 1231481 // just random number
        
        var task1Completed = false
        
        //===
        
        Sequence()
            .add { (_, previousResult: Any?) -> Any? in
                
                XCTAssertFalse(task1Completed)
                XCTAssertNil(previousResult)
                XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
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
                XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
                
                //===
                
                for i in 0...10000
                {
                    print("CaseWithError task 2, step \(i)")
                }
                
                //===
                
                // lets return error here
                
                throw TestError.two(code: errCode)
            }
            .onFailure({ (_, error) -> Void in
                
                XCTAssertTrue(task1Completed)
                XCTAssertEqual(OperationQueue.current, OperationQueue.main)
                
                //===
                
                XCTAssertTrue(error is TestError)
                
                switch error
                {
                    case TestError.two(let code):
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
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
                XCTAssertNotEqual(sequence.status, Sequence.Status.cancelled)
                XCTAssertNil(previousResult)
                XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
                
                //===
                
                task1Started = true
                
                //===
                
                OperationQueue
                    .main
                    .addOperation {
                        
                        XCTAssertTrue(task1Started)
                        XCTAssertFalse(task1Completed)
                        XCTAssertNotEqual(sequence.status, Sequence.Status.cancelled)
                        
                        //===
                        
                        sequence.cancel()
                        
                        //===
                        
                        XCTAssertEqual(sequence.status, Sequence.Status.cancelled)
                    }
                
                //===
                
                for i in 0...10000
                {

                    print("CaseWithCancel task 1, step \(i)")
                }
                
                task1Completed = true
                
                //===
                
                XCTAssertEqual(sequence.status, Sequence.Status.cancelled)
                
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
            self.expectation(description: "CaseWithErrorAndRepeat Sequence")
        
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
                    throw TestError.two(code: errCode)
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
                    case TestError.two(let code):
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithErrorAndDefault()
    {
        let expectation =
            self.expectation(description: "CaseWithErrorAndDefault Sequence")
        
        //===
        
        Sequence()
            .add { (_, previousResult: Any?) -> Any? in
                
                throw TestError.one
            }
            .onFailure({ (_, error) -> Void in
                
                XCTAssertTrue(error is TestError)
                
                switch error
                {
                    case TestError.one:
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithBegin()
    {
        let expectation =
            self.expectation(description: "CaseWithBegin Sequence")
        
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithBegin2()
    {
        let expectation =
            self.expectation(description: "CaseWithBegin2 Sequence")
        
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
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
