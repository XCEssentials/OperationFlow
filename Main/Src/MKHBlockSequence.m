//
//  MKHBlockSequence.m
//  BlockSequence
//
//  Created by Maxim Khatskevich on 02/12/14.
//  Copyright (c) 2014 Maxim Khatskevich. All rights reserved.
//

#import "MKHBlockSequence.h"

//#import "MacrosBase.h"
//#import <CocoaTouchHelpers/NSObject+Helpers.h>
//#import <CocoaTouchHelpers/NSMutableArray+Helpers.h>

//===

static __weak NSOperationQueue *__defaultQueue;
static MKHSequenceErrorBlock __defaultErrorBlock;

//===

@interface MKHBlockSequence ()

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSBlockOperation *currentOperation;

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) id selfLink;

@property (copy, nonatomic) MKHSequenceCompletionBlock completionBlock;
@property (copy, nonatomic) MKHSequenceErrorBlock errorBlock;

@end

//===

@implementation MKHBlockSequence

#pragma mark - Overrided methods

+ (void)initialize
{
    [super initialize];
    
    //===
    
    [self setDefaultQueue:[NSOperationQueue currentQueue]];
    [self setDefaultErrorHandler:nil];
}

- (instancetype)init
{
    self = [super init];
    
    //===
    
    if (self)
    {
        self.targetQueue = __defaultQueue;
        
        //===
        
        if (__defaultErrorBlock)
        {
            self.errorBlock = __defaultErrorBlock;
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            
            [self
             setErrorBlock:^(NSError *error) {
                 
                 NSLog(@"Sequence named >> %@ << error: %@",
                       weakSelf.name,
                       error);
             }];
        }
        
        //===
        
        self.items = [NSMutableArray array];
    }
    
    //===
    
    return self;
}

#pragma mark - Global

+ (void)setDefaultQueue:(NSOperationQueue *)defaultQueue
{
    __defaultQueue = defaultQueue;
}

+ (void)setDefaultErrorHandler:(MKHSequenceErrorBlock)defaultErrorBlock
{
    __defaultErrorBlock = defaultErrorBlock;
}

#pragma mark - Custom

+ (instancetype)newWithName:(NSString *)sequenceName
{
    MKHBlockSequence *result = self.class.new;
    
    //===
    
    result.name = sequenceName;
    
    //===
    
    return result;
}

+ (instancetype)execute:(MKHSequenceInitialBlock)firstOperation
{
    return
    [self.class.new
     then:^(id object) {
         
         id result = nil;
         
         //===
         
         if (firstOperation)
         {
             result = firstOperation();
         }
         
         //===
         
         return result;
     }];
}

- (instancetype)then:(MKHSequenceGenericBlock)operation
{
    // [self.items safeAddObject:operation];
    
    if (operation)
    {
        [self.items addObject:operation];
    }
    
    //===
    
    return self;
}

- (instancetype)finally:(MKHSequenceCompletionBlock)completion
{
    self.completionBlock = completion;
    
    //===
    
    if (self.items.count)
    {
        self.selfLink = self;
    }
    
    //===
    
    [self start];
    
    //===
    
    return self;
}

- (instancetype)errorHandler:(MKHSequenceErrorBlock)errorHandling
{
    self.errorBlock = errorHandling;
    
    //===
    
    return self;
}

- (void)cancel
{
    [self.currentOperation cancel];
}

#pragma mark - Internal

- (void)start
{
    // make sure we start sequence on main queue:
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.items.count)
        {
            [self executeNextWithObject:nil];
        }
    });
}

- (void)executeNextWithObject:(id)previousResult
{
    // NOTE: this mehtod is supposed to be called on main queue
    
    if (self.items.count)
    {
        // regular block
        
        if (self.targetQueue)
        {
            MKHSequenceGenericBlock block = [self.items objectAtIndex:0];
            [self.items removeObjectAtIndex:0];
            
            //===
            
            __weak NSBlockOperation *thisOperation = nil;
            thisOperation = self.currentOperation = [NSBlockOperation new];
            
            [thisOperation
             addExecutionBlock:^{
                 
                 id result = block(previousResult);
                 
                 //===
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     self.currentOperation = nil;
                     
                     //===
                     
                     if (thisOperation.isCancelled)
                     {
                         [self releaseSelf];
                     }
                     else
                     {
                         // return
                         
                         if ([result isKindOfClass:NSError.class])
                         {
                             [self reportError:result];
                         }
                         else
                         {
                             [self executeNextWithObject:result];
                         }
                     }
                 });
             }];
            
            //===
            
            [self.targetQueue addOperation:thisOperation];
        }
        else
        {
            NSLog(@"WARNING: Can't execute block sequence, .targetQueue hasn't been set.");
            
            [self releaseSelf];
        }
    }
    else
    {
        [self completeWithResult:previousResult];
    }
}

- (void)completeWithResult:(id)lastResult
{
    if (self.completionBlock)
    {
        // final block
        // run on main queue
        
        self.completionBlock(lastResult);
    }
    
    //===
    
    [self releaseSelf];
}

- (void)reportError:(NSError *)error
{
    if (self.errorBlock)
    {
        // error block
        // run on main queue
        
        self.errorBlock(error);
    }
    
    //===
    
    [self releaseSelf];
}

- (void)releaseSelf
{
    self.selfLink = nil;
}

@end
