//
//  JKTeacher.h
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKPersonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKTeacher : JKPersonModel
@property (nonatomic, copy) NSString *school;
@property (nonatomic, strong) NSMutableArray <JKPersonModel *>*students; /// 学生
@end

NS_ASSUME_NONNULL_END
