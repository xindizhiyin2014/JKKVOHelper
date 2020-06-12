//
//  JKKVOItemManager.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import "JKKVOItemManager.h"
#import <objc/runtime.h>
#import "JKKVOItem.h"

#pragma mark - - JKKVOItemManager - -

@interface JKKVOItemManager()

/// 所有的items
@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation JKKVOItemManager

+ (instancetype)sharedManager
{
    static JKKVOItemManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        _manager.lock = [[NSRecursiveLock alloc] init];
        _manager.items = [NSMutableArray new];
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
    if (item
        && ![[JKKVOItemManager sharedManager].items containsObject:item]) {
        [[JKKVOItemManager sharedManager].items addObject:item];
    }
}

+ (void)removeItem:(JKKVOItem *)item
{
    if (item) {
        [[JKKVOItemManager sharedManager].items removeObject:item];
    }
}

+ (NSArray *)items
{
    return [[JKKVOItemManager sharedManager].items copy];
}

+ (nullable JKKVOItem *)isContainItemWithObserver:(__kindof NSObject *)observer
                                       observered:(__kindof NSObject *)observered
                                          keyPath:(NSString *)keyPath
                                          context:(nullable void *)context
{
    if (!observer || !observered || !keyPath) {
        return nil;
    }
    [self lock];
    NSArray *items = [JKKVOItemManager items];
    [self unLock];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return item;
        }
    }
    return nil;
}

+ (nullable JKKVOArrayItem *)isContainArrayItemWithObserver:(__kindof NSObject *)observer
                                                 observered:(__kindof NSObject *)observered
                                                    keyPath:(NSString *)keyPath
                                                    context:(nullable void *)context
{
  if (!observer || !observered || !keyPath) {
        return nil;
    }
    [self lock];
    NSArray *items = [JKKVOItemManager items];
    [self unLock];
    for (JKKVOItem *item in items) {
        if ([item isKindOfClass:[JKKVOArrayItem class]]
            && item.valid
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return (JKKVOArrayItem *)item;
        }
    }
    return nil;
}

+ (BOOL)isContainItemWithObserver:(__kindof NSObject *)observer
                       observered:(__kindof NSObject *)observered
{
    if (!observer || !observered) {
        return NO;
    }
    [self lock];
    NSArray *items = [JKKVOItemManager items];
    [self unLock];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
            return YES;
        }
    }
    return NO;
}

+ (nullable JKKVOItem *)isContainItemWith_kvoObserver:(JKKVOObserver *)kvoObserver
                                           observered:(__kindof NSObject *)observered
                                              keyPath:(NSString *)keyPath
                                              context:(nullable void *)context
{
 if (!kvoObserver || !observered || !keyPath) {
        return nil;
    }
    [self lock];
    NSArray *items = [JKKVOItemManager items];
    [self unLock];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [kvoObserver isEqual:item.kvoObserver]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return item;
        }
    }
    return nil;
}

+ (nullable JKKVOItem *)isContainItemWith_kvoObserver:(JKKVOObserver *)kvoObserver
{
    if (!kvoObserver) {
        return nil;
    }
    [self lock];
    NSArray *items = [JKKVOItemManager items];
    [self unLock];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [kvoObserver isEqual:item.kvoObserver]) {
            return item;
        }
    }
    return nil;
}

