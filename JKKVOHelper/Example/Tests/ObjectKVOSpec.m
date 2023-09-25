//
//  ObjectKVOSpec.m
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


SPEC_BEGIN(ObjectKVOSpec)

describe(@"JKKVOHelper", ^{
    context(@"addObserver", ^{
   it(@"addObserver", ^{
       JKWorker *worker = [JKWorker new];
       JKPersonModel *person = [JKPersonModel new];
       __block BOOL invoked1 = NO;
       [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
           [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
           invoked1 = YES;
       }];
       worker.name = @"zhangsan";
       NSArray *array = [JKKVOItemManager itemsOfObservered:worker];
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

       NSArray *array1 = [JKKVOItemManager itemsOfObservered:worker];
       [[array1 should] haveCountOf:1];
       NSArray *array2 = [JKKVOItemManager itemsOfObservered:person];
       [[array2 should] haveCountOf:1];
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
     person.name = @"12345";
       __block BOOL invoked1 = NO;
       [person jk_addObserverForKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
           [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
           invoked1 = YES;
       }];
       person.name = @"zhangsan";
       NSArray *array = [JKKVOItemManager itemsOfObservered:person];
       [[array should] haveCountOf:1];
       [[theValue(invoked1) shouldEventually] beYes];

       NSArray *observers = [person jk_observersOfKeyPath:@"name"];
       [[observers should]haveCountOf:1];
       [[observers.firstObject should] equal:person];
   });
});
    
    context(@"singleInstance addObserver", ^{
        static JKWorker *tmp_worker = nil;
        it(@"JKFactory", ^{
            JKFactory *factory = [JKFactory sharedInstance];
            tmp_worker = [JKWorker new];
            __block BOOL invoked1 = NO;
            [factory jk_addObserver:tmp_worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                [[[change objectForKey:@"new"] should] equal:@"北京"];
                invoked1 = YES;
            }];
            factory.name = @"北京";
            NSArray *array = [JKKVOItemManager itemsOfObservered:factory];
            [[array should] haveCountOf:1];
            [[theValue(invoked1) shouldEventually] beYes];
        });

        afterAll(^{
            JKFactory *factory = [JKFactory sharedInstance];
            NSArray *array = [JKKVOItemManager itemsOfObservered:factory];
            [[array should] haveCountOf:1];
        });
});

         context(@"addObserver context", ^{

            it(@"no context", ^{
                JKWorker *worker = [JKWorker new];
                JKPersonModel *person = [JKPersonModel new];
                __block BOOL invoked1 = NO;
                __block BOOL invoked2 = NO;
                [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                    [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                    invoked1 = YES;
                }];

                [[theBlock(^{
                                                    [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
                                                        [[[change objectForKey:@"new"] should] equal:@"zhangsan"];
                                                        invoked2 = YES;
                                                    }];
                }) should] raiseWithReason:@"add duplicate observer,please check"];

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
                    NSArray *array = [JKKVOItemManager itemsOfObservered:worker];
                    [[array should] haveCountOf:2];
            });

});

         context(@"object", ^{
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
        it(@"jk_removeObserver:forKeyPath:", ^{
                JKWorker *worker = [JKWorker new];
                JKPersonModel *person = [JKPersonModel new];
                [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                        }];
                [worker jk_removeObserver:person forKeyPath:@"name"];
                NSArray *array = [JKKVOItemManager itemsOfObservered:worker];
            [[array should] haveCountOf:0];
        });

        it(@"jk_removeObserver:forKeyPath:context:", ^{
            JKWorker *worker = [JKWorker new];
            JKPersonModel *person = [JKPersonModel new];
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

                    }];
            void *aaa = &aaa;
            [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:aaa withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {

            }];

            NSArray *array = [JKKVOItemManager itemsOfObservered:worker];
            [[array should] haveCountOf:2];
            [worker jk_removeObserver:person forKeyPath:@"name" context:aaa];
            NSArray *array1 = [JKKVOItemManager itemsOfObservered:worker];
            [[array1 should] haveCountOf:1];
            JKKVOItem *item = array1.firstObject;
            [[theValue(item.context==NULL) should] beYes];
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
        NSArray *array = [JKKVOItemManager itemsOfObservered:person];
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
        NSArray *array = [JKKVOItemManager itemsOfObservered:person];
        [[array should] haveCountOf:0];
    });

});
    
//    context(@"observerd is nil", ^{
//
//            it(@"observerd is nil", ^{
//                JKPersonModel *person = [JKPersonModel new];
//                JKWorker *worker = [JKWorker new];
//                [person jk_addObserver:worker forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
//
//                }];
//
//            });
//    });
});

SPEC_END
