//
//  JKWorker.h
//  JKKVOHelper_Example
//
//  Created by JackLee on 2019/9/2.
//  Copyright © 2019 xindizhiyin2014. All rights reserved.
//

#import "JKPersonModel.h"
#import "JKFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface JKWorker : JKPersonModel
@property (nonatomic, strong) JKFactory *factory;

@end

NS_ASSUME_NONNULL_END
