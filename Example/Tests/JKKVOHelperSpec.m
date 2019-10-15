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
#import "JKWorker.h"
#import "JKTeacher.h"


SPEC_BEGIN(JKKVOHelperSpec)
static JKPersonModel *thePerson = nil;
describe(@"JKKVOHelper", ^{
         context(@"addObserver", ^{
    it(@"addObserver", ^{
        JKWorker *worker = [JKWorker new];
        JKPersonModel *person = [JKPersonModel new];
        [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
            
        }];
        worker.name = @"zhangsan";
        NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(1)];
    });
    
    it(@"test manager", ^{
       NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(0)];
    });
//    
    it(@"A observe B, B observe A", ^{
      JKWorker *worker = [JKWorker new];
        JKPersonModel *person = [JKPersonModel new];
        [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
        
                }];
        
 
        [person jk_addObserver:worker forKeyPath:@"age" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
            
        }];
        
                
    
        NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(2)];
    
    });
    
    it(@"test dealloc", ^{
       NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(0)];
    });
    
    it(@"test origin remove", ^{
       JKWorker *worker = [JKWorker new];
        JKPersonModel *person = [JKPersonModel new];
        [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
        
                }];
        [worker removeObserver:person forKeyPath:@"name"];
        [worker removeObserver:person forKeyPath:@"name"];
        NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(0)];
        
    });
    
    it(@"test origin jk_remove", ^{
       JKWorker *worker = [JKWorker new];
        JKPersonModel *person = [JKPersonModel new];
        [worker jk_addObserver:person forKeyPath:@"name" options:NSKeyValueObservingOptionNew withBlock:^(NSDictionary * _Nonnull change, void * _Nonnull context) {
        
                }];
        [worker jk_removeObserver:person forKeyPath:@"name"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [worker jk_removeObserver:person forKeyPath:@"name"];
        });
        
        [worker removeObserver:person forKeyPath:@"name"];
        NSArray *array = [JKKVOItemManager items];
        [[theValue([array count]) should] equal:theValue(0)];
        
    });
});
});

SPEC_END
