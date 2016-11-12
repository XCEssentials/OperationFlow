MKHOperationFlow
=============

Lightweight async serial operation flow controller.

Swift vs. Objective-C
---

Note, that this description is valid for version 2.*, which is done in Swift. If you are looking for an Objective-C implementation and documentation, see tag/release [1.0.3][0].


Inspiration
---

This library has been inspired by [PromiseKit][1], [Objective-Chain][2] and [ReactiveCocoa][3].


The Goal
---

A tool for simple and elegant management of operations flow that are being executed **serially** on a background queue with shared (among all operations) error handler and completion handler being called on main queue after all operations have been executed and completed successfully.


How It Works?
---

`OperationFlow` class implements generic queue-based (FIFO) set of operations that are supposed to be executed one-by-one. Each operation is represented by a [closure][4] which is being executed on the target queue. You can add as many operations to the flow as you need, but at least one operation is expected to make use of this class meaningful. Each operation should expect to receive output of previous operation as _input_ parameter. The very first operation gets no input parameter, unless the flow has been set with input value before chaining first operation.

Any operation flow might be provided with **final** (completion) operation which will be called when all operations have completed successfully. Completion block is always being called on main queue. If you do not need completion block - feel free to just call `start()` instead of `finally(...)`.

Operation flow also might be configured with custom **error** handling block which will be called (with error as input parameter) if _ANY_ of the operations in the flow has failed. To indicate failure, operation must `throw` an instance of _Error_. In this case, the flow will not execute next operation (as well as final/completion block). Instead it will call error handling block (if provided) and stop execution after that. Error handling block is always being called on main queue.

NOTE: Each operation in flow may be also called _step_.

Key Features
---

Here are some key features that makes this library different from the others.

### Lightweight syntax

Easy to use, minimal syntax. Minimum params have to be provided per each call to simplify usage and increase readability.

### Code completion

This library does not use block-return class methods or run time "magic", so in Xcode you have full code-completion support.

### Independent target queue per each flow

The target queue (where all operations of that given flow will be executed one by one) can be set for each flow independently from other flows.

NOTE: The flow target queue is automatically being set to global default value, so no need to set target queue for each particular flow explicitly. In turn, global default target queue is being set automatically to a dedicated background seriall queue. See `FlowDefaults` for more details.

### Pass result value between steps

Each operation in a flow returns a value. This value is considered as result (_output_) of this operation and will be passed to next operation as _input_ parameter. Output of the last operation in the flow will be passed as input parameter of the completion block.

### Operates via main queue

Each flow manages its execution on main queue, i.e. every step is being executed on target queue, but flow passes results from previous operation to next one and controls execution via main queue.

### Completion block

When all operations from the flow have been _successfully_ completed, completion block will be called with output value of the very last operation in the flow. 

### Shared error handling block

Each flow can be configured with shared error handling block which will be called (with error as input parameter) if _ANY_ of the operations in the flow has indicated execution failure.

### Cancellable

The flow might be cancelled at any time. If cancelled, flow won't force to stop current operation execution immediately, but will NOT proceed to next operation or completion block.

How to add to your project
---

Just import module "MKHOperationFlow" like this:

```swift
import MKHOperationFlow
```

How To Use
---

Please, see [unit tests][5] to get an idea of how to use `OperationFlow` class.

Swift 3
---

Starting from [version 3.0][6], this library supports Swift 3. For compatibility with Swift 2.2 and Swift 2.3 use [older version][7].


[0]: https://github.com/maximkhatskevich/MKHOperationFlow/releases/tag/1.0.3
[1]: http://promisekit.org
[2]: https://github.com/iMartinKiss/Objective-Chain
[3]: https://github.com/ReactiveCocoa/ReactiveCocoa
[4]: https://www.google.ru/search?q=swift+closure
[5]: https://github.com/maximkhatskevich/MKHOperationFlow/blob/master/Tst/Main.swift
[6]: https://github.com/maximkhatskevich/MKHOperationFlow/releases/tag/3.0.0
[7]: https://github.com/maximkhatskevich/MKHOperationFlow/releases/tag/2.6.3

