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
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];

                invoked = YES;
            }];
            teacher.students = @[].mutableCopy;
            [[theValue(invoked) shouldEventually] beYes];

        });

//    it(@"array is nil", ^{
//        JKTeacher *teacher = [JKTeacher new];
//        __block BOOL invoked = NO;
//        NSMutableArray *students = [NSMutableArray new];
//        JKPersonModel *person1 = [JKPersonModel new];
//        person1.name = @"1";
//        [students addObject:person1];
//        teacher.students = students;
//
//        [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//            [[[change objectForKey:@"new"] should] equal:[NSNull null]];
//            invoked = YES;
//        }];
////        teacher.students = nil;
//        [students jk_setNil:&students];
//        [[theValue(invoked) shouldEventually] beYes];
//    });
//
//    it(@"array is nil_1", ^{
//            JKTeacher *teacher = [JKTeacher new];
//            NSMutableArray *students = [NSMutableArray new];
//            JKPersonModel *person1 = [JKPersonModel new];
//            person1.name = @"1";
//            [students addObject:person1];
//            teacher.students = students;
//            [students jk_setNil:&students];
//           [[students should] beNil];
//        });
//
//    it(@"array is nil_2", ^{
//        JKTeacher *teacher = [JKTeacher new];
//        NSMutableArray *students = [NSMutableArray new];
//        JKPersonModel *person1 = [JKPersonModel new];
//        person1.name = @"1";
//        [students addObject:person1];
//        teacher.students = students;
//        [[theBlock(^{
//            [students jk_setNil:nil];
//        }) should] raiseWithReason:@"make sure array != NULL be YES"];
//
//
//    });

//    it(@"array is nil_3", ^{
//        JKTeacher *teacher = [JKTeacher new];
//        NSMutableArray *students = [NSMutableArray new];
//        JKPersonModel *person1 = [JKPersonModel new];
//        person1.name = @"1";
//        [students addObject:person1];
//        teacher.students = students;
//        [[theBlock(^{
//            NSMutableArray *tmpArray = [NSMutableArray new];
//            [students jk_setNil:&tmpArray];
//        }) should] raiseWithReason:@"make sure [self_address isEqualToString:array_address] be YES"];
//    });

        it(@"jk_addObject", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:1];
                invoked = YES;
            }];
            [students jk_addObject:person1];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_insertObject:atIndex:", ^{
           JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:3];
                invoked = YES;
            }];
            [students jk_insertObject:person3 atIndex:1];
            [[theValue(invoked) shouldEventually] beYes];
        });
    it(@"jk_insertObject:atIndex:1", ^{
        JKTeacher *teacher = [JKTeacher new];
        NSMutableArray *students = [NSMutableArray new];
        teacher.students = students;
        JKPersonModel *person1 = [JKPersonModel new];
        person1.name = @"1";
        [students jk_addObject:person1];

        JKPersonModel *person2 = [JKPersonModel new];
        person2.name = @"2";
        [students jk_addObject:person2];

        JKPersonModel *person3 = [JKPersonModel new];
        person3.name = @"3";

        __block BOOL invoked = NO;
        [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
            [[[change objectForKey:@"new"] should] haveCountOf:3];
            invoked = YES;
        }];
        [students jk_insertObject:person3 atIndex:2];
        [[theValue(invoked) shouldEventually] beYes];
    });

        it(@"jk_removeLastObject", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students jk_addObject:person2];

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:2];
                invoked = YES;
            }];
            [students jk_removeLastObject];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_removeObjectAtIndex", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students jk_addObject:person2];

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:2];
                invoked = YES;
            }];
            [students jk_removeObjectAtIndex:1];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_replaceObjectAtIndex:withObject:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students jk_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:3];
                NSArray *array = [change objectForKey:@"new"];
                JKPersonModel *person = array[2];
                [[person should] equal:person4];
                invoked = YES;
            }];
            [students jk_replaceObjectAtIndex:2 withObject:person4];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_addObjectsFromArray:", ^{
          JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";

            JKPersonModel *person4 = [JKPersonModel new];
            NSArray *array = @[person3,person4];

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:4];
                invoked = YES;
            }];
            [students jk_addObjectsFromArray:array];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_exchangeObjectAtIndex:withObjectAtIndex:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students jk_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students jk_addObject:person4];


            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:4];
                NSArray *array = [change objectForKey:@"new"];
                JKPersonModel *person_1 = array[2];
                [[person_1 should] equal:person4];
                JKPersonModel *person_2 = array[3];
                [[person_2 should] equal:person3];
                invoked = YES;
            }];
            [students jk_exchangeObjectAtIndex:2 withObjectAtIndex:3];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_removeAllObjects", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];

            JKPersonModel *person2 = [JKPersonModel new];
            person2.name = @"2";
            [students jk_addObject:person2];

            JKPersonModel *person3 = [JKPersonModel new];
            person3.name = @"3";
            [students jk_addObject:person3];
            JKPersonModel *person4 = [JKPersonModel new];
            person4.name = @"4";
            [students jk_addObject:person4];

            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                invoked = YES;
            }];
            [students jk_removeAllObjects];
            [[theValue(invoked) shouldEventually] beYes];
        });

        it(@"jk_removeObject:", ^{
            JKTeacher *teacher = [JKTeacher new];
            NSMutableArray *students = [NSMutableArray new];
            teacher.students = students;
            JKPersonModel *person1 = [JKPersonModel new];
            person1.name = @"1";
            [students jk_addObject:person1];
            __block BOOL invoked = NO;
            [teacher jk_addObserverForKeyPath:@"students" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] haveCountOf:0];
                invoked = YES;
            }];
            [students jk_removeObject:person1];
            [[theValue(invoked) shouldEventually] beYes];
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
    afterAll(^{
        NSArray *array = [JKKVOItemManager items];
        [[array should]haveCountOf:0];
    });
});
        

});

SPEC_END
