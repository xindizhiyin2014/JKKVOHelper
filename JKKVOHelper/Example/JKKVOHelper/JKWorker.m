//
//  JKWorker.m
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKWorker.h"
#import "JKKVOItemManager.h"

@implementation JKWorker
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
//    NSArray *array = [JKKVOItemManager items];
    NSLog(@"JKWorker dealloc");// count %@",@([array count]));

}
@end
