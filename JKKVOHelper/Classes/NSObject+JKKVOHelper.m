//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import <objc/runtime.h>

@interface JKKVOHelperItem : NSObject

@property (nonatomic, weak) NSObject *observer;                                 ///< 观察者
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
static NSMutableSet *jk_onceTokenSet = nil;

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
        item.observer = observer;
        item.keyPath = keyPath;
        item.block = block;
        [self.jk_kvoHelperItems addObject:item];
        [observer jk_exchangeMethod];
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
    for (NSObject *observer in observers) {
        [self jk_removeObserver:observer forKeyPath:keyPath];
    }
}

- (NSArray *)jk_observers
{
    NSMutableArray *observers = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        [observers addObject:item.observer];
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
            [observers addObject:item.observer];
        }
    }
    return [observers copy];
}

- (NSArray *)jk_keyPathsObserveredBy:(NSObject *)observer
{
    NSMutableArray *keyPaths = [NSMutableArray new];
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        if ([item.observer isEqual:observer]) {
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
- (void)jk_exchangeMethod
{
    if (!jk_onceTokenSet) {
        jk_onceTokenSet = [NSMutableSet new];
    }
    dispatch_once_t onceToken = 0;
    if (![jk_onceTokenSet containsObject:NSStringFromClass([self class])]) {
        [jk_onceTokenSet addObject:NSStringFromClass([self class])];
    } else {
        onceToken = -1;
    }
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL observeValueForKeyPath = @selector(observeValueForKeyPath:ofObject:change:context:);
        SEL jk_ObserveValueForKeyPath = @selector(jk_observeValueForKeyPath:ofObject:change:context:);
        [NSObject jk_exchangeInstanceMethod:class originalSel:observeValueForKeyPath swizzledSel:jk_ObserveValueForKeyPath];
    });
}

- (JKKVOHelperItem *)jk_IsContainObserver:(NSObject *)observer andKeyPath:(NSString *)keyPath
{
    for (JKKVOHelperItem *item in self.jk_kvoHelperItems) {
        if ([item.observer isEqual:observer] && [item.keyPath isEqualToString:keyPath]) {
            return item;
        }
    }
    return nil;
}

- (void)jk_removeKVOHelperItemWithObserver:(NSObject *)observer andKeyPath:(NSString *)keyPath
{
    NSArray *jk_kvoHelperItems = [self.jk_kvoHelperItems allObjects];
    for (JKKVOHelperItem *item in jk_kvoHelperItems) {
        if ([item.observer isEqual:observer] && [item.keyPath isEqualToString:keyPath]) {
            [self.jk_kvoHelperItems removeObject:item];
            break;
        }
    }
}

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
