//
//  MKHSequenceTests.swift
//  MKHSequenceTests
//
//  Created by Maxim Khatskevich on 11/26/15.
//  Copyright © 2015 Maxim Khatskevich. All rights reserved.
//

import XCTest
@testable import MKHSequence

class MKHSequenceTests: XCTestCase
{
    // MARK: Properties - Static
    
    var queue = NSOperationQueue()
    
    // MARK: Tests
    
    func testSimpleCase()
    {
        // how we test async calls: http://stackoverflow.com/a/24705283
        
        //===
        
        let expectation = self.expectationWithDescription("SimpleCase Sequence")
        
        //===
        
        MKHSequence.setDefaultTargetQueue(queue)
        
        //===
        
        let seq = MKHSequence()
        
        seq.add { (previousResult) -> Any? in
            
            // previousResult is nil
            
            for i in 0...1000
            {
                print("SimpleCase task 1, step \(i)")
            }
            
            //===
            
            return "SimpleCase - 1st result"
        }
        
        seq.add { (previousResult) -> Any? in
            
            // previousResult is: "1st result"
            
            //===
            
            for i in 0...10000
            {
                print("SimpleCase task 2, step \(i)")
            }
            
            //===
            
            return "SimpleCase - 2nd result"
        }
        
        seq.finally { (previousResult) -> Void in
            
            // previousResult is: "2nd result"
            
            print("SimpleCase - DONE")
            
            XCTAssert(true, "Pass")
            expectation.fulfill()
        }
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithError()
    {
        let expectation = self.expectationWithDescription("CaseWithError Sequence")
        
        //===
        
        MKHSequence.setDefaultTargetQueue(queue)
        
        //===
        
        MKHSequence()
            .add { (previousResult) -> Any? in
                
                // previousResult is nil
                
                for i in 0...1000
                {
                    print("CaseWithError task 1, step \(i)")
                }
                
                //===
                
                return "CaseWithError - 1st result"
            }
            .add { (previousResult) -> Any? in
            
                // previousResult is: "1st result"
                
                //===
                
                for i in 0...10000
                {
                    print("CaseWithError task 2, step \(i)")
                }
                
                //===
                
                // lets return error here
                
                return
                    NSError(domain: "MKHSmapleError",
                        code: 500,
                        userInfo: ["reason": "Just for test",
                            "origin": "CaseWithError, task 2"])
            }
            .onFailure({ (error) -> Void in
                
                print("An error occured: \(error)")
                
                //===
                
                XCTAssert(true, "Pass")
                expectation.fulfill()
            })
            .start()
        
        //===
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testCaseWithCancel()
    {
        let expectation = self.expectationWithDescription("CaseWithCancel Sequence")
        
        //===
        
        MKHSequence.setDefaultTargetQueue(queue)
        
        //===
        
        let seq = MKHSequence()
            .add { (previousResult) -> Any? in
                
                // previousResult is nil
                
                for i in 0...10000
                {

                    print("CaseWithCancel task 1, step \(i)")
                }
                
                //===
                
                return "CaseWithCancel - 2st result"
            }
            .start()
        
        //===
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
            print("About to cancel sequence")
            
            seq.cancel()
            
            XCTAssert(true, "Pass")
            expectation.fulfill()
        }
        
        //===
        
        print("Starting to wait for expectation.")
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
