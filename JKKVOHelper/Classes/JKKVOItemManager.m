//
//  JKKVOItemManager.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import "JKKVOItemManager.h"
#import <objc/runtime.h>

@interface JKKVOItem(Private)
@property (nonatomic, weak, nullable, readwrite) __kindof NSObject *observered_property;
@end

@implementation JKKVOItem(Private)
@dynamic observered_property;

@end

@interface JKKVOObserver()

@property (nonatomic, weak, nullable) __kindof NSObject *originObserver;
@property (nonatomic, copy, nullable) NSString *originObserver_address;


@end

@implementation JKKVOObserver

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       Class class = [JKKVOObserver class];
        SEL observeValueForKeyPath = @selector(observeValueForKeyPath:ofObject:change:context:);
        SEL jk_ObserveValueForKeyPath = @selector(jkhook_observeValueForKeyPath:ofObject:change:context:);
        [JKKVOItemManager jk_exchangeInstanceMethod:class originalSel:observeValueForKeyPath swizzledSel:jk_ObserveValueForKeyPath];
    });
}

+ (instancetype)initWithOriginObserver:(__kindof NSObject *)originObserver
{
    JKKVOObserver *kvoObserver = [[self alloc] init];
    if (kvoObserver) {
        kvoObserver.originObserver = originObserver;
        kvoObserver.originObserver_address = [NSString stringWithFormat:@"%p",originObserver];
    }
    return kvoObserver;
}

- (void)jkhook_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSObject class]]) {
        NSObject *observeredObject = (NSObject *)object;
        JKKVOItem *item = [JKKVOItemManager isContainItemWith_kvoObserver:self observered:observeredObject keyPath:keyPath context:context];
        if (!item.kvoObserver.originObserver) {
            return;
        }
        item.observered_property = [observeredObject valueForKeyPath:keyPath];
        if (item) {
            if (item.block) {
                void(^block)(NSDictionary *change, void *context) = item.block;
                if (block) {
                    block(change,context);
                }
            } else if (item.detailBlock) {
                void(^detailBlock)(NSString *keyPath, NSDictionary *change, void *context) = item.detailBlock;
                if (detailBlock) {
                    detailBlock(keyPath,change,context);
                }
            }
        }
        
    }
}

@end
#pragma mark - - JKKVOItem - -
@interface JKKVOItem()
/// 观察者
@property (nonatomic, strong, nonnull, readwrite) JKKVOObserver *kvoObserver;
/// 被观察的对象
@property (nonatomic, weak, nullable, readwrite) __kindof NSObject *observered;
/// 被观察的对象的内存地址
@property (nonatomic, copy, nullable, readwrite)  NSString * observered_address;

@property (nonatomic, weak, nullable, readwrite) __kindof NSObject *observered_property;
/// 监听的keyPath
@property (nonatomic, copy, nonnull, readwrite) NSString *keyPath;
/// 上下文
@property (nonatomic, nullable, readwrite) void *context;
/// 回调
@property (nonatomic, copy, readwrite) void(^block)(NSDictionary *change,void *context);
/// 返回更详细信息的回调
@property (nonatomic, copy, readwrite) void(^detailBlock)(NSString *keyPath, NSDictionary *change, void *context);
@end

@implementation JKKVOItem

+ (instancetype)initWith_kvoObserver:(nonnull JKKVOObserver *)kvoObserver
                          observered:(nonnull __kindof NSObject *)observered
                 observered_property:(__kindof NSObject *)observered_property
                             keyPath:(nonnull NSString *)keyPath
                             context:(nullable void *)context
                               block:(nullable void(^)(NSDictionary *change,void *context))block
                         detailBlock:(nullable void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    JKKVOItem *item = [[self alloc] init];
    if (item) {
        item.kvoObserver = kvoObserver;
        item.observered = observered;
        item.observered_address = [NSString stringWithFormat:@"%p",observered];
        item.observered_property = observered_property;
        item.keyPath = keyPath;
        item.context = context;
        item.block = block;
        item.detailBlock = detailBlock;
    }
    return item;
}

@end

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
        if ([[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return item;
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
        if ([[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
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
        if ([kvoObserver isEqual:item.kvoObserver]
            && [[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [keyPath isEqualToString:item.keyPath]
            && context == item.context) {
            return item;
        }
    }
    return nil;
}

+ (NSArray <JKKVOItem *>*)itemsWithObserver:(__kindof NSObject *)observer
                                 observered:(__kindof NSObject *)observered
                                    keyPath:(nullable NSString *)keyPath
{
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]
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
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
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

+ (NSArray <JKKVOItem *>*)itemsOfObservered_property:(__kindof NSObject *)observered_property
{
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([observered_property isEqual:item.observered_property]) {
            if (![tmpArray containsObject:item]) {
                [tmpArray addObject:item];
            }
        }
    }
    [self unLock];
    return [tmpArray copy];
}

+ (NSArray <JKKVOItem *>*)itemsOfObserver:(__kindof NSObject *)observer
{
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]) {
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
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([kvoObserver isEqual:item.kvoObserver]) {
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
    NSArray *items = [JKKVOItemManager itemsOfObservered:observered keyPath:keyPath];
    [self lock];
    NSMutableSet *set = [NSMutableSet new];
    for (JKKVOItem *item in items) {
        if (item.kvoObserver.originObserver) {
            [set addObject:item.kvoObserver.originObserver];
        }
    }
    [self unLock];
    return [set allObjects];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfObservered:(__kindof NSObject *)observered
{
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]) {
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
    [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([[NSString stringWithFormat:@"%p",observered] isEqualToString:item.observered_address]
            && [[NSString stringWithFormat:@"%p",observer] isEqualToString:item.kvoObserver.originObserver_address]) {
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
   [self lock];
    NSArray *items =  [JKKVOItemManager items];
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (JKKVOItem *item in items) {
        if ([kvoObserver isEqual:item.kvoObserver]) {
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
