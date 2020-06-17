//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import <objc/runtime.h>
#import "JKKVOItem.h"

static const void *is_jk_observeredKey = &is_jk_observeredKey;
static const void *is_jk_deallocedKey = "is_jk_deallocedKey";


@implementation NSObject (JKKVOHelper)
+ (void)load
{
   [self jk_exchangeDeallocMethod];
}
#pragma mark - - setter - -
- (void)setIs_jk_observered:(BOOL)is_jk_observered
{
    objc_setAssociatedObject(self, is_jk_observeredKey, @(is_jk_observered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIs_jk_dealloced:(BOOL)is_jk_dealloced
{
   objc_setAssociatedObject(self, is_jk_deallocedKey, @(is_jk_dealloced), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - - getter - -
- (BOOL)is_jk_observered
{
    return [objc_getAssociatedObject(self, is_jk_observeredKey) boolValue];
}

- (BOOL)is_jk_dealloced
{
   return [objc_getAssociatedObject(self, is_jk_deallocedKey) boolValue];
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
    if (![JKKVOItemManager isContainItemWithObserver:observer
                                          observered:self
                                             keyPath:keyPath
                                             context:context]) {
        [JKKVOItemManager lock];
        [self setIs_jk_observered:YES];
        JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
        void(^realBlock)(NSString *keyPath, NSDictionary *change, void *context) = ^(NSString *keyPath, NSDictionary *change, void *context){
            if (block) {
                block(change,context);
            }
        };
        JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath context:context block:realBlock];
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
    for (NSString *keyPath in keyPaths) {
        if (![JKKVOItemManager isContainItemWithObserver:observer
                                              observered:self
                                                 keyPath:keyPath
                                                 context:context]) {
            [JKKVOItemManager lock];
            [self setIs_jk_observered:YES];
            JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
            JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath context:context block:detailBlock];
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

- (void)jk_addObserverOfArrayForKeyPath:(NSString *)keyPath
                                options:(NSKeyValueObservingOptions)options
                                context:(nullable void *)context
                              withBlock:(void (^)(NSString *keyPath, NSDictionary *change,JKKVOArrayChangeModel *changedModel, void *context))block
{
    [self jk_addObserverOfArrayForKeyPath:keyPath options:options context:context elementKeyPaths:nil withBlock:block];
}

- (void)jk_addObserverOfArrayForKeyPath:(NSString *)keyPath
                                options:(NSKeyValueObservingOptions)options
                                context:(nullable void *)context
                        elementKeyPaths:(nullable NSArray <NSString *>*)elementKeyPaths
                              withBlock:(void (^)(NSString *keyPath, NSDictionary *change,JKKVOArrayChangeModel *changedModel, void *context))block
{
    [self jk_addObserverOfArray:self keyPath:keyPath options:options context:context elementKeyPaths:elementKeyPaths withBlock:block];
}

- (void)jk_addObserverOfArray:(__kindof NSObject *)observer
                      keyPath:(NSString *)keyPath
                      options:(NSKeyValueObservingOptions)options
                      context:(nullable void *)context
              elementKeyPaths:(nullable NSArray <NSString *>*)elementKeyPaths
                    withBlock:(void (^)(NSString *keyPath, NSDictionary *change,JKKVOArrayChangeModel *changedModel, void *context))block
{
    if (!observer || !keyPath || !block) {
        return;
    }
    if (![JKKVOItemManager isContainArrayItemWithObserver:observer
                                         observered:self
                                            keyPath:keyPath
                                            context:context]) {
       [JKKVOItemManager lock];
       [self setIs_jk_observered:YES];
       JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:observer];
       NSArray *observered_property = [self valueForKeyPath:keyPath];
        if (observered_property
            && ![observered_property isKindOfClass:[NSArray class]]) {
            NSAssert(NO, @"make sure [observered_property isKindOfClass:[NSArray class]] be YES");
            return;
        }
            
       JKKVOArrayItem *item = [JKKVOArrayItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath context:context options:options observered_property:observered_property elementKeyPaths:elementKeyPaths detailBlock:block];
       [JKKVOItemManager addItem:item];
       [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
        NSArray *elements = [observered_property copy];
        for (NSObject *element in elements) {
           [item addObserverOfElement:element];
        }
       [JKKVOItemManager unLock];
   }
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
        if ([item isKindOfClass:[JKKVOArrayItem class]]) {
            JKKVOArrayItem *arrayItem = (JKKVOArrayItem *)item;
            for (__kindof NSObject *element in arrayItem.observered_property) {
                [arrayItem removeObserverOfElement:element];
            }
        }
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
    if (![self is_jk_dealloced]) {
        [self setIs_jk_dealloced:YES];
        if ([self is_jk_observered]) {
            [self setIs_jk_observered:NO];
            [self jk_dealloc_removeObservers];
            [self jkhook_dealloc];
        } else {
          [self jkhook_dealloc];
        }
    }
}

- (void)jk_remove_kvoObserverWithItem:(JKKVOItem *)item
{
    if (!item) {
        return;
    }
    [JKKVOItemManager lock];
    [self removeObserver:item.kvoObserver forKeyPath:item.keyPath context:item.context];
    if ([item isKindOfClass:[JKKVOArrayItem class]]) {
        JKKVOArrayItem *arrayItem = (JKKVOArrayItem *)item;
        for (__kindof NSObject *element in arrayItem.observered_property) {
            [arrayItem removeObserverOfElement:element];
        }
    }
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
