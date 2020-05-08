//
//  NSMutableArray+JKKVOHelper.m
//  JKKVOHelper
//
//  Created by JackLee on 2020/4/28.
//

#import "NSMutableArray+JKKVOHelper.h"
#import "JKKVOItemManager.h"

@implementation NSMutableArray (JKKVOHelper)

- (void)jk_addObject:(id)anObject
{
#if DEBUG
    NSAssert(anObject, @"anObject can't be nil");
#endif
    if (anObject) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self addObject:anObject];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
          [self addObject:anObject];
        }
        
    }
}
- (void)jk_insertObject:(id)anObject atIndex:(NSUInteger)index
{
#if DEBUG
    NSAssert(anObject, @"anObject can't be nil");
    NSAssert(index <= self.count, @"make sure index <= self.count be YES");
#endif
    if (anObject
        && index <= self.count) {
         NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
         if (items.count > 0) {
             for (JKKVOItem *item in items) {
                 [item.observered willChangeValueForKey:item.keyPath];
                 [self insertObject:anObject atIndex:index];
                 [item.observered didChangeValueForKey:item.keyPath];
             }
         } else {
           [self insertObject:anObject atIndex:index];
         }
    }
}

- (void)jk_removeLastObject
{
#if DEBUG
    NSAssert(self.count > 0, @"make sure self.count > 0 be YES");
#endif
    if (self.count > 0) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self removeLastObject];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self removeLastObject];
        }
    }
}
- (void)jk_removeObjectAtIndex:(NSUInteger)index
{
#if DEBUG
    NSAssert(index < self.count, @"make sure index < self.count be YES");
#endif
    if (index < self.count) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self removeObjectAtIndex:index];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self removeObjectAtIndex:index];
        }
    }
}

- (void)jk_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
#if DEBUG
    NSAssert(anObject, @"anObject can't be nil");
    NSAssert(index < self.count, @"make sure index < self.count be YES");
#endif
    if (anObject
        && index < self.count
        && ![self[index] isEqual:anObject]) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self replaceObjectAtIndex:index withObject:anObject];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self replaceObjectAtIndex:index withObject:anObject];
        }
    }
}

- (void)jk_addObjectsFromArray:(NSArray<id> *)otherArray
{
#if DEBUG
    NSAssert(otherArray.count > 0, @"make sure otherArray.count > 0 be YES");
#endif
    if (otherArray.count > 0) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self addObjectsFromArray:otherArray];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self addObjectsFromArray:otherArray];
        }
    }
}

- (void)jk_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
#if DEBUG
    NSAssert(idx1 >= 0, @"make sure idx1 >= 0 be YES");
    NSAssert(idx2 >= 0, @"make sure idx2 >= 0 be YES");
    NSAssert(idx1 < self.count, @"make sure idx1 < self.count be YES");
    NSAssert(idx2 < self.count, @"make sure idx2 < self.count be YES");
#endif
    if (idx1 >= 0
        && idx2 >= 0
        && idx1 < self.count
        && idx2 < self.count
        && idx1 != idx2) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
        }
    }
}

- (void)jk_removeAllObjects
{
    if (self.count > 0) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self removeAllObjects];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self removeAllObjects];
        }
    }
}

- (void)jk_removeObject:(id)anObject
{
#if DEBUG
    NSAssert(anObject, @"anObject can't be nil");
#endif
    if (anObject
        && [self containsObject:anObject]) {
        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
        if (items.count > 0) {
            for (JKKVOItem *item in items) {
                [item.observered willChangeValueForKey:item.keyPath];
                [self removeObject:anObject];
                [item.observered didChangeValueForKey:item.keyPath];
            }
        } else {
            [self removeObject:anObject];
        }
    }
}

//- (void)jk_setNil:(NSMutableArray **)array
//{
//#if DEBUG
//    NSAssert(array != NULL, @"make sure array != NULL be YES");
//    NSString *self_address = [NSString stringWithFormat:@"%p",self];
//    NSString *array_address = [NSString stringWithFormat:@"%p",*array];
//    NSAssert([self_address isEqualToString:array_address] , @"make sure [self_address isEqualToString:array_address] be YES");
//#endif
//        NSArray <JKKVOItem *>*items = [JKKVOItemManager itemsOfObservered_property:self];
//        if (items.count > 0) {
//            for (JKKVOItem *item in items) {
//                [item.observered willChangeValueForKey:item.keyPath];
//                [item.observered setValue:nil forKeyPath:item.keyPath];
//                [item.observered didChangeValueForKey:item.keyPath];
//            }
//        } else {
//            if (array != NULL) {
//                *array = nil;
//            }
//        }
//}


@end
