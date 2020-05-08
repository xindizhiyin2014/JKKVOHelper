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

+ (instancetype)initWithOriginObserver:(__kindof NSObject *)originObserver;

@end



@interface JKKVOItem : NSObject
/// 观察者
@property (nonatomic, strong, nonnull, readonly) JKKVOObserver *kvoObserver;
/// 被观察者
@property (nonatomic, weak, nullable, readonly) __kindof NSObject *observered;
///被观察者的内存地址
@property (nonatomic, copy, nullable, readonly) NSString *observered_address;
/// 被监听的属性对应的对象
@property (nonatomic, weak, nullable, readonly) __kindof NSObject *observered_property;
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
                          observered:(nonnull __kindof NSObject *)observered
                 observered_property:(__kindof NSObject *)observered_property
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
+ (nullable JKKVOItem *)isContainItemWithObserver:(__kindof NSObject *)observer
                                       observered:(__kindof NSObject *)observered
                                          keyPath:(NSString *)keyPath
                                          context:(nullable void *)context;

/// 是否存在item
/// @param observer 观察者
/// @param observered 被观察者
+ (BOOL)isContainItemWithObserver:(__kindof NSObject *)observer
                       observered:(__kindof NSObject *)observered;

/// 判断是否存在item
/// @param kvoObserver 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
/// @param context context
+ (nullable JKKVOItem *)isContainItemWith_kvoObserver:(JKKVOObserver *)kvoObserver
                                           observered:(__kindof NSObject *)observered
                                              keyPath:(NSString *)keyPath
                                              context:(nullable void *)context;

/// 获取item列表
/// @param observer 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <JKKVOItem *>*)itemsWithObserver:(__kindof NSObject *)observer
                                 observered:(__kindof NSObject *)observered
                                    keyPath:(nullable NSString *)keyPath;

/// 获取item列表
/// @param observered 被观察者
+ (NSArray <JKKVOItem *>*)itemsOfObservered:(__kindof NSObject *)observered;

/// 获取item列表
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <JKKVOItem *>*)itemsOfObservered:(__kindof NSObject *)observered
                                    keyPath:(nullable NSString *)keyPath;

/// 获取item列表
/// @param observered_property 被观察者对应的属性对象
+ (NSArray <JKKVOItem *>*)itemsOfObservered_property:(__kindof NSObject *)observered_property;

/// 获取item列表
/// @param observer 观察者
+ (NSArray <JKKVOItem *>*)itemsOfObserver:(__kindof NSObject *)observer;

/// 获取item列表
/// @param kvoObserver 真正的观察者
+ (NSArray <JKKVOItem *>*)itemsOfKvo_Observer:(__kindof NSObject *)kvoObserver;

/// 获取监听者列表
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <__kindof NSObject *>*)observersOfObservered:(__kindof NSObject *)observered
                                                keyPath:(NSString *)keyPath;

/// 获取被观察的keyPath列表
/// @param observered 被观察者
+ (NSArray <NSString *>*)observeredKeyPathsOfObservered:(__kindof NSObject *)observered;

/// 获取被观察keyPath列表
/// @param observered 被观察者
/// @param observer 观察者
+ (NSArray <NSString *>*)observeredKeyPathsOfObserered:(__kindof NSObject *)observered
                                              observer:(__kindof NSObject *)observer;

/// 获取被观察的keyPath列表
/// @param kvoObserver 被观察者
+ (NSArray <NSString *>*)observeredKeyPathsOfKvo_observer:(JKKVOObserver *)kvoObserver;

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
