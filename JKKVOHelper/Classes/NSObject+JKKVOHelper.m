//
//  NSObject+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import "NSObject+JKKVOHelper.h"
#import <objc/runtime.h>
#import "JKKVOItem.h"
#import "JKKVOHelperMacro.h"
#import <objc/message.h>

static const void *is_jk_observeredKey = &is_jk_observeredKey;
static const void *is_jk_deallocedKey = "is_jk_deallocedKey";
static const void *is_jk_computedKey = "is_jk_computedKey";

static NSString *const JKComputedPrefix = @"JKComputed_";

@interface NSObject()

@property (nonatomic, assign) BOOL is_jk_observered;
@property (nonatomic, assign) BOOL is_jk_dealloced;
@property (nonatomic, assign) BOOL is_jk_computed;

@end

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

- (void)setIs_jk_computed:(BOOL)is_jk_computed
{
   objc_setAssociatedObject(self, is_jk_computedKey, @(is_jk_computed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (BOOL)is_jk_computed
{
    return [objc_getAssociatedObject(self, is_jk_computedKey) boolValue];
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
    if (!observer || !keyPath || keyPath.length == 0 || !block) {
#if DEBUG
        NSAssert(NO, @"params error,please check");
#endif
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
        JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath options:options context:context block:realBlock];
        [JKKVOItemManager addItem:item];
        [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
        [JKKVOItemManager unLock];
    } else {
#if DEBUG
        NSAssert(NO, @"add duplicate observer,please check");
#endif
    }
}

- (void)jk_addObserver:(__kindof NSObject *)observer
           forKeyPaths:(NSArray <NSString *>*)keyPaths
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
       withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock
{
    if (!observer || !keyPaths || keyPaths.count == 0 || !detailBlock) {
#if DEBUG
        NSAssert(NO, @"params error,please check");
#endif
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
            JKKVOItem *item = [JKKVOItem initWith_kvoObserver:kvoObserver observered:self keyPath:keyPath options:options  context:context block:detailBlock];
            [JKKVOItemManager addItem:item];
            [self addObserver:kvoObserver forKeyPath:keyPath options:options context:context];
            [JKKVOItemManager unLock];
        } else {
#if DEBUG
           NSAssert(NO, @"add duplicate observer,please check");
#endif
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
    if (!observer || !keyPath || keyPath.length == 0 || !block) {
#if DEBUG
        NSAssert(NO, @"params error,please check");
#endif
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
   }  else {
#if DEBUG
      NSAssert(NO, @"add duplicate observer,please check");
#endif
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
  if (!keyPath || keyPath.length == 0 || !observer) {
        return;
    }
    JKBaseKVOItem *item = [JKKVOItemManager isContainItemWithObserver:observer
                                                       observered:self
                                                          keyPath:keyPath
                                                          context:context];
    if (item) {
        [self jk_remove_kvoObserverWithItem:item];
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

- (void)jk_removeObservers:(nullable NSArray <__kindof NSObject *>*)observers
                forKeyPath:(NSString *)keyPath
{
    if (!keyPath) {
        return;
    }
    if (!observers) {
        [JKKVOItemManager lock];
        NSArray *items = [JKKVOItemManager itemsOfObservered:self];
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

- (void)jk_removeObserver:(__kindof NSObject *)observer
{
    NSArray <JKBaseKVOItem *>*items = [JKKVOItemManager itemsOfObserver:observer observered:self];
    for (JKBaseKVOItem *item in items) {
        [self jk_remove_kvoObserverWithItem:item];
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

- (NSDictionary <NSString *,NSArray *>*)jk_computedProperty_config
{
    return @{};
}

- (void)jk_initComputed
{
    if (!self.is_jk_computed) {
        self.is_jk_computed = YES;
        NSDictionary *computed_config = [self jk_computedProperty_config];
        @weakify(self);
        [self jk_addComputedObserverswithConfig:computed_config detailBlock:^(NSString *computedKey, NSString *dependentProperty) {
            @strongify(self);
            SEL getterSelector = NSSelectorFromString(computedKey);
            JKKVOComputedItem *computed_item = [JKKVOItemManager isContainComputedItemWithObserver:self observered:self keyPath:computedKey];
            computed_item.dirty = YES;
            jk_computed_getter(self, getterSelector);
        }];
        [self jk_configComputedSubClassWithConfig:computed_config];
    }
}

#pragma mark - - private method - -
- (void)jk_addComputedObserverswithConfig:(NSDictionary *)computed_config
                              detailBlock:(void(^)(NSString *computedKey, NSString *dependentProperty))detailBlock
{
    [JKKVOItemManager lock];
    [self setIs_jk_observered:YES];
    for (NSString *computedKey in [computed_config allKeys]) {
        NSArray *dependentProperties = computed_config[computedKey];
        JKKVOObserver *kvoObserver = [JKKVOObserver initWithOriginObserver:self];
        void(^realBlock)(NSString *keyPath, NSDictionary *change, void *context) = ^(NSString *keyPath, NSDictionary *change, void *context){
            if (detailBlock) {
                detailBlock(computedKey,keyPath);
            }
        };
        JKKVOComputedItem *computed_item = [JKKVOComputedItem initWith_kvoObserver:kvoObserver observered:self keyPath:computedKey dependentProperties:dependentProperties block:realBlock];
        [computed_item addDependentPropertiesObserver];
        objc_property_t property_t = class_getProperty(jk_originClass(self), [computedKey UTF8String]);
        NSString *attribute = [NSString stringWithFormat:@"%s", property_getAttributes(property_t)];
        NSArray *attributes = [attribute componentsSeparatedByString:@","];
        NSString *firstObject = attributes.firstObject;
        const char *valueType = [[firstObject substringFromIndex:1] UTF8String];
        computed_item.valueType = valueType;
        [JKKVOItemManager addItem:computed_item];
    }
    [JKKVOItemManager unLock];
}

/// 配置派生子类
- (void)jk_configComputedSubClassWithConfig:(NSDictionary *)computed_config
{
    for (NSString *computedKey in [computed_config allKeys]) {
          SEL getterSelector = NSSelectorFromString(computedKey);
          if (![self respondsToSelector:getterSelector]) {
#if DEBUG
               NSString *errorMsg = [NSString stringWithFormat:@"%@ not respond selector:%@",NSStringFromClass([self class]),computedKey];
               NSAssert(NO, errorMsg);
#endif
                return;
           }
        // 2. 检查对象 isa 指向的类是不是一个 KVO 类。如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类
        Class clazz = object_getClass(self);
        NSString *className = NSStringFromClass(clazz);
        
        if (![className hasPrefix:JKComputedPrefix]) {
            clazz = [self jk_computedClassWithOriginalClassName:className];
            object_setClass(self, clazz);
        }
        Class originClass = jk_originClass(self);
        Method getterMethod = class_getInstanceMethod(originClass, getterSelector);
        const char *getterTypes = method_getTypeEncoding(getterMethod);
        class_addMethod(clazz, getterSelector, (IMP)jk_computed_getter, getterTypes);
        
        NSArray <NSString *>*dependentProperties = computed_config[computedKey];
       for (NSString *dependentProperty in dependentProperties) {
             NSString *setterSelectorName = [self jk_setterForGetter:dependentProperty];
             SEL setterSelector = NSSelectorFromString(setterSelectorName);
             Method setterMethod = class_getInstanceMethod(originClass, setterSelector);
             const char *setterTypes = method_getTypeEncoding(setterMethod);
             class_addMethod(clazz, setterSelector, (IMP)jk_dependentProperty_setter, setterTypes);
       }
    }
}

- (Class)jk_computedClassWithOriginalClassName:(NSString *)className
{
    NSString *computedClassName = [JKComputedPrefix stringByAppendingString:className];
    Class computedClass = NSClassFromString(computedClassName);
    
    // 如果kvo class存在则返回
    if (computedClass) {
        return computedClass;
    }
    
    // 如果kvo class不存在, 则创建这个类
    computedClass = objc_allocateClassPair([self class], computedClassName.UTF8String, 0);
    Class originClass = jk_originClass(self);
    // 修改kvo class方法的实现
    Method clazzMethod = class_getInstanceMethod(originClass, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(computedClass, @selector(class), (IMP)jk_computed_class, types);
    objc_registerClassPair(computedClass);
    return computedClass;
    
}

static Class jk_originClass(id self)
{
    Class originClass = object_getClass(self);
    while ([NSStringFromClass(originClass) hasPrefix:JKComputedPrefix] || [NSStringFromClass(originClass) hasPrefix:@"NSKVONotifying_"]) {
        originClass = class_getSuperclass(originClass);
    }
    return originClass;
}

/**
 *  模仿Apple的做法, 欺骗人们这个kvo类还是原类
 */
static Class jk_computed_class(id self, SEL cmd)
{
    Class superClazz = jk_originClass(self);
    return superClazz;
}

/**
 *  重写setter方法, 新方法在调用原方法后, 通知每个观察者(调用传入的block)
 *  编码类型参考网址：https://blog.csdn.net/SSIrreplaceable/article/details/53376915
 */
static void *jk_computed_getter(NSObject* self, SEL _cmd)
{
    // 调用原类的setter方法
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = jk_originClass(self)
    };
    if (!self.is_jk_computed) {
       return ((void *(*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
    } else {
         NSString *getterName = NSStringFromSelector(_cmd);
         JKKVOComputedItem *computed_item = [JKKVOItemManager isContainComputedItemWithObserver:self observered:self keyPath:getterName];
        if (strstr(computed_item.valueType, "@")) {
            if (computed_item.dirty) {
                void *oldValue = computed_item.value;
                void *newValue = ((void* (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
                if (oldValue != newValue) {
                    computed_item.dirty = NO;
                    NSString *setterName = [self jk_setterForGetter:getterName];
                    void(^block)(void) = ^(void) {
                        computed_item.value = newValue;
                    };
                    jk_computedProperty_setter(self, NSSelectorFromString(setterName), newValue,block);
                }
            }
            return computed_item.value;
        } else {
            return jk_non_objc_getter(self, _cmd, computed_item, superClazz, getterName);
        }
    }
}

static void * jk_non_objc_getter(NSObject *self, SEL _cmd, JKKVOComputedItem *computed_item, struct objc_super superClazz, NSString *getterName)
{
//    if (strstr(computed_item.valueType, "{CGRect=")) {//CGRect
//        if (computed_item.dirty) {
//            NSValue *oldValue = computed_item.non_obj_value;
//            CGRect rect = ((CGRect (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//            NSValue *newValue = [NSValue valueWithCGRect:rect];
//            if (![oldValue isEqualToValue:newValue]) {
//                computed_item.dirty = NO;
//                NSString *setterName = [self jk_setterForGetter:getterName];
//                void(^block)(void) = ^(void) {
//                     computed_item.non_obj_value = newValue;
//                 };
//                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &rect, block);
//            }
//        }
//        CGRect rect = [computed_item.non_obj_value CGRectValue];
//        void *value = &rect;
//        return value;
//    }
    if (strstr(computed_item.valueType, "{CGSize=")) {//CGSize
        if (computed_item.dirty) {
            NSValue *oldValue = computed_item.non_obj_value;
            CGSize size = ((CGSize (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
            NSValue *newValue = [NSValue valueWithCGSize:size];
            if (![oldValue isEqualToValue:newValue]) {
                computed_item.dirty = NO;
                NSString *setterName = [self jk_setterForGetter:getterName];
                void(^block)(void) = ^(void) {
                    computed_item.non_obj_value = newValue;
                };
                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &size, block);
            }
        }
        CGSize size = [computed_item.non_obj_value CGSizeValue];
        void *value = &size;
        return value;
    }
    if (strstr(computed_item.valueType, "{CGPoint=")) {//CGPoint
        if (computed_item.dirty) {
            NSValue *oldValue = computed_item.non_obj_value;
            CGPoint point = ((CGPoint (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
            NSValue *newValue = [NSValue valueWithCGPoint:point];
            if (![oldValue isEqualToValue:newValue]) {
                computed_item.dirty = NO;
                NSString *setterName = [self jk_setterForGetter:getterName];
                void(^block)(void) = ^(void) {
                     computed_item.non_obj_value = newValue;
                 };
                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &point, block);
            }
        }
        CGPoint point = [computed_item.non_obj_value CGPointValue];
        void *value = &point;
        return value;
    }
//    if (strstr(computed_item.valueType, "{UIEdgeInsets=")) {//UIEdgeInsets
//        if (computed_item.dirty) {
//            NSValue *oldValue = computed_item.non_obj_value;
//            UIEdgeInsets edgeInsets = ((UIEdgeInsets (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//            NSValue *newValue = [NSValue valueWithUIEdgeInsets:edgeInsets];
//            if (![oldValue isEqualToValue:newValue]) {
//                computed_item.dirty = NO;
//                NSString *setterName = [self jk_setterForGetter:getterName];
//                void(^block)(void) = ^(void) {
//                    computed_item.non_obj_value = newValue;
//                };
//                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &edgeInsets, block);
//            }
//        }
//        UIEdgeInsets edgeInsets = [computed_item.non_obj_value UIEdgeInsetsValue];
//        void *value = &edgeInsets;
//        return value;
//    }
//    if (strstr(computed_item.valueType, "{CGAffineTransform=")) {//CGAffineTransform
//        if (computed_item.dirty) {
//            NSValue *oldValue = computed_item.non_obj_value;
//            CGAffineTransform transform = ((CGAffineTransform (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//            NSValue *newValue = [NSValue valueWithCGAffineTransform:transform];
//            if (![oldValue isEqualToValue:newValue]) {
//                computed_item.dirty = NO;
//                NSString *setterName = [self jk_setterForGetter:getterName];
//                void(^block)(void) = ^(void) {
//                     computed_item.non_obj_value = newValue;
//                 };
//                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &transform, block);
//            }
//        }
//        CGAffineTransform transform = [computed_item.non_obj_value CGAffineTransformValue];
//        void *value = &transform;
//        return value;
//    }
    if (strstr(computed_item.valueType, "{UIOffset=")) {//CGSize
        if (computed_item.dirty) {
            NSValue *oldValue = computed_item.non_obj_value;
            UIOffset offset = ((UIOffset (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
            NSValue *newValue = [NSValue valueWithUIOffset:offset];
            if (![oldValue isEqualToValue:newValue]) {
                computed_item.dirty = NO;
                NSString *setterName = [self jk_setterForGetter:getterName];
                void(^block)(void) = ^(void) {
                     computed_item.non_obj_value = newValue;
                 };
                jk_computedProperty_setter(self, NSSelectorFromString(setterName), &offset, block);
            }
        }
        UIOffset offset = [computed_item.non_obj_value UIOffsetValue];
        void *value = &offset;
        return value;
    }
    if (strstr(computed_item.valueType, "c")       //A char
        || strstr(computed_item.valueType, "i")    //An int
        || strstr(computed_item.valueType, "s")    //A short
        || strstr(computed_item.valueType, "l")    //A long is treated as a 32-bit quantity on 64-bit programs.
        || strstr(computed_item.valueType, "q")    //A long long
        || strstr(computed_item.valueType, "C")    //An unsigned char
        || strstr(computed_item.valueType, "I")    //An unsigned int
        || strstr(computed_item.valueType, "S")    //An unsigned short
        || strstr(computed_item.valueType, "L")    //An unsigned long
        || strstr(computed_item.valueType, "Q")    //An unsigned long long
        || strstr(computed_item.valueType, "B")    //A C++ bool or a C99 _Bool
        || strstr(computed_item.valueType, "*")    //A character string (char *)
        || strstr(computed_item.valueType, "#")    //A class object (Class)
        ) {
        if (computed_item.dirty) {
             void *oldValue = computed_item.value;
             void *newValue = ((void * (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
             if (oldValue != newValue) {
                 computed_item.dirty = NO;
                 NSString *setterName = [self jk_setterForGetter:getterName];
                 void(^block)(void) = ^(void) {
                      computed_item.value = newValue;
                  };
                 jk_computedProperty_setter(self, NSSelectorFromString(setterName), newValue, block);
             }
         }
        return computed_item.value;
    }
//    if (strstr(computed_item.valueType, "f")) {//A float
//        if (computed_item.dirty) {
//             NSValue *oldValue = computed_item.non_obj_value;
//             float floatValue = ((float (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//             NSNumber *newValue = [NSNumber numberWithFloat:floatValue];
//             if (![oldValue isEqualToValue:newValue]) {
//                 computed_item.dirty = NO;
//                 NSString *setterName = [self jk_setterForGetter:getterName];
//                 void(^block)(void) = ^(void) {
//                      computed_item.non_obj_value = newValue;
//                  };
//                 jk_computedProperty_setter(self, NSSelectorFromString(setterName), &floatValue, block);
//             }
//         }
//        float floatValue = [(NSNumber *)computed_item.non_obj_value floatValue];
//        void *value = &floatValue;
//        return value;
//    }
//    if (strstr(computed_item.valueType, "d")) {//A double
//        if (computed_item.dirty) {
//             NSValue *oldValue = computed_item.non_obj_value;
//             double doubleValue = ((double (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//             NSNumber *newValue = [NSNumber numberWithDouble:doubleValue];
//             if (![oldValue isEqualToValue:newValue]) {
//                 computed_item.dirty = NO;
//                 NSString *setterName = [self jk_setterForGetter:getterName];
//                 void(^block)(void) = ^(void) {
//                      computed_item.non_obj_value = newValue;
//                  };
//                 jk_computedProperty_setter(self, NSSelectorFromString(setterName), &doubleValue, block);
//             }
//         }
//        double doubleValue = [(NSNumber *)computed_item.non_obj_value doubleValue];
//        void *value = &doubleValue;
//        return value;
//    }
//    if (strstr(computed_item.valueType, ":")) {//A method selector (SEL)
//        if (computed_item.dirty) {
//             NSValue *oldValue = computed_item.non_obj_value;
//             SEL selValue = ((SEL (*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
//            NSValue *newValue = [NSValue value:&selValue withObjCType:computed_item.valueType];
//             if (![oldValue isEqualToValue:newValue]) {
//                 computed_item.dirty = NO;
//                 NSString *setterName = [self jk_setterForGetter:getterName];
//                 void(^block)(void) = ^(void) {
//                      computed_item.non_obj_value = newValue;
//                  };
//                 jk_computedProperty_setter(self, NSSelectorFromString(setterName), &selValue, block);
//             }
//         }
//        SEL selValue;
//        [computed_item.non_obj_value getValue:&selValue];
//        void *value = &selValue;
//        return value;
//    }
    return ((void *(*)(void *, SEL))objc_msgSendSuper)(&superClazz, _cmd);
}


/**
 *  重写setter方法,计算属性依赖的属性的setter方法
 */
static void jk_dependentProperty_setter(id self, SEL _cmd, void *newValue)
{
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = jk_originClass(self)
    };
    NSString *setterSelectorName = NSStringFromSelector(_cmd);
    NSString *getterName = [self jk_getterForSetter:setterSelectorName];
    NSArray <__kindof JKBaseKVOItem *>*items = [JKKVOItemManager itemsOfObservered:self keyPath:getterName];
    BOOL hasExternalObserver = NO;
    for (__kindof JKBaseKVOItem *item in items) {
        if (item.context != [JKKVOComputedItem computedObserverContext]) {
            hasExternalObserver = YES;
        }
    }
    if (hasExternalObserver) {
        ((void (*)(void *, SEL, typeof(newValue)))objc_msgSendSuper)(&superClazz, _cmd, newValue);
    } else {
        [self willChangeValueForKey:getterName];
        ((void (*)(void *, SEL, typeof(newValue)))objc_msgSendSuper)(&superClazz, _cmd, newValue);
        [self didChangeValueForKey:getterName];
    }
}

static void jk_computedProperty_setter(id self, SEL _cmd, void *newValue, void(^block)(void))
{
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = jk_originClass(self)
    };
    NSString *setterSelectorName = NSStringFromSelector(_cmd);
    NSString *getterName = [self jk_getterForSetter:setterSelectorName];
    NSArray <__kindof JKBaseKVOItem *>*items = [JKKVOItemManager itemsOfObservered:self keyPath:getterName];
    BOOL hasExternalObserver = NO;
    for (__kindof JKBaseKVOItem *item in items) {
        if (item.context != [JKKVOComputedItem computedObserverContext]) {
            hasExternalObserver = YES;
        }
    }
    if (hasExternalObserver) {
        [self willChangeValueForKey:getterName];
        ((void (*)(void *, SEL, typeof(newValue)))objc_msgSendSuper)(&superClazz, _cmd, newValue);
        if (block) {
            block();
        }
        [self didChangeValueForKey:getterName];
    } else {
        ((void (*)(void *, SEL, typeof(newValue)))objc_msgSendSuper)(&superClazz, _cmd, newValue);
        if (block) {
            block();
        }
    }
}

/**
 *  根据setter方法名返回getter方法名
 */
- (NSString *)jk_getterForSetter:(NSString *)key
{
    // setName: -> Name -> name
    
    // 1. 去掉set
    NSRange range = [key rangeOfString:@"set"];
    
    NSString *subStr1 = [key substringFromIndex:range.location + range.length];
    
    // 2. 首字母转换成大写
    unichar c = [subStr1 characterAtIndex:0];
    NSString *subStr2 = [subStr1 stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c", c+32]];
    
    // 3. 去掉最后的:
    NSRange range2 = [subStr2 rangeOfString:@":"];
    NSString *getter = [subStr2 substringToIndex:range2.location];
    
    return getter;
}
    
- (NSString *)jk_setterForGetter:(NSString *)key
{
    // name -> Name -> setName:
    
    // 1. 首字母转换成大写
    unichar c = [key characterAtIndex:0];
    NSString *str = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c", c-32]];
    
    // 2. 最前增加set, 最后增加:
    NSString *setter = [NSString stringWithFormat:@"set%@:", str];
    return setter;
}


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

- (void)jk_remove_kvoObserverWithItem:(__kindof JKBaseKVOItem *)item
{
    if (!item) {
        return;
    }
    [JKKVOItemManager lock];
    if ([item isKindOfClass:[JKKVOArrayItem class]]) {
        JKKVOArrayItem *arrayItem = (JKKVOArrayItem *)item;
        [self removeObserver:arrayItem.kvoObserver forKeyPath:item.keyPath context:item.context];
        for (__kindof NSObject *element in arrayItem.observered_property) {
            [arrayItem removeObserverOfElement:element];
        }
    } else if ([item isKindOfClass:[JKKVOComputedItem class]]) {
        JKKVOComputedItem *computedItem = (JKKVOComputedItem *)item;
        [computedItem removeDependentPropertiesObserver];
    } else if ([item isKindOfClass:[JKKVOItem class]]) {
        [self removeObserver:item.kvoObserver forKeyPath:item.keyPath context:item.context];
    }
    [JKKVOItemManager removeItem:item];
    [JKKVOItemManager unLock];
}

- (void)jk_dealloc_removeObservers
{
    NSArray <__kindof JKBaseKVOItem *>*items = [JKKVOItemManager dealloc_itemsOfObservered:self];
    for (JKBaseKVOItem *item in items) {
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
