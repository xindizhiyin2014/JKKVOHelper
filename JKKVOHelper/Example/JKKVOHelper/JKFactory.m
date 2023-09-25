//
//  JKFactory.m
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/11/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKFactory.h"

@implementation JKFactory
+ (instancetype)sharedInstance
{
    static JKFactory *_factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _factory = [[self alloc] init];
    });
    return _factory;
}
@end
