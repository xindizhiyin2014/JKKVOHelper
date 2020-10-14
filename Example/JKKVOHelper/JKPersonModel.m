//
//  JKPersonModel.m
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKPersonModel.h"
#import "JKKVOHelper.h"
#import "JKKVOItemManager.h"

@implementation JKPersonModel
- (NSDictionary<NSString *,NSArray *> *)jk_computedProperty_config
{
    return @{@"fullName":@[@"firstName",@"lastName"],
             @"size":@[@"width",@"height"],
             @"point":@[@"pointX",@"pointY"],
             @"rect":@[@"rectX",@"rectY"],
             @"edgeInsets":@[@"edgeTop",@"edgeLeft"],
             @"transform":@[@"transformX",@"transformY"],
             @"offset":@[@"offset_horizontal",@"offset_vertical"],
             @"charValue":@[@"charA",@"charB"],
             @"intValue":@[@"intA",@"intB"],
             @"shortValue":@[@"shortA",@"shortB"],
             @"longValue":@[@"longA",@"longB"],
             @"sum":@[@"a",@"b"],
             @"unsignedCharValue":@[@"unsignedCharA",@"unsignedCharB"],
             @"unsignedIntValue":@[@"unsignedIntA",@"unsignedIntB"],
             @"unsignedShortValue":@[@"unsignedShortA",@"unsignedShortB"],
             @"unsignedLongValue":@[@"unsignedLongA",@"unsignedLongB"],
             @"unsignedLongLongValue":@[@"unsignedLongLongA",@"unsignedLongLongB"],
             @"floatValue":@[@"floatA",@"floatB"],
             @"doubleValue":@[@"doubleA",@"doubleB"],
             @"boolValue":@[@"boolA",@"boolB"],
             @"charPointValue":@[@"charPointA",@"charPointB"],
             @"classValue":@[@"isClassA",@"isClassB"],
             @"selValue":@[@"isSELA",@"isSELB"],


    };
}

- (NSString *)fullName
{
    self.invokedCount++;
    return [NSString stringWithFormat:@"%@%@",self.firstName,self.lastName];
}

- (CGSize)size
{
    self.invokedCount++;
    return CGSizeMake(self.width, self.height);
}

- (CGPoint)point
{
    self.invokedCount++;
    return CGPointMake(self.pointX, self.pointY);
}

- (CGRect)rect
{
    self.invokedCount++;
    return CGRectMake(0, 0, self.rectX, self.rectY);
}

- (UIEdgeInsets)edgeInsets
{
    self.invokedCount++;
    return UIEdgeInsetsMake(self.edgeTop, self.edgeLeft, 0, 0);
}

- (CGAffineTransform)transform
{
    self.invokedCount++;
    return CGAffineTransformMake(0, 0, 0, 0, 1, 5);
}

- (UIOffset)offset
{
    self.invokedCount++;
    return UIOffsetMake(self.offset_horizontal, self.offset_vertical);
}

- (char)charValue
{
    self.invokedCount++;
    if (self.charA && !self.charB) {
        return 'A';
    }
    if (self.charB) {
        return 'B';
    }
    return 'C';
}

- (int)intValue
{
    self.invokedCount++;
    return self.intA + self.intB;
}

- (short)shortValue
{
    self.invokedCount++;
    return self.shortA + self.shortB;
}

- (long)longValue
{
    self.invokedCount++;
    return self.longA + self.longB;
}

- (long long)sum
{
    self.invokedCount++;
    return self.a + self.b;
}

- (unsigned char)unsignedCharValue
{
    self.invokedCount++;
    if (self.unsignedCharA && !self.unsignedCharB) {
        return 'A';
    }
    if (self.unsignedCharB) {
        return 'B';
    }
    return 'C';
}

- (unsigned int)unsignedIntValue
{
    self.invokedCount++;
    return self.unsignedIntA + self.unsignedIntB;
}

- (unsigned short)unsignedShortValue
{
    self.invokedCount++;
    return self.unsignedShortA + self.unsignedShortB;
}

- (unsigned long)unsignedLongValue
{
    self.invokedCount++;
    return self.unsignedLongA + self.unsignedLongB;
}

- (unsigned long long)unsignedLongLongValue
{
    self.invokedCount++;
    return self.unsignedLongLongA + self.unsignedLongLongB;
}

- (float)floatValue
{
    self.invokedCount++;
    return self.floatA + self.floatB;
}

- (double)doubleValue
{
    self.invokedCount++;
    return self.doubleA + self.doubleB;
}

- (BOOL)boolValue
{
    self.invokedCount++;
    return self.boolA && self.boolB;
}

- (char *)charPointValue
{
    self.invokedCount++;
    NSString *str = [NSString stringWithFormat:@"%s%s",self.charPointA,self.charPointB];
    char *value = (char *)[str UTF8String];
    return value;
}

- (Class)classValue
{
    self.invokedCount++;
    if (self.isClassA && !self.isClassB) {
        return [UIView class];
    }
    if (self.isClassB) {
        return [UIViewController class];
    }
    return [UIButton class];
}

- (SEL)selValue
{
    self.invokedCount++;
    if (self.isSELA && !self.isSELB) {
        return NSSelectorFromString(@"testA");
    }
    if (self.isSELB) {
        return NSSelectorFromString(@"testB");
    }
   return NSSelectorFromString(@"testC");
}







- (void)dealloc
{
//    NSArray *array = [JKKVOItemManager items];
    NSLog(@"JKPersonModel dealloc ");//count %@",@([array count]));
//  NSString *className = NSStringFromClass([super class]);
//    NSLog(@"className %@",className);
    
}
@end
