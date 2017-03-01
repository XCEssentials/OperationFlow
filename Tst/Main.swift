//
//  Main.swift
//  MKHOperationFlowTst
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

class Main: XCTestCase
{
    func testSimpleCase()
    {
        // how we test async calls: http://stackoverflow.com/a/24705283
        
        //===
        
        let caseName = "SimpleCase"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let res1 = caseName + " - 1st result"
        let res2 = caseName + " - 2nd result"
        
        var task1Completed = false
        var task2Completed = false
        
        //===
        
        let firstBlock: OFL.OperationNoInput<String> = {
        
            XCTAssertFalse(task1Completed)
            XCTAssertFalse(task2Completed)
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            for i in 0...1000
            {
                print(caseName + " task 1, step \(i)")
            }
            
            task1Completed = true
            
            //===
            
            return res1
        }
        
        let secondBlock = { (input: String) -> String in
        
            XCTAssertTrue(task1Completed)
            XCTAssertFalse(task2Completed)
            XCTAssertEqual(input, res1)
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            for i in 0...10000
            {
                print(caseName + " task 2, step \(i)")
            }
            
            task2Completed = true
            
            //===
            
            return res2
        }
        
        let finalBlock = { (input: String) in
        
            XCTAssertTrue(task1Completed)
            XCTAssertTrue(task2Completed)
            XCTAssertEqual(input, res2)
            XCTAssertEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            print(caseName + " - DONE")
            
            //===
            
            // this sequence has been completed as expected
            
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName)
            .first(firstBlock)
            .then(secondBlock)
            .finally(finalBlock)
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithError()
    {
        let caseName = "CaseWithError"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let res1 = caseName + " - 1st result"
        let errCode = 1231481 // just random number
        
        var task1Completed = false
        
        //===
        
        let firstBlock = { () -> String in
            
            XCTAssertFalse(task1Completed)
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            for i in 0...1000
            {
                print(caseName + " task 1, step \(i)")
            }
            
            task1Completed = true
            
            //===
            
            return res1
        }
        
        let secondBlock = { (input: String) -> String in
        
            XCTAssertTrue(task1Completed)
            XCTAssertEqual(input, res1)
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            for i in 0...10000
            {
                print(caseName + " task 2, step \(i)")
            }
            
            //===
            
            // lets return error here
            
            throw TestError.two(code: errCode)
        }
        
        let failureBlock: OFL.FailureGeneric = { _, error, _ in
            
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
            
            print(caseName + " - FAILURE REPORTED")
            
            //===
            
            // this error block has been executed as expected
            
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName, maxRetries: 0)
            .first(firstBlock)
            .then(secondBlock)
            .onFailure(failureBlock)
            .start()
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithCancel()
    {
        let caseName = "CaseWithCancel"
        
        //===
        
        let res1 = caseName + " - 1st result"
        
        var task1Started = false
        var task1Completed = false
        
        //===
        
        let firstBlock = { (flow: OFL.ActiveProxy) -> String in
        
            XCTAssertFalse(task1Started)
            XCTAssertFalse(task1Completed)
            XCTAssertNotEqual(OperationQueue.current, OperationQueue.main)
            
            //===
            
            task1Started = true
            
            //===
            
            OperationQueue
                .main
                .addOperation {
                    
                    XCTAssertTrue(task1Started)
                    XCTAssertFalse(task1Completed)
                    
                    //===
                    
                    do
                    {
                        try flow.cancel()
                    }
                    catch
                    {
                        XCTAssert(error is OperationFlowError)
                    }
                }
            
            //===
            
            for i in 0...10000
            {
                
                print(caseName + " task 1, step \(i)")
            }
            
            task1Completed = true
            
            //===
            
            return res1
        }
        
        let finalBlock = { (_: String) in
         
            XCTAssert(false, "This blok should NOT be called ever.")
        }
        
        //===
        
        OperationFlow
            .new(caseName)
            .first(firstBlock)
            .finally(finalBlock)
        
        //===
        
        // make sure the sequence has not started execution yet
        
        XCTAssertFalse(task1Started)
        XCTAssertFalse(task1Completed)
    }
    
    func testCaseWithErrorAndRepeat()
    {
        let caseName = "CaseWithErrorAndRepeat"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let res1 = caseName + " - 1st result"
        let errCode = 1231481 // just random number
        
        var failureReported = false
        var shouldReportFailure = true
        
        //===
        
        let firstBlock = { () -> String in
            
            for i in 0...1000
            {
                print(caseName + " task 1, step \(i)")
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
        
        let failureBlock: OFL.FailureGeneric = { _, error, _ in
           
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
        }
        
        let finalBlock = { (input: String) in
            
            XCTAssertTrue(failureReported)
            XCTAssertEqual(input, res1)
            
            //===
            
            print(caseName + " - DONE")
            
            //===
            
            // this error block has been executed as expected
            
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName, maxRetries: 1)
            .first(firstBlock)
            .onFailure(failureBlock)
            .finally(finalBlock)
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithErrorAndDefault()
    {
        let caseName = "CaseWithErrorAndDefault"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let firstBlock = { () throws -> String in
        
            throw TestError.one
        }
        
        let failureBlock: OFL.FailureGeneric = { _, error, shouldRetry in
        
            XCTAssertTrue(error is TestError)
            
            switch error
            {
                case TestError.one:
                    XCTAssert(true)
                    
                default:
                    XCTAssert(false, "Received wrong error type")
            }
            
            //===
            
            print(caseName + " - FAILURE REPORTED")
            
            //===
            
            shouldRetry = false // because default retries == 3
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName)
            .first(firstBlock)
            .onFailure(failureBlock)
            .start()
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithInput()
    {
        let caseName = "CaseWithInput"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let res0 = caseName + " - input"
        
        //===
        
        let firstBlock = { (input: String) throws in
        
            XCTAssertEqual(res0, input)
            
            //===
            
            for i in 0...1000
            {
                print(caseName + " task 1, step \(i)")
            }
        }
        
        let finalBlock = { () in
            
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName)
            .take(res0)
            .first(firstBlock)
            .finally(finalBlock)
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testCaseWithInput2()
    {
        let caseName = "CaseWithInput2"
        
        let expectation =
            self.expectation(description: caseName)
        
        //===
        
        let res0 = caseName + " - input"
        
        //===
        
        let firstBlock = { (input: String) in
            
            XCTAssertEqual(res0, input)
            
            //===
            
            for i in 0...1000
            {
                print(caseName + " task 1, step \(i)")
            }
        }
        
        let finalBlock = {
            
            expectation.fulfill()
        }
        
        //===
        
        OperationFlow
            .new(caseName)
            .take(res0)
            .first(firstBlock)
            .finally(finalBlock)
        
        //===
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
