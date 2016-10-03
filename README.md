MKHSequence
=============

Lightweight async operations controller.

Swift vs. Objective-C
---

Note, that this description is valid for version 2.x, which is done in Swift 2.0. If you are looking for an Objective-C implementation and documentation, see tag/release [1.0.3][0].


Inspiration
---

This library has been inspired by [PromiseKit][1], [Objective-Chain][2] and [ReactiveCocoa][3].


The Goal
---

A tool for simple and elegant management of sequence of tasks that are being executed **serially** on a background queue with shared (among all tasks) error handler and completion handler being called on main queue after all tasks have been executed and completed successfully.


How It Works?
---

_Sequence_ class implements generic queue-based (FIFO) collection of tasks that are supposed to be executed one-by-one. Each task is represented by a [block][4] which is being executed on the sequence target queue. You can add as many tasks to a sequence as you need, but at least one task is expected to make use of this class meaningful. Each task should expect to receive result from  previous task as input parameter (expect the very first task where input parameter is always `nil`).

Any sequence might be provided with **final** (completion) block which will be called when all tasks have completed successfully. Completion block is always being called on main queue. If you do not need completion block - feel free to just call `start()` instead.

Sequence also might be configured with custom **error** handling block which will be called (with error as input parameter) if _ANY_ of the tasks in the sequence has failed. To indicate failure, a task must return an instance of _NSError_ class. In this case, the sequence will not call next task (or final/completion block). Instead it will call sequence error handling block and stop execution after that. Error handling block is always being called on main queue.

NOTE: Each task in a sequence may be also called _step_.

Key Features
---

Here are some key features that makes this library different from the others.

### Lightweight syntax

Easy to use, minimal syntax. Minimum params have to be provided per each call to simplify usage and increase readability.

### Code completion

This library does not use block-return class methods or run time "magic", so in Xcode you have full code-completion support.

### Independent target queue per each sequence

The target queue (where all tasks of that given sequence will be executed one by one) can be set for each sequence independently from other sequences.

NOTE: The sequence target queue is automatically being set to global default value, so no need to setup target queue for each particular sequence explicitly. In turn, global default target queue is being set automatically to _current queue_, i.e. to the queue where sequence class has been used first time. It is **recommended** to setup global default target queue to a custom background serial queue explicitly before you start using Sequence class.

### Pass result value between steps

Each task in a sequence returns an _Any?_ value. This object is considered as a result of this step and will be passed to next task as input parameter.

### Operates via main queue

Each sequence manages its flow on main queue, i.e. every step is being executed on target queue, but sequence passes results from previous task to next one and controls the flow via main queue.

### Completion block

When all tasks from the sequence have been _successfully_ completed, the sequence will call completion block with result of the very last task in the sequence. 

### Shared error handling block

Each sequence can be configured with shared error handling block which will be called (with error as input parameter) if _ANY_ of the tasks in the sequence has indicated execution failure.

### Cancellable

Any sequence might be cancelled at any time. If cancelled, sequence won't force to stop current task execution immediately, but will NOT proceed to next task or completion block.

How to add to your project
---

Just import module "MKHSequence" like this:

```swift
import MKHSequence
```

How To Use
---

Please, see [unit tests][5] to get an idea of how to use Sequence class.

Swift 3
---

Starting from [version 0.7.0](https://github.com/maximkhatskevich/MKHSequence/releases/tag/7.0.0), this library supports Swift 3. For compatibility with Swift 2.2 and Swift 2.3 use [older version](https://github.com/maximkhatskevich/MKHSequence/releases/tag/2.6.3).


[0]: https://github.com/maximkhatskevich/MKHSequence/releases/tag/1.0.3
[1]: http://promisekit.org
[2]: https://github.com/iMartinKiss/Objective-Chain
[3]: https://github.com/ReactiveCocoa/ReactiveCocoa
[4]: https://www.google.ru/search?q=objective+c+block
[5]: https://github.com/maximkhatskevich/MKHSequence/blob/master/Framework/iOS/MKHSequenceTests/MKHSequenceTests.swift

