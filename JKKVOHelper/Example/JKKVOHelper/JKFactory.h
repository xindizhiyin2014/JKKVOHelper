//
//  JKFactory.h
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/11/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JKFactory : NSObject

@property (nonatomic, copy) NSString *address;   ///< 工厂的地址
@property (nonatomic, copy) NSString *name;      ///< 工厂的名字

+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
