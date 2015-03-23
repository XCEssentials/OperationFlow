//
//  MKHSequenceCtrl.h
//  MKHSequenceCtrl
//
//  Created by Maxim Khatskevich on 02/12/14.
//  Copyright (c) 2014 Maxim Khatskevich. All rights reserved.
//

#import <Foundation/Foundation.h>

//===

#define MKHNewSequence MKHSequenceCtrl *sequence = [MKHSequenceCtrl new]

//===

typedef id (^MKHSequenceInitialBlock)(void);
typedef id (^MKHSequenceGenericBlock)(id previousResult);
typedef void (^MKHSequenceCompletionBlock)(id lastResult);
typedef void (^MKHSequenceErrorBlock)(NSError *error);

//===

@interface MKHSequenceCtrl : NSObject

@property (weak, nonatomic) NSOperationQueue *targetQueue;

+ (void)setDefaultQueue:(NSOperationQueue *)defaultQueue;
+ (void)setDefaultErrorHandler:(MKHSequenceErrorBlock)defaultErrorBlock;

+ (instancetype)newWithName:(NSString *)sequenceName;
+ (instancetype)execute:(MKHSequenceInitialBlock)firstOperation;

- (instancetype)then:(MKHSequenceGenericBlock)operation;
- (instancetype)finally:(MKHSequenceCompletionBlock)completion;
- (instancetype)errorHandler:(MKHSequenceErrorBlock)errorHandling;

- (void)cancel;

@end
