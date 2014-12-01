//
//  MKHBlockSequenceTests.m
//  BlockSequence
//
//  Created by Maxim Khatskevich on 02/12/14.
//  Copyright (c) 2014 Maxim Khatskevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BlockSequence.h"

//===

@interface MKHBlockSequenceTests : XCTestCase

@end

//===

@implementation MKHBlockSequenceTests

- (void)setUp
{
    [super setUp];
    
    //===
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testUsage
{
    NSOperationQueue *theQueue = [NSOperationQueue new];
    
    //===
    
    [MKHBlockSequence setDefaultQueue:theQueue];
    
    //===
    
    MKHBlockSequence *sequence =
    [MKHBlockSequence newWithName:@"MyTestSequence"]; // name is needed for debugging only
    
    // alternatively you can use 'MKHNewSequence' macro for quick temp var definition
    
    [sequence
     then:^id(id object) {
         
         NSLog(@"Input: %@", object);
         
         for (int i = 0; i<1000; i++)
         {
             NSLog(@"Long operation");
         }
         
         // [promise cancel];
         
         //===
         
         return @"1st result";
     }];
    
    [sequence
     then:^id(id object) {
         
         NSAssert([object isEqual:@"1st result"],
                  @"Incorrect previous result");
         
         //===
         
         NSLog(@"Input: %@", object);
         
         for (int i = 0; i<10000; i++)
         {
             NSLog(@"Another Long operation");
         }
         
         //===
         
         return @"2nd result";
     }];
    
    [sequence
     finally:^(id lastResult) {
         
         NSAssert([lastResult isEqual:@"2nd result"],
                  @"Incorrect previous result");
         
         //===
         
         NSLog(@"Input: %@", lastResult);
         NSLog(@"DONE");
     }];
}

- (void)testAnotherUseageExample
{
    NSOperationQueue *theQueue = [NSOperationQueue new];
    
    //===
    
    [MKHBlockSequence setDefaultQueue:theQueue];
    
    //===
    
    [[[[MKHBlockSequence
        execute:^id{
            
            for (int i = 0; i<1000; i++)
            {
                NSLog(@"Long operation");
            }
            
            //===
            
            return @"1st result";
        }]
       then:^id(id previousResult) {
           
           // object is: "1st result"
           
           //===
           
           for (int i = 0; i<10000; i++)
           {
               NSLog(@"Another Long operation");
           }
           
           //===
           
           return @"2nd result";
       }]
      errorHandler:^(NSError *error) {
          
          // handle error
          // show an alert and so on...
      }]
     finally:^(id lastResult) {
         
         // object is: "2nd result"
         
         NSLog(@"DONE");
     }];
}

@end
