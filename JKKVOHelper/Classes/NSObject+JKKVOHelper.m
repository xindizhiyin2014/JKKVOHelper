//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import "JKKVOItemManager.h"

@implementation NSObject (JKKVOHelper)

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
    if (!observer || !keyPath || !block) {
        return;
    }
    [JKKVOItemManager lock];
    if (![JKKVOItemManager isContainItemWithObserver:observer
                                          observered:self
                                             keyPath:keyPath
                                             context:context]) {
        [self jk_exchangeMethodWithObserver:observer];
        JKKVOItem *item = [JKKVOItem new];
        item.observerAddress = [NSString stringWithFormat:@"%p",observer];
        item.observered = self;
        item.keyPath = keyPath;
        item.block = block;
        item.context = context;
        [JKKVOItemManager addItem:item];
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
        
    }
    [JKKVOItemManager unLock];
}

- (void)jk_addObserver:(NSObject *)observer
           forKeyPaths:(NSArray <NSString *>*)keyPaths
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
       withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
 if (!observer || !keyPaths || keyPaths.count == 0 || !detailBlock) {
        return;
    }
    [JKKVOItemManager lock];
    for (NSString *keyPath in keyPaths) {
        if (![JKKVOItemManager isContainItemWithObserver:observer
                                              observered:self
                                                 keyPath:keyPath
                                                 context:context]) {
            [self jk_exchangeMethodWithObserver:observer];
            JKKVOItem *item = [JKKVOItem new];
            item.observerAddress = [NSString stringWithFormat:@"%p",observer];
            item.observered = self;
            item.keyPath = keyPath;
            item.detailBlock = detailBlock;
            item.context = context;
            [JKKVOItemManager addItem:item];
            [self addObserver:observer forKeyPath:keyPath options:options context:context];
        }
    }
    
    [JKKVOItemManager unLock];
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
    [JKKVOItemManager unLock];
    if (item) {
        [self removeObserver:observer forKeyPath:keyPath context:context];
    }
    
}

