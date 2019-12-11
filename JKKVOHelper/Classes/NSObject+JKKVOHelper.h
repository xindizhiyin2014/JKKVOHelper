//
//  NSObject+JKKVOHelper.h
//  JKKVOHelper
//
//  Created by JackLee on 2019/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JKKVOHelper)
/**
 添加keyPath监听
 
 @param observer 观察者
 @param keyPath keyPath
 @param options options
 @param block 回调
 */
- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
             withBlock:(void(^)(NSDictionary *change, void *context))block;

/**
 添加keyPath监听
 
 @param observer 观察者
 @param keyPath keyPath
 @param options options
 @param context context
 @param block 回调
 */
- (void)jk_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
             withBlock:(void(^)(NSDictionary *change, void *context))block;


/// 添加一组keyPath监听
/// @param observer 观察者
/// @param keyPaths keyPath数组
/// @param options options
/// @param context context
/// @param detailBlock 回调
- (void)jk_addObserver:(NSObject *)observer
           forKeyPaths:(NSArray <NSString *>*)keyPaths
               options:(NSKeyValueObservingOptions)options
               context:(nullable void *)context
       withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock;

/**
 添加keyPath监听,观察者是自己
 
 @param keyPath keyPath
 @param options options
 @param block 回调
 */
- (void)jk_addObserverForKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                       withBlock:(void(^)(NSDictionary *change, void *context))block;

/**
 添加keyPath监听,观察者是自己
 
 @param keyPath keyPath
 @param options options
 @param context context
 @param block 回调
 */
- (void)jk_addObserverForKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(nullable void *)context
                       withBlock:(void(^)(NSDictionary *change, void *context))block;

/// 添加一组keyPath监听,观察者是自己
/// @param keyPaths keyPath数组
/// @param options options
/// @param context context
/// @param detailBlock 回调
- (void)jk_addObserverForKeyPaths:(NSArray <NSString *>*)keyPaths
                          options:(NSKeyValueObservingOptions)options
                          context:(nullable void *)context
                  withDetailBlock:(void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock;
/**
 移除keyPath监听
 
 @param observer 观察者
 @param keyPath keyPath
 */
- (void)jk_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath;

/// 移除keyPath监听
/// @param observer 观察者
/// @param keyPath keyPath
/// @param context context
- (void)jk_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  context:(nullable void *)context;

/**
 移除某个observer下的对应的keyPath列表监听
 
 @param observer 观察者
 @param keyPaths keyPath组成的数组
 */
- (void)jk_removeObserver:(NSObject *)observer
              forKeyPaths:(NSArray <NSString *>*)keyPaths;

/**
 移除某个keyPath的所有obsevers对应的监听
 
 @param observers 观察者数组
 @param keyPath keyPath
 */
- (void)jk_removeObservers:(NSArray <NSObject *>*)observers
                forKeyPath:(NSString *)keyPath;

/**
 移除所有通过jk_前缀添加的观察者，默认在被观察的对象dealloc的时候调用
 */
- (void)jk_removeObservers;

/**
 所有的观察者列表
 
 @return 观察者列表的数组
 */
- (NSArray *)jk_observers;

/// 所有的被观察者列表的数组
- (NSArray *)jk_observereds;

/**
 所有的被监听的keyPath列表
 
 @return 被监听的keyPath组成的列表
 */
- (NSArray *)jk_observeredKeyPaths;

/**
 某个keyPath对应的观察者列表
 
 @param keyPath keyPath
 @return 观察者列表的数组
 */
- (NSArray *)jk_observersForKeyPath:(NSString *)keyPath;

/**
 某个观察者监听的keyPath组成的列表
 
 @param observer 观察者
 @return keyPath组成的列表
 */
- (NSArray *)jk_keyPathsObserveredBy:(NSObject *)observer;

@end

NS_ASSUME_NONNULL_END
