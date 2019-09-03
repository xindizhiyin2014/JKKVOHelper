//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import <objc/runtime.h>

@interface JKKVOHelperItem : NSObject

@property (nonatomic, copy) NSString *observerAddress;                          ///< 观察者的内存地址
@property (nonatomic, copy) NSString *keyPath;                                  ///< 监听的keyPath
@property (nonatomic, copy) void(^block)(NSDictionary *change,void *context);   ///< 回调

@end

@implementation JKKVOHelperItem

@end


@interface NSObject ()

@property (nonatomic, strong) NSMutableSet *jk_kvoHelperItems;       ///< 保存observer,keyPath和block的set
@property (nonatomic, strong) NSLock *jk_observerLock;               ///< 线程锁，保证线程安全

@end

@implementation NSObject (JKKVOHelper)
static NSMutableSet *jk_observerSet = nil;      ///< 方法被替换的观察者的集合
static NSMutableSet *jk_observeredSet = nil;    ///< 方法被替换的被观察者的集合

- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
             withBlock:(void(^)(NSDictionary *change,void *context))block
{
    [self jk_addObserver:observer forKeyPath:keyPath options:options context:nil withBlock:block];
}

- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
             withBlock:(void(^)(NSDictionary *change,void *context))block
{
    if (!observer || !keyPath || !block) {
        return;
    }
    [self.jk_observerLock lock];
    if (![self jk_IsContainObserver:observer andKeyPath:keyPath]) {
        JKKVOHelperItem *item = [JKKVOHelperItem new];
        item.observerAddress = [NSString stringWithFormat:@"%p",observer];
        item.keyPath = keyPath;
        item.block = block;
        [self.jk_kvoHelperItems addObject:item];
        [NSObject jk_exchangeMethodWithObserver:observer observered:self];
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
    [self.jk_observerLock unlock];
    
}

- (void)jk_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
{
    if (!keyPath || !observer) {
        return;
    }
    [self.jk_observerLock lock];
    if ([self jk_IsContainObserver:observer andKeyPath:keyPath]) {
        
        [self jk_removeKVOHelperItemWithObserver:observer andKeyPath:keyPath];
        [self removeObserver:observer forKeyPath:keyPath];
    }
    
    [self.jk_observerLock unlock];
}

- (void)jk_removeObserver:(NSObject *)observer
              forKeyPaths:(NSArray <NSString *>*)keyPaths
{
    for (NSString *keyPath in keyPaths) {
        [self jk_removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)jk_removeObservers:(NSArray <NSObject *>*)observers
                forKeyPath:(NSString *)keyPath
{
    if (!keyPath) {
        return;
    }
    if (!observers) {
     for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
         if ([item.keyPath isEqualToString:keyPath]) {
            id observer = [self jk_objectWithAddressStr:item.observerAddress];
             [self jk_removeObserver:observer forKeyPath:keyPath];
         }
     }
    } else {
        for (NSObject *observer in observers) {
            [self jk_removeObserver:observer forKeyPath:keyPath];
        }
    }
}

- (void)jk_removeObservers
{
    NSArray *observers = [self jk_observers];
    for (NSObject *observer in observers) {
        NSArray *keyPaths = [self jk_keyPathsObserveredBy:observer];
        [self jk_removeObserver:observer forKeyPaths:keyPaths];
    }
}

- (NSArray *)jk_observers
{
    NSMutableArray *observers = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        id observer = [self jk_objectWithAddressStr:item.observerAddress];
        [observers addObject:observer];
    }
    return [observers copy];
}

- (NSArray *)jk_observeredKeyPaths
{
    NSMutableArray *keyPaths = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        [keyPaths addObject:item.keyPath];
    }
    return [keyPaths copy];
}

- (NSArray *)jk_observersForKeyPath:(NSString *)keyPath
{
    NSMutableArray *observers = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        if ([item.keyPath isEqualToString:keyPath]) {
            id observer = [self jk_objectWithAddressStr:item.observerAddress];
            [observers addObject:observer];
        }
    }
    return [observers copy];
}

- (NSArray *)jk_keyPathsObserveredBy:(NSObject *)observer
{
    NSMutableArray *keyPaths = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        id itemObserver = [self jk_objectWithAddressStr:item.observerAddress];
        if ([itemObserver isEqual:observer]) {
            [keyPaths addObject:item.keyPath];
        }
    }
    return [keyPaths copy];
}


