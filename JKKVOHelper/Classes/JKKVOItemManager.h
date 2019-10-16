//
//  JKKVOItemManager.h
//  JKKVOHelper
//
//  Created by JackLee on 2019/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKKVOItem : NSObject

@property (nonatomic, copy) NSString *observerAddress;                        ///< 观察者
@property (nonatomic, weak) id observered;                        ///< 被监听的对象
@property (nonatomic, copy) NSString *keyPath;         ///< 监听的keyPath

@property (nonatomic) void *context;                   ///< 上下文

@property (nonatomic, copy) void(^block)(NSDictionary *change,void *context);  ///< 回调
@property (nonatomic, copy) void(^detailBlock)(NSString *keyPath, NSDictionary *change, void *context); ///< 返回更详细信息的回调

@end

@interface JKKVOItemManager : NSObject

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

/// observer 中observeValueForKeyPath:ofObject:change:context: 方法是否已经被交换了
/// @param observer 观察者
+ (BOOL)obseverMethodHasExchangedOfObserver:(id)observer;

/// 获取item列表
/// @param observer 观察者
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray <JKKVOItem *>*)itemsWithObserver:(id)observer
                    observered:(id)observered
                       keyPath:(nullable NSString *)keyPath;

/// 获取观察者列表
/// @param observered 被观察者
+ (NSArray *)observersOfObserered:(id)observered;

/// 获取被观察列表
/// @param observer 观察者
+ (NSArray *)observeredsOfObserver:(id)observer;

/// 获取被观察的keyPath列表
/// @param observered 被观察者
+ (NSArray *)observeredKeyPathsOfObservered:(id)observered;

/// 获取观察者列表
/// @param observered 被观察者
/// @param keyPath keyPath
+ (NSArray *)observersOfObserered:(id)observered
                          keyPath:(nullable NSString *)keyPath;

/// 获取被观察keyPath列表
/// @param observered 被观察者
/// @param observer 观察者
+ (NSArray *)observeredKeyPathsOfObserered:(id)observered
                                  observer:(id)observer;

+ (id)objectWithAddressStr:(NSString *)addressStr;

@end

NS_ASSUME_NONNULL_END
