//
//  JKKVOItemManager.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import "JKKVOItemManager.h"
#import <objc/runtime.h>

@interface JKKVOObserver()
@property (nonatomic, copy, nonnull) NSString *originObserverAddress;
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

+ (instancetype)initWithOriginObserver:(id)originObserver
{
    JKKVOObserver *kvoObserver = [[self alloc] init];
    if (kvoObserver) {
        kvoObserver.originObserverAddress = [NSString stringWithFormat:@"%p",originObserver];
    }
    return kvoObserver;
}

- (void)jkhook_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSObject class]]) {
        NSObject *observeredObject = (NSObject *)object;
        JKKVOItem *item = [JKKVOItemManager isContainItemWith_kvoObserver:self observered:observeredObject keyPath:keyPath context:context];
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
/// 被监听的对象
@property (nonatomic, weak, nullable, readwrite) id observered;
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
                          observered:(nonnull id)observered
                             keyPath:(nonnull NSString *)keyPath
                             context:(nullable void *)context
                               block:(nullable void(^)(NSDictionary *change,void *context))block
                         detailBlock:(nullable void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    JKKVOItem *item = [[self alloc] init];
    if (item) {
        item.kvoObserver = kvoObserver;
        item.observered = observered;
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

@property (nonatomic, strong) NSMutableSet *items;
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
    NSArray *items = [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.kvoObserver.originObserverAddress]
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
    if (!observer || !observered) {
        return NO;
    }
    NSArray *items = [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.kvoObserver.originObserverAddress]
            && [observered isEqual:item.observered]) {
            return YES;
        }
    }
    return NO;
}

+ (JKKVOItem *)isContainItemWith_kvoObserver:(JKKVOObserver *)kvoObserver
                                  observered:(id)observered
                                     keyPath:(nullable NSString *)keyPath
                                     context:(nullable void *)context
{
 if (!kvoObserver || !observered) {
        return nil;
    }
    NSArray *items = [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        if ([kvoObserver isEqual:item.kvoObserver]
            && [observered isEqual:item.observered]) {
            return item;
        }
    }
    return nil;
}

+ (NSArray <JKKVOItem *>*)itemsWithObserver:(id)observer
                    observered:(id)observered
                       keyPath:(nullable NSString *)keyPath
{
    NSMutableArray *tmpArray = [NSMutableArray new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in items) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.kvoObserver.originObserverAddress]
            && [observered isEqual:item.observered]) {
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

+ (NSArray <JKKVOItem *>*)observerItemsOfObserered:(id)observered
{
    return [self observerItemsOfObserered:observered keyPath:nil];
}

+ (NSArray <JKKVOItem *>*)observerItemsOfObserered:(id)observered
                                           keyPath:(nullable NSString *)keyPath
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in [items mutableCopy]) {
        if ([observered isEqual:item.observered]) {
            if (keyPath) {
                if ([keyPath isEqualToString:item.keyPath]) {
                    [tmpSet addObject:item];
                }
            } else {
               [tmpSet addObject:item];
            }
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray <JKKVOItem *>*)observeredItemsOfObserver:(id)observer
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in [items mutableCopy]) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observerAddress isEqualToString:item.kvoObserver.originObserverAddress]) {
            [tmpSet addObject:item];
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfObservered:(id)observered
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in [items mutableCopy]) {
        if ([observered isEqual:item.observered]) {
            if (item.keyPath) {
                [tmpSet addObject:item.keyPath];
            }
        }
    }
    return [tmpSet allObjects];
}

+ (NSArray <NSString *>*)observeredKeyPathsOfObserered:(id)observered
                                  observer:(id)observer
{
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *items =  [[JKKVOItemManager sharedManager].items allObjects];
    for (JKKVOItem *item in [items mutableCopy]) {
        NSString *observerAddress = [NSString stringWithFormat:@"%p",observer];
        if ([observered isEqual:item.observered]
            && [observerAddress isEqualToString:item.kvoObserver.originObserverAddress]) {
            if (item.keyPath) {
                [tmpSet addObject:item.keyPath];
            }
        }
    }
    return [tmpSet allObjects];
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
