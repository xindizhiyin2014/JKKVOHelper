//
//  JKKVOHelperSpec.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/15.
//  Copyright 2019 xindizhiyin2014. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <JKKVOHelper/JKKVOHelper.h>
#import <JKKVOHelper/JKKVOItemManager.h>
#import "JKTeacher.h"
#import "JKWorker.h"



SPEC_BEGIN(JKKVOHelperSpec)
describe(@"JKKVOHelper", ^{
         context(@"addObserver", ^{
    afterEach(^{
     NSArray *array = [JKKVOItemManager items];
        for(JKKVOItem *item in array) {
            [JKKVOItemManager removeItem:item];
        }
    });
        it(@"addObserver", ^{
            JKWorker *worker = [JKWorker new];
            JKPersonModel *person = [JKPersonModel new];
            __block BOOL invoked1 = NO;
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                invoked1 = YES;
            }];
            worker.name = @"zhangsan";
            NSArray *array = [JKKVOItemManager items];
            [[array should] haveCountOf:1];
            [[theValue(invoked1) shouldEventually] beYes];
        });

        it(@"A observe B, B observe A", ^{
          JKWorker *worker = [JKWorker new];
            JKPersonModel *person = [JKPersonModel new];
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

            }];

            [person jk_addObserver:worker forKeyPath:@"age" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

            }];

            NSArray *array = [JKKVOItemManager items];
            [[array should] haveCountOf:2];
        });

        it(@"test observerKeyPaths", ^{
          JKWorker *worker = [JKWorker new];
            JKPersonModel *person = [JKPersonModel new];
            __block NSInteger invokedCout = 0;
            [worker jk_addObserver:person forKeyPaths:@[@"name",@"factory"] options:NSKeyValueObservingOptionNew context:nil withDetailBlock:^(NSString * _Nonnull keyPath, NSDictionary * _Nonnull change, void * _Nonnull context) {
                if([keyPath isEqualToString:@"name"]){
                   [[[change objectForKey:@"new"] should] equal:@"bbb"];
                } else if ([keyPath isEqualToString:@"factory"]) {
                    JKFactory *factory = [change objectForKey:@"new"];
                    [[factory.name should] equal:@"China"];
                }
                invokedCout++;
            }];

            worker.name = @"bbb";
            JKFactory *factory = [JKFactory new];
            factory.name = @"China";
            worker.factory = factory;
            [[theValue(invokedCout) shouldEventually] equal:@(2)];
        });

      it(@"test observer and observered are the same object", ^{
            JKPersonModel *person = [JKPersonModel new];
            __block BOOL invoked1 = NO;
            [person jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                invoked1 = YES;
            }];
            person.name = @"zhangsan";
            NSArray *array = [JKKVOItemManager items];
            [[array should] haveCountOf:1];
            [[theValue(invoked1) shouldEventually] beYes];
        });


});
    context(@"singleInstance addObserver", ^{
        it(@"JKFactory", ^{
            JKFactory *factory = [JKFactory sharedInstance];
            JKWorker *worker = [JKWorker new];
            __block BOOL invoked1 = NO;
            [factory jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] equal:@"北京"];
                invoked1 = YES;
            }];
            factory.name = @"北京";
            NSArray *array = [JKKVOItemManager items];
            [[array should] haveCountOf:1];
            [[theValue(invoked1) shouldEventually] beYes];
        });

        afterAll(^{
            NSArray *array = [JKKVOItemManager items];
            [[array should] haveCountOf:1];
        });
});

         context(@"addObserver context", ^{

            beforeAll(^{
               NSArray *array = [JKKVOItemManager items];
                for(JKKVOItem *item in array) {
                    [JKKVOItemManager removeItem:item];
                }
            });
            afterEach(^{
               NSArray *array = [JKKVOItemManager items];
                for(JKKVOItem *item in array) {
                    [JKKVOItemManager removeItem:item];
                }
            });

            it(@"no context", ^{
                JKWorker *worker = [JKWorker new];
                JKPersonModel *person = [JKPersonModel new];
                __block BOOL invoked1 = NO;
                __block BOOL invoked2 = NO;
                [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                    [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                    invoked1 = YES;
                }];

                [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                    [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                    invoked2 = YES;
                }];
                worker.name = @"zhangsan";
                [[theValue(invoked1) shouldEventually] beYes];
                [[theValue(invoked2) shouldEventually] beNo];
                NSArray *array = [JKKVOItemManager items];
                [[array should] haveCountOf:1];
            });

            it(@"has context", ^{
                    JKWorker *worker = [JKWorker new];
                    JKPersonModel *person = [JKPersonModel new];
                    __block BOOL invoked1 = NO;
                    __block BOOL invoked2 = NO;
                    void *aaa = &aaa;
                    [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:aaa withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                        [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                        invoked1 = YES;
                    }];
                    void *bbb = &bbb;
                    [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew
                        context:bbb withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                        [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                        invoked2 = YES;
                    }];
                    worker.name = @"zhangsan";
                    [[theValue(invoked1) shouldEventually] beYes];
                    [[theValue(invoked2) shouldEventually] beYes];
                    NSArray *array = [JKKVOItemManager items];
                    [[array should] haveCountOf:2];
            });

});

         context(@"object", ^{
            beforeAll(^{
                   NSArray *array = [JKKVOItemManager items];
                    for(JKKVOItem *item in array) {
                        [JKKVOItemManager removeItem:item];
                    }
                });
            afterEach(^{
               NSArray *array = [JKKVOItemManager items];
                for(JKKVOItem *item in array) {
                    [JKKVOItemManager removeItem:item];
                }
            });

            it(@"jk_observeredKeyPaths", ^{
                JKPersonModel *person = [JKPersonModel new];
                 JKWorker *worker = [JKWorker new];
                 [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                 }];
                 [person jk_addObserver:worker forKeyPath:@"age" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                 }];

                 NSArray *keyPaths = [person jk_observeredKeyPaths];
                 [[keyPaths should] haveCountOf:2];
            });
            it(@"jk_observersOfKeyPath:1", ^{
                JKPersonModel *person = [JKPersonModel new];
                JKWorker *worker = [JKWorker new];
                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                void *aaa = &aaa;
                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:aaa withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                NSArray *observers = [person jk_observersOfKeyPath:@"name"];
                [[observers should] haveCountOf:1];

            });
            it(@"jk_observersOfKeyPath:2", ^{
                JKPersonModel *person = [JKPersonModel new];
                JKWorker *worker = [JKWorker new];
                JKWorker *worker1 = [JKWorker new];

                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                [person jk_addObserver:worker1 forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                NSArray *observers = [person jk_observersOfKeyPath:@"name"];
                [[observers should] haveCountOf:2];
            });
            it(@"jk_keyPathsObserveredBy:", ^{
                JKPersonModel *person = [JKPersonModel new];
                JKWorker *worker = [JKWorker new];
                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                [person jk_addObserver:worker forKeyPath:@"age" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                }];
                NSArray *keyPaths = [person jk_keyPathsObserveredBy:worker];
                [[keyPaths should] haveCountOf:2];
            });
});


     context(@"remove", ^{
        beforeAll(^{
           NSArray *array = [JKKVOItemManager items];
            for(JKKVOItem *item in array) {
                [JKKVOItemManager removeItem:item];
            }
        });
    afterEach(^{
       NSArray *array = [JKKVOItemManager items];
        for(JKKVOItem *item in array) {
            [JKKVOItemManager removeItem:item];
        }
    });
        it(@"jk_removeObserver:forKeyPath:", ^{
                JKWorker *worker = [JKWorker new];
                JKPersonModel *person = [JKPersonModel new];
                [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                        }];
                [worker jk_removeObserver:person forKeyPath:@"name"];
                NSArray *array = [JKKVOItemManager items];
                [[theValue([array count]) should] equal:theValue(0)];
        });

        it(@"jk_removeObserver:forKeyPath:context:", ^{
            JKWorker *worker = [JKWorker new];
            JKPersonModel *person = [JKPersonModel new];
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                    }];
            void *aaa = &aaa;
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:aaa withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

            }];

            NSArray *array = [JKKVOItemManager items];
            [[theValue([array count]) should] equal:theValue(2)];
            [worker jk_removeObserver:person forKeyPath:@"name" context:aaa];
            NSArray *array1 = [JKKVOItemManager items];
            [[theValue([array1 count]) should] equal:theValue(1)];
            JKKVOItem *item = array1.firstObject;
            [[item.keyPath should] equal:@"name"];
        });

    it(@"jk_removeObserver:forKeyPaths:", ^{
        JKPersonModel *person = [JKPersonModel new];
        JKWorker *worker = [JKWorker new];
        [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

        }];
        [person jk_addObserver:worker forKeyPath:@"age" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

        }];


        NSArray *keyPaths = [person jk_observeredKeyPaths];
        [[keyPaths should] haveCountOf:2];
        [person jk_removeObserver:worker forKeyPaths:keyPaths];
        NSArray *array = [JKKVOItemManager items];
        [[array should] haveCountOf:0];
    });

    it(@"jk_removeObservers:forKeyPath:", ^{
        JKPersonModel *person = [JKPersonModel new];
        JKWorker *worker = [JKWorker new];
        JKWorker *worker1 = [JKWorker new];

        [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

        }];
        [person jk_addObserver:worker1 forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

        }];
        NSArray *observers = [person jk_observersOfKeyPath:@"name"];
        [[observers should] haveCountOf:2];
        [person jk_removeObservers:observers forKeyPath:@"name"];
        NSArray *array = [JKKVOItemManager items];
        [[array should] haveCountOf:0];
    });
    
    it(@"for循环内快速创建对象", ^{
        NSMutableSet *set = [NSMutableSet new];
        for (NSInteger i = 0; i < 20; i++) {
            JKPersonModel *person = [JKPersonModel new];
            NSInteger itemCount = [JKKVOItemManager items].count;
            __block BOOL invoked = NO;
            [person jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                invoked = YES;
            }];
            person.name = [NSString stringWithFormat:@"name:%@",@(i)];
            [[theValue(invoked) should] beYes];
            [[theValue(itemCount + 1) should] equal:theValue([JKKVOItemManager items].count)];
            NSString *address = [NSString stringWithFormat:@"%p",person];
            [set addObject:address];
            NSLog(@"amodel %@",address);
        }
        NSLog(@"count %@",@([set count]));
        [[set shouldNot] haveCountOf:20];
        [[[JKKVOItemManager items] should] haveCountOf:0];
    });

});
         context(@"array action", ^{

        afterEach(^{
           NSArray *array = [JKKVOItemManager items];
            for(JKKVOItem *item in array) {
                [JKKVOItemManager removeItem:item];
            }
        });

        it(@"init", ^{
            JKTeacher *teacher = [JKTeacher new];
            __block BOOL invoked = NO;
            [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                invoked = YES;

            }];
            teacher.students = @[].mutableCopy;
            [[theValue(invoked) shouldEventually] beYes];

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
        });
    
    it(@"element's property change", ^{
        JKTeacher *teacher = [JKTeacher new];
        NSMutableArray *students = [NSMutableArray new];
        teacher.students = students;
        JKPersonModel *person1 = [JKPersonModel new];
        person1.name = @"1";
        [students kvo_addObject:person1];

        __block BOOL invoked = NO;
        [teacher jk_addObserverOfArrayForKeyPath:@"students" options:NSKeyValueObservingOptionNew context:nil elementKeyPaths:@[@"name"] withBlock:^(NSString * _Nonnull keyPath, NSDictionary *change, JKKVOArrayChangeModel * _Nonnull changedModel, void * _Nonnull context) {
            [[theValue(changedModel.changeType) should] equal:theValue(JKKVOArrayChangeTypeElement)];
            [[changedModel.changedElements should] haveCountOf:1];
            [[changedModel.changedElements.firstObject.object should] equal:person1];
            [[theValue(changedModel.changedElements.firstObject.newIndex) should] equal:theValue(0)];
            [[theValue(changedModel.changedElements.firstObject.oldIndex) should] equal:theValue(0)];
            invoked = YES;
        }];
        person1.name = @"2";
        [[theValue(invoked) shouldEventually] beYes];
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
                     [teacher jk_removeObservers];
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
                 [teacher jk_removeObserver:teacher forKeyPath:@"students" context:nil];
             });

         });
         
         context(@"observerd is nil", ^{
            beforeAll(^{
                NSArray *array = [JKKVOItemManager items];
                for(JKKVOItem *item in array) {
                    [JKKVOItemManager removeItem:item];
                }
            });
            it(@"observerd is nil", ^{
                JKPersonModel *person = [JKPersonModel new];
                JKWorker *worker = [JKWorker new];
                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                    
                }];
                
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

             });
             
    afterAll(^{
        NSArray *array = [JKKVOItemManager items];
        [[array should]haveCountOf:0];
    });
});
        

});

SPEC_END
