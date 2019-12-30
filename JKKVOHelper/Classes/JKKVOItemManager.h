//
//  JKKVOItemManager.h
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKKVOObserver : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)initWithOriginObserver:(id)originObserver;

@end

@interface JKKVOItem : NSObject
/// 观察者
@property (nonatomic, strong, nonnull, readonly) JKKVOObserver *kvoObserver;
/// 被监听的对象
@property (nonatomic, weak, nullable, readonly) id observered;
/// 监听的keyPath
@property (nonatomic, copy, nonnull, readonly) NSString *keyPath;
/// 上下文
@property (nonatomic, nullable, readonly) void *context;
/// 回调
@property (nonatomic, copy, readonly) void(^block)(NSDictionary *change,void *context);
/// 返回更详细信息的回调
@property (nonatomic, copy, readonly) void(^detailBlock)(NSString *keyPath, NSDictionary *change, void *context);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)initWith_kvoObserver:(nonnull JKKVOObserver *)kvoObserver
                          observered:(nonnull id)observered
                             keyPath:(nonnull NSString *)keyPath
                             context:(nullable void *)context
                               block:(nullable void(^)(NSDictionary *change,void *context))block
                         detailBlock:(nullable void(^)(NSString *keyPath, NSDictionary *change, void *context))detailBlock;
@end

@interface JKKVOItemManager : NSObject

+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)init NS_UNAVAILABLE;

+ (instancetype)sharedManager;

+ (void)lock;

+ (void)unLock;

+ (void)addItem:(JKKVOItem *)item;

+ (void)removeItem:(JKKVOItem *)item;

+ (NSArray <JKKVOItem *>*)items;

/// 判断是否存在item
/// @param observer 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
/// @param context context
+ (JKKVOItem *)isContainItemWithObserver:(id)observer
                       observered:(id)observered
                          keyPath:(nullable NSString *)keyPath
                          context:(nullable void *)context;

/// 是否存在item
/// @param observer 观察者
/// @param observered 被观察者
+ (BOOL)isContainItemWithObserver:(id)observer
                       observered:(id)observered;

/// 判断是否存在item
/// @param kvoObserver 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
/// @param context context
+ (JKKVOItem *)isContainItemWith_kvoObserver:(JKKVOObserver *)kvoObserver
                              observered:(id)observered
                                 keyPath:(nullable NSString *)keyPath
                                 context:(nullable void *)context;

/// 获取item列表
/// @param observer 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <JKKVOItem *>*)itemsWithObserver:(id)observer
                                 observered:(id)observered
                                    keyPath:(nullable NSString *)keyPath;

/// 获取observered 作为被观察者对应的JKKVOItem列表
/// @param observered 被观察者
+ (NSArray <JKKVOItem *>*)observerItemsOfObserered:(id)observered;

/// 获取observered 作为被观察者对应的JKKVOItem列表
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <JKKVOItem *>*)observerItemsOfObserered:(id)observered
                                           keyPath:(nullable NSString *)keyPath;
/// 获取observer 作为观察者对应的JKKVOItem列表
/// @param observer 观察者
+ (NSArray <JKKVOItem *>*)observeredItemsOfObserver:(id)observer;

/// 获取被观察的keyPath列表
/// @param observered 被观察者
+ (NSArray <NSString *>*)observeredKeyPathsOfObservered:(id)observered;

/// 获取被观察keyPath列表
/// @param observered 被观察者
/// @param observer 观察者
+ (NSArray <NSString *>*)observeredKeyPathsOfObserered:(id)observered
                                  observer:(id)observer;

/**
 实例方法替换
 
 @param targetClass targetClass
 @param originalSel 源方法
 @param swizzledSel 替换方法
 */
+ (void)jk_exchangeInstanceMethod:(Class)targetClass
                      originalSel:(SEL)originalSel
                      swizzledSel:(SEL)swizzledSel;
@end

NS_ASSUME_NONNULL_END
