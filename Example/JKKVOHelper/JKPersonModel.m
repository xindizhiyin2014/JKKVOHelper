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
@synthesize size = _size;
- (NSDictionary<NSString *,NSArray *> *)jk_computedProperty_config
{
    return @{@"fullName":@[@"firstName",@"lastName"],
             @"size":@[@"width",@"height"],
             @"sum":@[@"a",@"b"]
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

- (NSInteger)sum
{
    self.invokedCount++;
    return self.a + self.b;
}

- (void)setSize:(CGSize)size
{
//    _size = size;
}



- (void)dealloc
{
//    NSArray *array = [JKKVOItemManager items];
    NSLog(@"JKPersonModel dealloc ");//count %@",@([array count]));
//  NSString *className = NSStringFromClass([super class]);
//    NSLog(@"className %@",className);
    
}
@end