- (void)jk_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSObject class]]) {
        NSObject *observeredObject = (NSObject *)object;
        JKKVOHelperItem *item = [observeredObject jk_IsContainObserver:self andKeyPath:keyPath];
        if (item) {
            void(^block)(NSDictionary *change,void *context) = item.block;
            if (block) {
                block(change,context);
            }
        }else{
            [self jk_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }else{
        [self jk_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)jk_dealloc
{
    [self.jk_observerLock lock];
    [self jk_removeObservers];
    [self jk_dealloc];
    [self.jk_observerLock unlock];
}

#pragma mark - setter -
- (void)setJk_kvoHelperItems:(NSMutableSet *)jk_kvoHelperItems
{
    objc_setAssociatedObject(self, (__bridge const void *)(@"jk_kvoHelperItemsKey"), jk_kvoHelperItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setJk_observerLock:(NSLock *)jk_observerLock
{
    objc_setAssociatedObject(self, (__bridge const void *)(@"jk_observerLockKey"), jk_observerLock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - getter -
- (NSMutableSet *)jk_kvoHelperItems
{
    NSMutableSet *set = objc_getAssociatedObject(self, (__bridge const void *)(@"jk_kvoHelperItemsKey"));
    if (!set) {
        [self setJk_kvoHelperItems:[NSMutableSet new]];
        set = objc_getAssociatedObject(self, (__bridge const void *)(@"jk_kvoHelperItemsKey"));
    }
    
    return set;
}

- (NSLock *)jk_observerLock
{
    NSLock *lock = objc_getAssociatedObject(self, (__bridge const void *)(@"jk_observerLockKey"));
    if (!lock) {
        [self setJk_observerLock:[NSLock new]];
        lock = objc_getAssociatedObject(self, (__bridge const void *)(@"jk_observerLockKey"));
    }
    return lock;
}

#pragma mark - private method
+ (void)jk_exchangeMethodWithObserver:(NSObject *)observer observered:(NSObject *)observered
{
    if (!jk_observerSet) {
        jk_observerSet = [NSMutableSet new];
    }
    
    dispatch_once_t observerOnceToken = 0;
    if (![jk_observerSet containsObject:NSStringFromClass([observer class])]) {
        [jk_observerSet addObject:NSStringFromClass([observer class])];
    } else {
        observerOnceToken = -1;
    }
    dispatch_once(&observerOnceToken, ^{
        Class class = [observer class];
        SEL observeValueForKeyPath = @selector(observeValueForKeyPath:ofObject:change:context:);
        SEL jk_ObserveValueForKeyPath = @selector(jk_observeValueForKeyPath:ofObject:change:context:);
        [NSObject jk_exchangeInstanceMethod:class originalSel:observeValueForKeyPath swizzledSel:jk_ObserveValueForKeyPath];

    });
    
    if (!jk_observeredSet) {
        jk_observeredSet = [NSMutableSet new];
    }
    
    dispatch_once_t observeredOnceToken = 0;
    if (![jk_observeredSet containsObject:NSStringFromClass([observered class])]) {
        [jk_observeredSet addObject:NSStringFromClass([observered class])];
    } else {
        observeredOnceToken = -1;
    }
    
    dispatch_once(&observeredOnceToken, ^{
        Class class = [observered class];
        SEL observeredDealloc = NSSelectorFromString(@"dealloc");
        SEL jk_observerdDealloc = NSSelectorFromString(@"jk_dealloc");
        [NSObject jk_exchangeInstanceMethod:class originalSel:observeredDealloc swizzledSel:jk_observerdDealloc];
    });
    
}

- (JKKVOHelperItem *)jk_IsContainObserver:(NSObject *)observer andKeyPath:(NSString *)keyPath
{
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        id itemObserver = [self jk_objectWithAddressStr:item.observerAddress];
        if ([itemObserver isEqual:observer] && [item.keyPath isEqualToString:keyPath]) {
            return item;
        }
    }
    return nil;
}

- (void)jk_removeKVOHelperItemWithObserver:(NSObject *)observer andKeyPath:(NSString *)keyPath
{
    NSArray *jk_kvoHelperItems = [self.jk_kvoHelperItems allObjects];
    for (JKKVOHelperItem *item in jk_kvoHelperItems) {
        id itemObserver = [self jk_objectWithAddressStr:item.observerAddress];
        if ([itemObserver isEqual:observer] && [item.keyPath isEqualToString:keyPath]) {
            [self.jk_kvoHelperItems removeObject:item];
            break;
        }
    }
}


/**
 根据内存地址转换对应的对象

 @param addressStr 内存地址
 @return 转换后的对象
 */
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
- (id)jk_objectWithAddressStr:(NSString *)addressStr
{
    addressStr = [addressStr hasPrefix:@"0x"] ? addressStr : [@"0x" stringByAppendingString:addressStr];
    uintptr_t hex = strtoull(addressStr.UTF8String, NULL, 0);
    id object = (__bridge id)(void *)hex;
    return object;
}
#pragma clang diagnostic pop

/**
 实例方法替换
 
 @param fdClass class
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)jk_exchangeInstanceMethod:(Class)fdClass
                   originalSel:(SEL)originalSel
                   swizzledSel:(SEL)swizzledSel
{
    Method originalMethod = class_getInstanceMethod(fdClass, originalSel);
    Method swizzledMethod = class_getInstanceMethod(fdClass, swizzledSel);
    
    // 这里用这个方法做判断，看看origin方法是否有实现，如果没实现，直接用我们自己的方法，如果有实现，则进行交换
    BOOL isAddMethod =
    class_addMethod(fdClass,
                    originalSel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (isAddMethod) {
        class_replaceMethod(fdClass,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
