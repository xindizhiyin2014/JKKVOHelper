//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import "JKKVOItemManager.h"
#import <objc/runtime.h>
static const void *is_jk_observerKey = &is_jk_observerKey;

@implementation NSObject (JKKVOHelper)

#pragma mark - - setter - -
- (void)setIs_jk_observer:(BOOL)is_jk_observer
{
    objc_setAssociatedObject(self, is_jk_observerKey, @(is_jk_observer), OBJC_ASSOCIATION_RETAIN);
}
#pragma mark - - getter - -
- (BOOL)is_jk_observer
{
    return [objc_getAssociatedObject(self, is_jk_observerKey) boolValue];
}
- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
             withBlock:(void(^)(NSDictionary *change, void *context))block
{
    [self jk_addObserver:observer forKeyPath:keyPath options:options context:nil withBlock:block];
}

- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
             withBlock:(void(^)(NSDictionary *change, void *context))block
{
    [self jk_exchangeDeallocMethod];
    if (!observer || !keyPath || !block) {
        return;
    }
    [JKKVOItemManager lock];
    if (![JKKVOItemManager isContainItemWithObserver:observer
                                          observered:self
                                             keyPath:keyPath
                                             context:context]) {
        [observer setIs_jk_observer:YES];
        JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
        JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath context:context block:block detailBlock:nil];
        [JKKVOItemManager addItem:item];
        [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
        
    }
    [JKKVOItemManager unLock];
}

- (void)jk_addObserver:(NSObject *)observer
           forKeyPaths:(NSArray <NSString *>*)keyPaths
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
       withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    [self jk_exchangeDeallocMethod];
    if (!observer || !keyPaths || keyPaths.count == 0 || !detailBlock) {
        return;
    }
    
    [JKKVOItemManager lock];
    for (NSString *keyPath in keyPaths) {
        if (![JKKVOItemManager isContainItemWithObserver:observer
                                              observered:self
                                                 keyPath:keyPath
                                                 context:context]) {
            [observer setIs_jk_observer:YES];
            JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
            JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath context:context block:nil detailBlock:detailBlock];
            [JKKVOItemManager addItem:item];
            [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
        }
    }
    
    [JKKVOItemManager unLock];
}

- (void)jk_addObserverForKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                       withBlock:(void(^)(NSDictionary *change, void *context))block
{
    [self jk_addObserver:self forKeyPath:keyPath options:options withBlock:block];
}

- (void)jk_addObserverForKeyPaths:(NSArray <NSString *>*)keyPaths
                          options:(NSKeyValueObservingOptions)options
                          context:(nullable void *)context
                  withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    [self jk_addObserver:self forKeyPaths:keyPaths options:options context:context withDetailBlock:detailBlock];
}

- (void)jk_addObserverForKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(nullable void *)context
                       withBlock:(void(^)(NSDictionary *change, void *context))block
{
    [self jk_addObserver:self forKeyPath:keyPath options:options context:context withBlock:block];
}

- (void)jk_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
{
    [self jk_removeObserver:observer forKeyPath:keyPath context:nil];
}

- (void)jk_removeObserver:(NSObject *)observer
forKeyPath:(NSString *)keyPath
   context:(nullable void *)context
{
  if (!keyPath || !observer) {
        return;
    }
    [JKKVOItemManager lock];
    JKKVOItem *item = [JKKVOItemManager isContainItemWithObserver:observer
                                                       observered:self
                                                          keyPath:keyPath
                                                          context:context];
    if (item) {
        [self removeObserver:item.kvoObserver forKeyPath:keyPath context:context];
        [JKKVOItemManager removeItem:item];
    }
    [JKKVOItemManager unLock];
}

- (void)jk_removeObserver:(NSObject *)observer
              forKeyPaths:(NSArray <NSString *>*)keyPaths
{
    for (NSString *keyPath in keyPaths) {
        [JKKVOItemManager lock];
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
        for (JKKVOItem *item in [items mutableCopy]) {
              [self jk_remove_kvoObserverWithItem:item];
        }
        [JKKVOItemManager unLock];

    }
}

