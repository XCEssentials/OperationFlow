BlockSequence
=============

Lightweight implementation of async operations sequence controller.


Inspiration
---

This lib has been inspired by [PromiseKit][0], [Objective-Chain][1] and [ReactiveCocoa][2].


The Goal
---

A tool for easy and elegant control of **serial** sequence of (background) operations with shared error handling and completion blocks.


How It Works?
---

_BlockSequence_ class implements generic queue-based (FIFO) collection of operations that are supposed to be executed one-by-one. Each operation is represented by a [block][3] which is being executed on the sequence target queue. You can add as many operations to a sequence as you need, but at least one operation is needed to make the use of this class meaningful. Each operation should expect to get previous operation result as input parameter (expect the very first operation where input parameter is always `nil`).

Any sequence might be provided with **final** (completion) block which will be called when all other operations have completed successfully. Final block is always being called on main queue. If you do not need completion block - feel free to pass `nil` instead.

Sequence also might be configured with custom **error** handling block which will be called (with error as input parameter) if _ANY_ of the operations in the sequence has failed. To indicate failure, a block must return an instance of _NSError_ class. In this case, the sequence will not call next block (or even final block). Instead it will call sequence error handling block and stop execution after that. Error handling block is always being called on main queue.

NOTE: Each operation in a sequence may be also called _step_ or _block_ (because each operation is being passed to a sequence as a block).


Key Features
---

Here are some key features that makes this library different from the others.

### Lightweight syntax

Easy to use, minimal syntax. Minimum params have to be provided per each call to simplify usage and increase readability.

### Code completion

This library does not use block-return class methods and "dot-based" syntax, so when you are in Xcode - you have full code-completion support.

### Independent target queue per sequence

The target queue (where all the operations of that given sequence will be executed one by one) can be set for each sequence independently from other sequences.

NOTE: The sequence target queue is automatically being set to global default value, so no need to setup target queue for each particular sequence explicitly. In turn, global default target queue is being set automatically to _current queue_, i.e. to the queue where sequence class has been used first time. It is **recommended** to setup global default target queue to a custom background queue explicitly before you start using sequences.

### Pass result value between steps

Each block in a sequence returns an _id_ object. This object is considered as a result of this step and will be passed to next block as input parameter.

### Operates via main queue

Each sequence controls its flow on main queue, i.e. every step is being executed on target queue, but sequence passes results from previous block to next one and controls the flow via main queue.

### Completion block

When all operations that have been added to the sequence have been _successfully_ completed, the sequence will call completion method with result of the very last operation in the sequence. 

### Shared error handling block

Each sequence can be configured with custom error handling block which will be called (with error as input parameter) if _ANY_ of the operations in the sequence has failed.

### Cancellable

Any sequence might be cancelled at any time. If cancelled, sequence won't stop current operation execution immediately, but will NOT proceed to next operation and release itself.


How To Use
---

Here is a simple usage example.

```objective-c
NSOperationQueue *theQueue = ...; // store an NSOperationQueue somewhere

//===

[MKHBlockSequence setDefaultQueue:theQueue];

//===

MKHBlockSequence *sequence =
[MKHBlockSequence newWithName:@"MyTestSequence"]; // name is needed for debugging only
    
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
     
     //===
     
     for (int i = 0; i<10000; i++)
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
     
     NSLog(@"DONE");
 }];
```

Here is a more advanced usage example.

```objective-c
NSOperationQueue *theQueue = ...; // store an NSOperationQueue somewhere
    
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
```


[0]: http://promisekit.org
[1]: https://github.com/iMartinKiss/Objective-Chain
[2]: https://github.com/ReactiveCocoa/ReactiveCocoa
[3]: https://www.google.ru/search?q=objective+c+block


