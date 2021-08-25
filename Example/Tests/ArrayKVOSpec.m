//
//  ArrayKVOSpec.m
//  JKKVOHelper
//
//  Created by JackLee on 2021/8/25.
//  Copyright 2021 xindizhiyin2014. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <JKKVOHelper/JKKVOHelper.h>
#import <JKKVOHelper/JKKVOItemManager.h>
#import "JKTeacher.h"
#import "JKWorker.h"



SPEC_BEGIN(ArrayKVOSpec)

describe(@"ArrayKVO", ^{
    context(@"array action", ^{
        it(@"init", ^{
            JKTeacher *teacher = [JKTeacher new];
            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                invoked = YES;

            }];
            teacher.students = @[].mutableCopy;
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];

        });

        it(@"jk_addObject", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:1];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddTail)];
                [[changedModel.changedElements.firstObject.object should] equal:person1];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(0)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];
            [students kvo_addObject:person1];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

        it(@"jk_addObject, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            __block BOOL invoked = NO;
            [students kvo_addObject:person1];
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:1];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeElement)];
                [[changedModel.changedElements.firstObject.object should] equal:person1];
                invoked = YES;
            }];
            person1.name = @"person1";

            [[theValue(invoked) shouldEventually] beYes];

            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

        it(@"jk_insertObject:atIndex:", ^{
           JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:3];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddAtIndex)];
                [[changedModel.changedElements should] haveCountOf:1];
                [[changedModel.changedElements.firstObject.object should] equal:person3];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(1)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];

            [students kvo_insertObject:person3 atIndex:1];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });


        it(@"jk_insertObject:atIndex:1", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:3];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddAtIndex)];
                [[changedModel.changedElements should] haveCountOf:1];
                [[changedModel.changedElements.firstObject.object should] equal:person3];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(2)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];
            [students kvo_insertObject:person3 atIndex:2];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

        it(@"jk_insertObject:atIndex:, elementKeyPaths is not nil", ^{
           JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {

                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeElement)];
                [[changedModel.changedElements should] haveCountOf:1];
                [[changedModel.changedElements.firstObject.object should] equal:person2];

                invoked = YES;
            }];
            person2.name = @"person2";
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

        it(@"jk_removeLastObject", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:2];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeRemoveTail)];
                [[changedModel.changedElements should] haveCountOf:1];
                JKPersonModel *tmpPerson = (JKPersonModel *)changedModel.changedElements.firstObject.object;
                NSLog(@"person %@",tmpPerson.name);
                [[changedModel.changedElements.firstObject.object should] equal:person3];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(2)];
                invoked = YES;
            }];
            [students kvo_removeLastObject];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

        it(@"jk_removeLastObject, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            person3.name = @"zhangsan";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            [students kvo_removeLastObject];
            [[theValue(invokedCount) shouldEventually] equal:@2];
            person3.name = @"lisi";
            [[theValue(invokedCount) shouldEventually] equal:@2];
        });

        
        it(@"jk_removeObjectAtIndex", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:2];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeRemoveAtIndex)];
                [[changedModel.changedElements should] haveCountOf:1];
                [[changedModel.changedElements.firstObject.object should] equal:person2];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(1)];
                invoked = YES;
            }];

            [students kvo_removeObjectAtIndex:1];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });
        
        it(@"jk_removeObjectAtIndex, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }]; 
            person2.name = @"person3";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            [students kvo_removeObjectAtIndex:1];
            [[theValue(invokedCount) shouldEventually] equal:@2];
            person2.name = @"lisi";
            [[theValue(invokedCount) shouldEventually] equal:@2];
        });

        it(@"jk_replaceObjectAtIndex:withObject:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:3];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeReplace)];
                [[changedModel.changedElements should] haveCountOf:2];
                [[changedModel.changedElements.lastObject.object should] equal:person4];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(2)];

                [[theValue(changedModel.changedElements.lastObject.newIndex) should] equal:theValue(2)];
                [[theValue(changedModel.changedElements.lastObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];

            [students kvo_replaceObjectAtIndex:2 withObject:person4];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });
        
        it(@"jk_replaceObjectAtIndex:withObject:, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            person3.name = @"person3";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            person4.name = @"person4";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            [students kvo_replaceObjectAtIndex:2 withObject:person4];
            [[theValue(invokedCount) shouldEventually] equal:@2];
            
            person3.name = @"zhangsan";
            [[theValue(invokedCount) shouldEventually] equal:@2];
            person4.name = @"lisi";
            [[theValue(invokedCount) shouldEventually] equal:@3];
        });

        it(@"jk_addObjectsFromArray:", ^{
          JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            JKPersonModel *person4 = [JKPersonModel new];
            NSArray *array = @[person3,person4];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:4];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddTail)];
                [[changedModel.changedElements should] haveCountOf:2];
                [[changedModel.changedElements.firstObject.object should] equal:person3];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(2)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];

                [[changedModel.changedElements.lastObject.object should] equal:person4];
                [[theValue(changedModel.changedElements.lastObject.newIndex) should] equal:theValue(3)];
                [[theValue(changedModel.changedElements.lastObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];
            [students kvo_addObjectsFromArray:array];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });
        
        it(@"jk_addObjectsFromArray:, elementKeyPaths is not nil", ^{
          JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            JKPersonModel *person4 = [JKPersonModel new];
            NSArray *array = @[person3,person4];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            person3.name = @"person3";
            [[theValue(invokedCount) shouldEventually] equal:@0];
            [students kvo_addObjectsFromArray:array];
            [[theValue(invokedCount) shouldEventually] equal:@1];
            person3.name = @"zhangsan";
            [[theValue(invokedCount) shouldEventually] equal:@2];
            person4.name = @"person4";
            [[theValue(invokedCount) shouldEventually] equal:@3];
        });

        it(@"jk_exchangeObjectAtIndex:withObjectAtIndex:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students kvo_addObject:person4];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:4];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeReplace)];
                [[changedModel.changedElements should] haveCountOf:2];
                [[changedModel.changedElements.firstObject.object should] equal:person3];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(3)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(2)];

                [[changedModel.changedElements.lastObject.object should] equal:person4];
                [[theValue(changedModel.changedElements.lastObject.newIndex) should] equal:theValue(2)];
                [[theValue(changedModel.changedElements.lastObject.oldIndex) should] equal:theValue(3)];
                invoked = YES;
            }];
            [students kvo_exchangeObjectAtIndex:2 withObjectAtIndex:3];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });
        
        it(@"jk_exchangeObjectAtIndex:withObjectAtIndex:, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students kvo_addObject:person4];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            person3.name = @"person3";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            person4.name = @"person4";
            [[theValue(invokedCount) shouldEventually] equal:@2];
            [students kvo_exchangeObjectAtIndex:2 withObjectAtIndex:3];
            [[theValue(invokedCount) shouldEventually] equal:@3];
            person3.name = @"zhangsan";
            [[theValue(invokedCount) shouldEventually] equal:@4];
            person4.name = @"lisi";
            [[theValue(invokedCount) shouldEventually] equal:@5];
        });

        it(@"jk_removeAllObjects", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students kvo_addObject:person4];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeRemoveTail)];
                [[changedModel.changedElements should] haveCountOf:4];

                [[changedModel.changedElements[0].object should] equal:person1];
                [[theValue(changedModel.changedElements[0].newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements[0].oldIndex) should] equal:theValue(0)];

                [[changedModel.changedElements[1].object should] equal:person2];
                [[theValue(changedModel.changedElements[1].newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements[1].oldIndex) should] equal:theValue(1)];

                [[changedModel.changedElements[2].object should] equal:person3];
                [[theValue(changedModel.changedElements[2].newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements[2].oldIndex) should] equal:theValue(2)];

                [[changedModel.changedElements[3].object should] equal:person4];
                [[theValue(changedModel.changedElements[3].newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements[3].oldIndex) should] equal:theValue(3)];

                invoked = YES;
            }];
            [students kvo_removeAllObjects];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
        });
        
        it(@"jk_removeAllObjects, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students kvo_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students kvo_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students kvo_addObject:person4];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            [students kvo_removeAllObjects];
            [[theValue(invokedCount) shouldEventually] equal:@1];
            person4.name = @"person4";
            [[theValue(invokedCount) shouldEventually] equal:@1];
        });

        it(@"jk_removeObject:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];
            [students kvo_addObject:person1];

            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary * change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeRemoveAtIndex)];
                [[changedModel.changedElements should] haveCountOf:2];
                [[changedModel.changedElements.firstObject.object should] equal:person1];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(0)];

                [[changedModel.changedElements.lastObject.object should] equal:person1];
                [[theValue(changedModel.changedElements.lastObject.newIndex) should] equal:theValue(NSNotFound)];
                [[theValue(changedModel.changedElements.lastObject.oldIndex) should] equal:theValue(1)];
                invoked = YES;
            }];
            [students kvo_removeObject:person1];
            [[theValue(invoked) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
        });
        
        it(@"jk_removeObject:, elementKeyPaths is not nil", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students kvo_addObject:person1];
            [students kvo_addObject:person1];

            __block NSInteger invokedCount = 0;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                invokedCount++;
            }];
            person1.name = @"person1";
            [[theValue(invokedCount) shouldEventually] equal:@1];
            [students kvo_removeObject:person1];
            [[theValue(invokedCount) shouldEventually] equal:@2];
            person1.name = @"zhangsan";
            [[theValue(invokedCount) shouldEventually] equal:@2];
        });

    

             it(@"jk_removeObservers", ^{
                 JKTeacher *teacher = [JKTeacher new];
                 NSMutableArray *students = [NSMutableArray new];
                 teacher.students = students;
                 JKPersonModel *person1 = [JKPersonModel new];
                 person1.name = @"1";
                 [students kvo_addObject:person1];

                 __block BOOL invoked = NO;
                 [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                     invoked = YES;
                 }];
                 person1.name = @"2";
                 [[theValue(invoked) shouldEventually] beYes];
                 NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
                 [[items should] haveCountOf:1];
                 [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
                 [teacher jk_removeObservers];
                 NSArray *items1 = [JKKVOItemManager itemsOfObservered:teacher];
                 [[items1 should] haveCountOf:0];

             });

             it(@"jk_removeObserver:forKeyPath:context:", ^{
                 JKTeacher *teacher = [JKTeacher new];
                 NSMutableArray *students = [NSMutableArray new];
                 teacher.students = students;
                 JKPersonModel *person1 = [JKPersonModel new];
                 person1.name = @"1";
                 [students kvo_addObject:person1];

                 __block BOOL invoked = NO;
                 [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                     invoked = YES;
                 }];
                 person1.name = @"2";
                 [[theValue(invoked) shouldEventually] beYes];
                 NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
                 [[items should] haveCountOf:1];
                 [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
                 [teacher jk_removeObserver:teacher forKeyPath:@"students" context:nil];
                 NSArray *items1 = [JKKVOItemManager itemsOfObservered:teacher];
                 [[items1 should] haveCountOf:0];
             });

        it(@"two object, one array jk_addObject", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;

            JKTeacher *teacher1 = [JKTeacher new];
            teacher1.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            __block BOOL invoked = NO;
            __block BOOL invoked1 = NO;

            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:1];
                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddTail)];
                [[changedModel.changedElements.firstObject.object should] equal:person1];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(0)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked = YES;
            }];

            [teacher1 jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:NSKeyValueChangeNewKey] should] haveCountOf:1];
                [[[change objectForKey:NSKeyValueChangeOldKey] should] haveCountOf:0];

                [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeAddTail)];
                [[changedModel.changedElements.firstObject.object should] equal:person1];
                [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(0)];
                [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(NSNotFound)];
                invoked1 = YES;
            }];
            [students kvo_addObject:person1];
            [[theValue(invoked) shouldEventually] beYes];
            [[theValue(invoked1) shouldEventually] beYes];
            NSArray *items = [JKKVOItemManager itemsOfObservered:teacher];
            [[items should] haveCountOf:1];
            [[items.firstObject should] beKindOfClass:[JKKVOArrayItem class]];

            NSArray *items1 = [JKKVOItemManager itemsOfObservered:teacher];
            [[items1 should] haveCountOf:1];
            [[items1.firstObject should] beKindOfClass:[JKKVOArrayItem class]];
        });

    });
         
});

SPEC_END