- (void)jk_removeObservers:(NSArray <NSObject *>*)observers
                forKeyPath:(NSString *)keyPath
{
    if (!keyPath) {
        return;
    }
    if (!observers) {
        [JKKVOItemManager lock];
        NSArray *items = [JKKVOItemManager items];
         for (JKKVOItem *item in [items mutableCopy]) {
             if ([item.keyPath isEqualToString:keyPath]) {
                 [self jk_remove_kvoObserverWithItem:item];
             }
         }
        [JKKVOItemManager unLock];
    } else {
        [JKKVOItemManager lock];
        for (NSObject *observer in observers) {
            NSArray <JKKVOItem *>* items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
            for (JKKVOItem *item in [items mutableCopy]) {
                [self jk_remove_kvoObserverWithItem:item];
            }
        }
        [JKKVOItemManager unLock];

    }
}

- (void)jk_removeObservers
{
    NSArray <JKKVOItem *>*items = [self jk_observerItems];
    for (JKKVOItem *item in [items mutableCopy]) {
        NSArray *keyPaths = [self jk_keyPathsObserveredBy:item.kvoObserver];
        [self jk_remove_kvoObserverWithItem:item forKeyPaths:keyPaths];
    }
}

- (NSArray <NSString *>*)jk_observeredKeyPaths
{
    [JKKVOItemManager lock];
    NSArray <NSString *>*keyPaths = [JKKVOItemManager observeredKeyPathsOfObservered:self];
    [JKKVOItemManager unLock];
    return keyPaths;
}

- (NSArray <NSString *>*)jk_keyPathsObserveredBy:(NSObject *)observer
{
    [JKKVOItemManager lock];
    NSArray *keyPaths = [JKKVOItemManager observeredKeyPathsOfObserered:self observer:observer];
    [JKKVOItemManager unLock];
    return keyPaths;
}

#pragma mark - - private method - -

- (void)jkhook_dealloc
{
    if ([self is_jk_observer] ) {
        [self jk_removeObserveredItems];
        [self jkhook_dealloc];
    } else {
      [self jkhook_dealloc];
    }
}

- (void)jk_remove_kvoObserverWithItem:(JKKVOItem *)item
                          forKeyPaths:(NSArray <NSString *>*)keyPaths
{
    [JKKVOItemManager lock];
    for (NSString *keyPath in keyPaths) {
        if ([item.keyPath isEqualToString:keyPath]) {
            [self jk_remove_kvoObserverWithItem:item];
        }
    }
    [JKKVOItemManager unLock];
}

- (void)jk_remove_kvoObserverWithItem:(JKKVOItem *)item
{
  if (!item) {
        return;
    }
    [self removeObserver:item.kvoObserver forKeyPath:item.keyPath context:item.context];
    [JKKVOItemManager removeItem:item];
    
}

- (NSArray <JKKVOItem *>*)jk_observerItemsForKeyPath:(NSString *)keyPath
{
    [JKKVOItemManager lock];
    NSArray <JKKVOItem *>*items = [JKKVOItemManager observerItemsOfObserered:self keyPath:keyPath];
    [JKKVOItemManager unLock];
    return items;
}

- (void)jk_removeObserveredItems
{
    NSArray <JKKVOItem *>*items = [self jk_observeredItems];
    for (JKKVOItem *item in [items mutableCopy]) {
        if (item.observered) {
            [item.observered jk_remove_kvoObserverWithItem:item];
        } else {
            [JKKVOItemManager removeItem:item];
        }
        
    }
}

- (NSArray <JKKVOItem *>*)jk_observerItems;
{
    [JKKVOItemManager lock];
    NSArray <JKKVOItem *>*items = [JKKVOItemManager observerItemsOfObserered:self];
    [JKKVOItemManager unLock];
    return items;
}

- (NSArray <JKKVOItem *>*)jk_observeredItems
{
   [JKKVOItemManager lock];
    NSArray <JKKVOItem *>*items = [JKKVOItemManager observeredItemsOfObserver:self];
    [JKKVOItemManager unLock];
    return items;
}

- (void)jk_exchangeDeallocMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL observeredDealloc = NSSelectorFromString(@"dealloc");
        SEL jk_observerdDealloc = NSSelectorFromString(@"jkhook_dealloc");
        [JKKVOItemManager jk_exchangeInstanceMethod:[NSObject class] originalSel:observeredDealloc swizzledSel:jk_observerdDealloc];
    });
}

@end
