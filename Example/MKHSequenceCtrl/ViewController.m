//
//  ViewController.m
//  MKHSequenceCtrl
//
//  Created by Maxim Khatskevich on 23/03/15.
//  Copyright (c) 2015 Maxim Khatsevich. All rights reserved.
//

#import "ViewController.h"

#import "MKHSequenceCtrl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //===
    
    [self simpleExample];
    [self anotherExample];
}

- (void)simpleExample
{
    static NSOperationQueue *theQueue;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        theQueue = [NSOperationQueue new];
    });
    
    //===
    
    [MKHSequenceCtrl setDefaultQueue:theQueue];
    
    //===
    
    MKHSequenceCtrl *sequence =
    [MKHSequenceCtrl newWithName:@"MyTestSequence"]; // name is needed for debugging only
    
    // alternatively you can use 'MKHNewSequence' macro for quick temp var definition
    
    // add some operation:
    [sequence
     then:^id(id object) {
         
         // object is nil
         
         for (int i = 0; i<1000; i++)
         {
             NSLog(@"Long operation");
         }
         
         //===
         
         return @"1st result";
     }];
    
    // add another operation:
    [sequence
     then:^id(id object) {
         
         // object is: "1st result"
         
         NSLog(@"========= object is: %@", object);
         
         //===
         
         for (int i = 0; i<1000; i++)
         {
             NSLog(@"Another Long operation");
         }
         
         //===
         
         return @"2nd result";
     }];
    
    // call 'finally:' method with completion block (may be nil)
    // to actually start sequence execution:
    [sequence
     finally:^(id object) {
         
         // object is: "2nd result"
         
         NSLog(@"========= object is: %@", object);
         
         NSLog(@"DONE");
     }];
}

- (void)anotherExample
{
    static NSOperationQueue *theAnotherQueue;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        theAnotherQueue = [NSOperationQueue new];
    });
    
    //===
    
    [MKHSequenceCtrl setDefaultQueue:theAnotherQueue];
    
    //===
    
    [[[[MKHSequenceCtrl
        execute:^id{
            
            for (int i = 0; i<1000; i++)
            {
                NSLog(@"Long operation again");
            }
            
            //===
            
            return @"1st result";
        }]
       then:^id(id previousResult) {
           
           // object is: "1st result"
           
           NSLog(@"========= object is: %@", previousResult);
           
           //===
           
           for (int i = 0; i<1000; i++)
           {
               NSLog(@"Another Long operation again");
           }
           
           //===
           
           return [NSError errorWithDomain:@"Sequence error" code:1 userInfo:nil];
       }]
      errorHandler:^(NSError *error) {
          
          // handle error
          // show an alert and so on...
         
          NSLog(@"ERROR: %@!", error.domain);
      }]
     finally:^(id lastResult) {
         
         // object is: "2nd result"
         
         NSLog(@"========= object is: %@", lastResult);
         
         NSLog(@"DONE again"); // this will never print out, because we return an error in the second block
     }];
}

@end