+ (NSArray <JKKVOItem *>*)itemsWithObserver:(__kindof NSObject *)observer
                                 observered:(__kindof NSObject *)observered
                                    keyPath:(nullable NSString *)keyPath
{
    if (!observer || !observered) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
            if (keyPath) {
                if ([keyPath isEqualToString:item.keyPath]) {
                    if (![tmpArray containsObject:item]) {
                        [tmpArray addObject:item];
                    }
                }
            } else {
                if (![tmpArray containsObject:item]) {
                    [tmpArray addObject:item];
                }
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <JKKVOItem *>*)itemsOfObservered:(__kindof NSObject *)observered
{
    return [self itemsOfObservered:observered keyPath:nil];
}

+ (NSArray <JKKVOItem *>*)itemsOfObservered:(__kindof NSObject *)observered
                                    keyPath:(nullable NSString *)keyPath
{
    if (!observered) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
            if (keyPath) {
                if ([keyPath isEqualToString:item.keyPath]) {
                    if (![tmpArray containsObject:item]) {
                        [tmpArray addObject:item];
                    }
                }
            } else {
               if (![tmpArray containsObject:item]) {
                   [tmpArray addObject:item];
               }
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}


+ (NSArray <JKKVOArrayItem *>*)arrayItemsOfObservered_property:(__kindof NSObject *)observered_property
{
  if (!observered_property) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *tmpItem in items) {
        if ([tmpItem isKindOfClass:[JKKVOArrayItem class]]) {
            JKKVOArrayItem *item = (JKKVOArrayItem *)tmpItem;
            if (item.valid
                && [observered_property isEqual:item.observered_property]) {
                if (![tmpArray containsObject:item]) {
                    [tmpArray addObject:item];
                }
            }
        }
        
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <JKKVOItem *>*)itemsOfObserver:(__kindof NSObject *)observer
{
    if (!observer) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]) {
            if (![tmpArray containsObject:item]) {
                [tmpArray addObject:item];
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <JKKVOItem *>*)itemsOfKvo_Observer:(__kindof NSObject *)kvoObserver
{
    if (!kvoObserver) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [kvoObserver isEqual:item.kvoObserver]) {
            if (![tmpArray containsObject:item]) {
                [tmpArray addObject:item];
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <__kindof NSObject *>*)observersOfObservered:(__kindof NSObject *)observered
                                                keyPath:(NSString *)keyPath
{
    if (!observered) {
        return @[];
    }
    NSArray *items = [JKKVOItemManager itemsOfObservered:observered keyPath:keyPath];
    [self lock];
    NSMutableSet *set = [NSMutableSet new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && item.kvoObserver.originObserver) {
            [set addObject:item.kvoObserver.originObserver];
        }
    }
    [self unLock];
    return [set allObjects];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfObservered:(__kindof NSObject *)observered
{
    if (!observered) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
            if (item.keyPath) {
                if (![tmpArray containsObject:item.keyPath]) {
                    [tmpArray addObject:item.keyPath];
                }
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfObserered:(__kindof NSObject *)observered
                                              observer:(__kindof NSObject *)observer
{
    if (!observer || !observered) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [[NSString stringWithFormat:@"%p",observer]
                isEqualToString:item.kvoObserver.originObserver_address]) {
            if (item.keyPath) {
                if (![tmpArray containsObject:item.keyPath]) {
                    [tmpArray addObject:item.keyPath];
                }
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfKvo_observer:(JKKVOObserver *)kvoObserver
{
    if (!kvoObserver) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (item.valid
            && [kvoObserver isEqual:item.kvoObserver]) {
            if (item.keyPath) {
                if (![tmpArray containsObject:item.keyPath]) {
                    [tmpArray addObject:item.keyPath];
                }
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <JKKVOItem *>*)dealloc_itemsOfObservered:(__kindof NSObject *)observered
{
    
 if (!observered) {
        return @[];
    }
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if (!item.valid
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
            if (![tmpArray containsObject:item]) {
               [tmpArray addObject:item];
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

#pragma mark - - private method - -

/**
 根据内存地址转换对应的对象

 @param addressStr 内存地址
 @return 转换后的对象
 */
//#pragma clang diagnostic ignored "-Wshorten-64-to-32"
//+ (id)objectWithAddressStr:(NSString *)addressStr
//{
//    addressStr = [addressStr hasPrefix:@"0x"] ? addressStr : [@"0x" stringByAppendingString:addressStr];
//    uintptr_t hex = strtoull(addressStr.UTF8String, NULL, 0);
//    id object = nil;
//    @try {
//        object = (__bridge id)(void *)hex;
//    } @catch (NSException *exception) {
//#if DEBUG
//        NSLog(@"JKKVOHelper exception %@",exception);
//#endif
//    } @finally {
//
//    }
//    return object;
//}

/**
 实例方法替换
 
 @param targetClass targetClass
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)jk_exchangeInstanceMethod:(Class)targetClass
                   originalSel:(SEL)originalSel
                   swizzledSel:(SEL)swizzledSel
{
    Method originalMethod = class_getInstanceMethod(targetClass, originalSel);
    Method swizzledMethod = class_getInstanceMethod(targetClass, swizzledSel);
    
    // 这里用这个方法做判断，看看origin方法是否有实现，如果没实现，直接用我们自己的方法，如果有实现，则进行交换
    BOOL isAddMethod =
    class_addMethod(targetClass,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (isAddMethod) {
        class_replaceMethod(targetClass,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end