- (void)jk_removeObserver:(NSObject *)observer
              forKeyPaths:(NSArray <NSString *>*)keyPaths
{
    for (NSString *keyPath in keyPaths) {
        [JKKVOItemManager lock];
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
        [JKKVOItemManager unLock];
        for (JKKVOItem *item in items) {
            id observer = [JKKVOItemManager objectWithAddressStr:item.observerAddress];
            if (observer) {
              [self jk_removeObserver:observer forKeyPath:item.keyPath context:item.context];
            } else {
              [JKKVOItemManager lock];
              [JKKVOItemManager removeItem:item];
              [JKKVOItemManager unLock];
            }
        }
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
        [JKKVOItemManager unLock];
         for (JKKVOItem *item in items) {
             if ([item.keyPath isEqualToString:keyPath]) {
                 id observer = [JKKVOItemManager objectWithAddressStr:item.observerAddress];
                 if (observer) {
                   [self jk_removeObserver:observer forKeyPath:item.keyPath context:item.context];
                 } else {
                   [JKKVOItemManager lock];
                   [JKKVOItemManager removeItem:item];
                   [JKKVOItemManager unLock];
                 }
             }
         }
    } else {
        for (NSObject *observer in observers) {
            [JKKVOItemManager lock];
            NSArray <JKKVOItem *>* items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
            [JKKVOItemManager unLock];
            for (JKKVOItem *item in items) {
                id observer = [JKKVOItemManager objectWithAddressStr:item.observerAddress];
                if (observer) {
                  [self jk_removeObserver:observer forKeyPath:item.keyPath context:item.context];
                } else {
                  [JKKVOItemManager lock];
                  [JKKVOItemManager removeItem:item];
                  [JKKVOItemManager unLock];
                }
            }
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

- (void)jk_removeObservereds
{
    NSArray *observereds = [self jk_observereds];
    for (NSObject *observered in observereds) {
        NSArray *keyPaths = [observered jk_keyPathsObserveredBy:self];
        [observered jk_removeObserver:self forKeyPaths:keyPaths];
    }
}

- (NSArray *)jk_observers
{
    [JKKVOItemManager lock];
    NSArray *observers = [JKKVOItemManager observersOfObserered:self];
    [JKKVOItemManager unLock];
    return observers;
}

- (NSArray *)jk_observereds
{
   [JKKVOItemManager lock];
    NSArray *observereds = [JKKVOItemManager observeredsOfObserver:self];
    [JKKVOItemManager unLock];
    return observereds;
}

- (NSArray *)jk_observeredKeyPaths
{
    [JKKVOItemManager lock];
    NSArray *keyPaths = [JKKVOItemManager observeredKeyPathsOfObservered:self];
    [JKKVOItemManager unLock];
    return keyPaths;
}

- (NSArray *)jk_observersForKeyPath:(NSString *)keyPath
{
    [JKKVOItemManager lock];
    NSArray *observers = [JKKVOItemManager observersOfObserered:self keyPath:keyPath];
    [JKKVOItemManager unLock];
    return observers;
}

- (NSArray *)jk_keyPathsObserveredBy:(NSObject *)observer
{
    [JKKVOItemManager lock];
    NSArray *keyPaths = [JKKVOItemManager observeredKeyPathsOfObserered:self observer:observer];
    [JKKVOItemManager unLock];
    return keyPaths;
}

- (void)jkhook_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSObject class]]) {
        NSObject *observeredObject = (NSObject *)object;
        BOOL isContain = [JKKVOItemManager isContainItemWithObserver:self observered:observeredObject];
        if (isContain) {
           JKKVOItem *item = [JKKVOItemManager isContainItemWithObserver:self observered:observeredObject keyPath:keyPath context:context];

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
        } else{
            [self jkhook_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }else{
        [self jkhook_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)jkhook_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context
{
    
    if ([JKKVOItemManager obseverMethodHasExchangedOfObserver:self]) {
        JKKVOItem *item = [JKKVOItemManager isContainItemWithObserver:observer observered:self keyPath:keyPath context:context];
        if (item) {
            [JKKVOItemManager lock];
            [JKKVOItemManager removeItem:item];
            [self jkhook_removeObserver:observer forKeyPath:keyPath context:context];
            [JKKVOItemManager unLock];
        }
    } else {
        [self jkhook_removeObserver:observer forKeyPath:keyPath context:context];
    }
    
}

- (void)jkhook_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    
    if ([JKKVOItemManager obseverMethodHasExchangedOfObserver:self]) {
        JKKVOItem *item = [JKKVOItemManager isContainItemWithObserver:observer observered:self keyPath:keyPath context:nil];
        if (item) {
            [JKKVOItemManager lock];
            [JKKVOItemManager removeItem:item];
            [self jkhook_removeObserver:observer forKeyPath:keyPath];
            [JKKVOItemManager unLock];
        }
    } else {
        [self jkhook_removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)jkhook_dealloc
{
    if ([JKKVOItemManager obseverMethodHasExchangedOfObserver:self]) {
       [self jk_removeObservereds];
       [self jkhook_dealloc];
    }else {
       [self jkhook_dealloc];
    }
}

#pragma mark - private method
- (void)jk_exchangeMethodWithObserver:(NSObject *)observer
{
    
    if (![JKKVOItemManager obseverMethodHasExchangedOfObserver:observer]) {
       Class class = [observer class];
        SEL observeValueForKeyPath = @selector(observeValueForKeyPath:ofObject:change:context:);
        SEL jk_ObserveValueForKeyPath = @selector(jkhook_observeValueForKeyPath:ofObject:change:context:);
        [JKKVOItemManager jk_exchangeInstanceMethod:class originalSel:observeValueForKeyPath swizzledSel:jk_ObserveValueForKeyPath];
        
        SEL observeredDealloc = NSSelectorFromString(@"dealloc");
        SEL jk_observerdDealloc = NSSelectorFromString(@"jkhook_dealloc");
        [JKKVOItemManager jk_exchangeInstanceMethod:class originalSel:observeredDealloc swizzledSel:jk_observerdDealloc];
        SEL removeObserver1 = NSSelectorFromString(@"removeObserver:forKeyPath:");
        SEL jk_removeObserver1 = NSSelectorFromString(@"jkhook_removeObserver:forKeyPath:");
        [JKKVOItemManager jk_exchangeInstanceMethod:class originalSel:removeObserver1 swizzledSel:jk_removeObserver1];
        SEL removeObserver2 = NSSelectorFromString(@"removeObserver:forKeyPath:context:");
        SEL jk_removeObserver2 = NSSelectorFromString(@"jkhook_removeObserver:forKeyPath:context:");
        [JKKVOItemManager jk_exchangeInstanceMethod:class originalSel:removeObserver2 swizzledSel:jk_removeObserver2];
    }
}



@end
