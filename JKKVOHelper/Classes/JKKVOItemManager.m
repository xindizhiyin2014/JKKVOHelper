//
//  JKKVOItemManager.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import "JKKVOItemManager.h"
@implementation JKKVOItem

@end

@interface JKKVOItemManager()

@property (nonatomic, strong) NSMutableSet *items;
@property (nonatomic, strong) NSMutableSet *classes;    ///< 保存被交换方法的类名
@property (nonatomic, strong) NSLock *lock;

@end

@implementation JKKVOItemManager

static JKKVOItemManager *_manager = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        _manager.lock = [[NSLock alloc] init];
        _manager.items = [NSMutableSet new];
        _manager.classes = [NSMutableSet new];
    });
    return _manager;
}

+ (void)lock
{
    [[JKKVOItemManager sharedManager].lock lock];
}

+ (void)unLock
{
    [[JKKVOItemManager sharedManager].lock unlock];
}

+ (void)addItem:(JKKVOItem *)item
{
    [[JKKVOItemManager sharedManager].items addObject:item];
    id observer = [self objectWithAddressStr:item.observerAddress];
    if (observer) {
        [[JKKVOItemManager sharedManager].classes addObject:[observer class]];
    }
    
}

+ (void)removeItem:(JKKVOItem *)item
{
    [[JKKVOItemManager sharedManager].items removeObject:item];
}

+ (NSArray *)items
{

    return [[JKKVOItemManager sharedManager].items allObjects];
}

+ (JKKVOItem *)isContainItemWithObserver:(id)observer
                       observered:(id)observered
                          keyPath:(nullable NSString *)keyPath
                          context:(nullable void *)context
{
    if (!observer || !observered) {
        return nil;
    }
    for (JKKVOItem *item in [JKKVOItemManager sharedManager].items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.observerAddress]
            && [observered isEqual:item.observered]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return item;
        }
    }
    return nil;
}

+ (BOOL)isContainItemWithObserver:(id)observer
                       observered:(id)observered
{
    JKKVOItem *item = [self isContainItemWithObserver:observer observered:observered keyPath:nil context:nil];
    if (item) {
        return YES;
    }
    return NO;
}

+ (BOOL)obseverMethodHasExchangedOfObserver:(id)observer
{
    Class observerClass = [observer class];
    for (Class class in [JKKVOItemManager sharedManager].classes) {
        if ([observerClass isSubclassOfClass:class]) {
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)itemsWithObserver:(id)observer observered:(id)observered keyPath:(nullable NSString *)keyPath
{
    NSMutableArray *tmpArray = [NSMutableArray new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.observerAddress] && [observered isEqual:item.observered]) {
            if (keyPath) {
                if ([keyPath isEqualToString:item.keyPath]) {
                    [tmpArray addObject:item];
                }
            } else {
                [tmpArray addObject:item];
            }
        }
    }
    return [tmpArray copy];
}

+ (NSArray *)observersOfObserered:(id)observered
{
    return [self observersOfObserered:observered keyPath:nil];
}

+ (NSArray *)observeredsOfObserver:(id)observer
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.observerAddress]) {
            id observered = item.observered;
            if (observered) {
                [tmpSet addObject:observered];
            } else {
                [self removeItem:item];
            }
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray *)observeredKeyPathsOfObservered:(id)observered
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        if ([observered isEqual:item.observered]) {
            if (item.keyPath) {
                [tmpSet addObject:item.keyPath];
            } else {
                [self removeItem:item];
            }
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray *)observersOfObserered:(id)observered
                          keyPath:(nullable NSString *)keyPath
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        if ([observered isEqual:item.observered]) {
            if (keyPath) {
                if ([keyPath isEqualToString:item.keyPath]) {
                    id observer = [self observeredsOfObserver:item.observerAddress];
                    if (observer) {
                        [tmpSet addObject:observer];
                    } else {
                        [self removeItem:item];
                    }
                    
                }
            } else {
                id observer = [self observeredsOfObserver:item.observerAddress];
              if (observer) {
                  [tmpSet addObject:observer];
              } else {
                  [self removeItem:item];
              }
            }
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray *)observeredKeyPathsOfObserered:(id)observered
                                  observer:(id)observer
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        id itemObserver = [self objectWithAddressStr:item.observerAddress];
        if ([observered isEqual:item.observered] && [observer isEqual:itemObserver]) {
            if (item.keyPath) {
                [tmpSet addObject:item.keyPath];
            } else {
                [self removeItem:item];
            }
        }
    }
    return [tmpSet allObjects];
}

/**
 根据内存地址转换对应的对象

 @param addressStr 内存地址
 @return 转换后的对象
 */
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
+ (id)objectWithAddressStr:(NSString *)addressStr
{
    addressStr = [addressStr hasPrefix:@"0x"] ? addressStr : [@"0x" stringByAppendingString:addressStr];
    uintptr_t hex = strtoull(addressStr.UTF8String, NULL, 0);
    id object = (__bridge id)(void *)hex;
    return object;
}
@end
