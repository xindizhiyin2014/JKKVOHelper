//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import "JKKVOItemManager.h"
#import <objc/runtime.h>
static const void *is_jk_observeredKey = &is_jk_observeredKey;

@implementation NSObject (JKKVOHelper)

#pragma mark - - setter - -
- (void)setIs_jk_observered:(BOOL)is_jk_observered
{
    objc_setAssociatedObject(self, is_jk_observeredKey, @(is_jk_observered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - - getter - -
- (BOOL)is_jk_observered
{
    return [objc_getAssociatedObject(self, is_jk_observeredKey) boolValue];
}
- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
             withBlock:(void(^)(NSDictionary *change, void *context))block
{
    [self jk_addObserver:observer forKeyPath:keyPath options:options context:nil withBlock:block];
}

- (void)jk_addObserver:(__kindof NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
             withBlock:(void(^)(NSDictionary *change, void *context))block
{
    if (!observer || !keyPath || !block) {
        return;
    }
    [self jk_exchangeDeallocMethod];
    if (![JKKVOItemManager isContainItemWithObserver:observer
                                          observered:self
                                             keyPath:keyPath
                                             context:context]) {
        [JKKVOItemManager lock];
        [self setIs_jk_observered:YES];
        JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
        JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self observered_property:[self valueForKeyPath:keyPath] keyPath:keyPath context:context block:block detailBlock:nil];
        [JKKVOItemManager addItem:item];
        [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
        [JKKVOItemManager unLock];
    }
}

- (void)jk_addObserver:(__kindof NSObject *)observer
           forKeyPaths:(NSArray <NSString *>*)keyPaths
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
       withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    if (!observer || !keyPaths || keyPaths.count == 0 || !detailBlock) {
        return;
    }
    [self jk_exchangeDeallocMethod];
    for (NSString *keyPath in keyPaths) {
        if (![JKKVOItemManager isContainItemWithObserver:observer
                                              observered:self
                                                 keyPath:keyPath
                                                 context:context]) {
            [JKKVOItemManager lock];
            [self setIs_jk_observered:YES];
            JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
            JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self observered_property:[self valueForKeyPath:keyPath] keyPath:keyPath context:context block:nil detailBlock:detailBlock];
            [JKKVOItemManager addItem:item];
            [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
            [JKKVOItemManager unLock];
        }
    }
    
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

- (void)jk_removeObserver:(__kindof NSObject *)observer
               forKeyPath:(NSString *)keyPath
{
    [self jk_removeObserver:observer forKeyPath:keyPath context:nil];
}

- (void)jk_removeObserver:(__kindof NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  context:(nullable void *)context
{
  if (!keyPath || !observer) {
        return;
    }
    JKKVOItem *item = [JKKVOItemManager isContainItemWithObserver:observer
                                                       observered:self
                                                          keyPath:keyPath
                                                          context:context];
    if (item) {
        [JKKVOItemManager lock];
        [self removeObserver:item.kvoObserver forKeyPath:keyPath context:context];
        [JKKVOItemManager removeItem:item];
        [JKKVOItemManager unLock];
    }
}

- (void)jk_removeObserver:(__kindof NSObject *)observer
              forKeyPaths:(NSArray <NSString *>*)keyPaths
{
    for (NSString *keyPath in keyPaths) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
        for (JKKVOItem *item in items) {
              [self jk_remove_kvoObserverWithItem:item];
        }
    }
}

- (void)jk_removeObservers:(NSArray <__kindof NSObject *>*)observers
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
                 [self jk_remove_kvoObserverWithItem:item];
             }
         }
    } else {
        for (NSObject *observer in observers) {
            NSArray <JKKVOItem *>* items = [JKKVOItemManager itemsWithObserver:observer observered:self keyPath:keyPath];
            for (JKKVOItem *item in items) {
                [self jk_remove_kvoObserverWithItem:item];
            }
        }

    }
}

- (void)jk_removeObservers
{
    NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered:self];
    for (JKKVOItem *item in items) {
        [self jk_remove_kvoObserverWithItem:item];
    }
}

- (NSArray <NSString *>*)jk_observeredKeyPaths
{
    NSArray <NSString *>*keyPaths = [JKKVOItemManager observeredKeyPathsOfObservered:self];
    return keyPaths;
}

- (NSArray <NSObject *>*)jk_observersOfKeyPath:(NSString *)keyPath
{
    NSArray <__kindof NSObject *>*observers = [JKKVOItemManager observersOfObservered:self keyPath:keyPath];
    return observers;
}

- (NSArray <NSString *>*)jk_keyPathsObserveredBy:(__kindof NSObject *)observer
{
    NSArray *keyPaths = [JKKVOItemManager observeredKeyPathsOfObserered:self observer:observer];
    return keyPaths;
}

#pragma mark - - private method - -

- (void)jkhook_dealloc
{
    if ([self is_jk_observered] ) {
        [self jk_dealloc_removeObservers];
        [self jkhook_dealloc];
    } else {
      [self jkhook_dealloc];
    }
}

- (void)jk_remove_kvoObserverWithItem:(JKKVOItem *)item
{
    if (!item) {
        return;
    }
    [JKKVOItemManager lock];
    [self removeObserver:item.kvoObserver forKeyPath:item.keyPath context:item.context];
    [JKKVOItemManager removeItem:item];
    [JKKVOItemManager unLock];
}

- (void)jk_dealloc_removeObservers
{
    NSArray <JKKVOItem *>*items = [JKKVOItemManager dealloc_itemsOfObservered:self];
    for (JKKVOItem *item in items) {
        [self jk_remove_kvoObserverWithItem:item];
    }
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
