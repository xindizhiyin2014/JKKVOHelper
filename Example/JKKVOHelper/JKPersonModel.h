//
//  JKPersonModel.h
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface JKPersonModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) NSInteger a;
@property (nonatomic, assign) NSInteger b;
@property (nonatomic, assign) NSInteger sum;

@property (nonatomic, strong) UIViewController *vc;
///
@property (nonatomic, assign) NSInteger invokedCount;

@end

NS_ASSUME_NONNULL_END
