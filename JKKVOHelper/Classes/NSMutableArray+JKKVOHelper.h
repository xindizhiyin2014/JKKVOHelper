//
//  NSMutableArray+JKKVOHelper.h
//  JKKVOHelper
//
//  Created by JackLee on 2020/4/28.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (JKKVOHelper)

- (void)jk_addObject:(id)anObject;
- (void)jk_insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)jk_removeLastObject;
- (void)jk_removeObjectAtIndex:(NSUInteger)index;
- (void)jk_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)jk_addObjectsFromArray:(NSArray<id> *)otherArray;
- (void)jk_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)jk_removeAllObjects;
- (void)jk_removeObject:(id)anObject;
- (void)jk_setNil:(NSMutableArray *_Nonnull*_Nonnull)array;
/*
- (void)jk_removeObject:(ObjectType)anObject inRange:(NSRange)range;
- (void)jk_removeObjectIdenticalTo:(ObjectType)anObject inRange:(NSRange)range;
- (void)jk_removeObjectIdenticalTo:(ObjectType)anObject;
- (void)jk_removeObjectsInArray:(NSArray<ObjectType> *)otherArray;
- (void)jk_removeObjectsInRange:(NSRange)range;
- (void)jk_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray range:(NSRange)otherRange;
- (void)jk_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ObjectType> *)otherArray;
- (void)jk_setArray:(NSArray<ObjectType> *)otherArray;
- (void)jk_sortUsingFunction:(NSInteger (NS_NOESCAPE *)(ObjectType,  ObjectType, void * _Nullable))compare context:(nullable void *)context;
- (void)jk_sortUsingSelector:(SEL)comparator;

- (void)jk_insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;
- (void)jk_removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)jk_replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray<ObjectType> *)objects;

- (void)jk_setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx API_AVAILABLE(macos(10.8), ios(6.0), watchos(2.0), tvos(9.0));

- (void)jk_sortUsingComparator:(NSComparator NS_NOESCAPE)cmptr API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
- (void)jk_sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)cmptr API_AVAILABLE(macos(10.6), ios(4.0), watchos(2.0), tvos(9.0));
*/
@end

NS_ASSUME_NONNULL_END
