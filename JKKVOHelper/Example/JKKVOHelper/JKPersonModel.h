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

@property (nonatomic, assign) NSInteger pointX;
@property (nonatomic, assign) NSInteger pointY;
@property (nonatomic, assign) CGPoint point;

@property (nonatomic, assign) NSInteger rectX;
@property (nonatomic, assign) NSInteger rectY;
@property (nonatomic, assign) CGRect rect;

@property (nonatomic, assign) NSInteger edgeTop;
@property (nonatomic, assign) NSInteger edgeLeft;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;


@property (nonatomic, assign) NSInteger transformX;
@property (nonatomic, assign) NSInteger transformY;
@property (nonatomic, assign) CGAffineTransform transform;

@property (nonatomic, assign) NSInteger offset_horizontal;
@property (nonatomic, assign) NSInteger offset_vertical;
@property (nonatomic, assign) UIOffset offset;

@property (nonatomic, assign) BOOL charA;
@property (nonatomic, assign) BOOL charB;
@property (nonatomic, assign) char charValue;

@property (nonatomic, assign) int intA;
@property (nonatomic, assign) int intB;
@property (nonatomic, assign) int intValue;

@property (nonatomic, assign) short shortA;
@property (nonatomic, assign) short shortB;
@property (nonatomic, assign) short shortValue;

@property (nonatomic, assign) long longA;
@property (nonatomic, assign) long longB;
@property (nonatomic, assign) long longValue;

@property (nonatomic, assign) long long a;
@property (nonatomic, assign) long long b;
@property (nonatomic, assign) long long sum;

@property (nonatomic, assign) BOOL unsignedCharA;
@property (nonatomic, assign) BOOL unsignedCharB;
@property (nonatomic, assign) unsigned char unsignedCharValue;

@property (nonatomic, assign) unsigned int unsignedIntA;
@property (nonatomic, assign) unsigned int unsignedIntB;
@property (nonatomic, assign) unsigned int unsignedIntValue;

@property (nonatomic, assign) unsigned short unsignedShortA;
@property (nonatomic, assign) unsigned short unsignedShortB;
@property (nonatomic, assign) unsigned short unsignedShortValue;

@property (nonatomic, assign) unsigned long unsignedLongA;
@property (nonatomic, assign) unsigned long unsignedLongB;
@property (nonatomic, assign) unsigned long unsignedLongValue;

@property (nonatomic, assign) unsigned long long unsignedLongLongA;
@property (nonatomic, assign) unsigned long long unsignedLongLongB;
@property (nonatomic, assign) unsigned long long unsignedLongLongValue;

@property (nonatomic, assign) float floatA;
@property (nonatomic, assign) float floatB;
@property (nonatomic, assign) float floatValue;

@property (nonatomic, assign) double doubleA;
@property (nonatomic, assign) double doubleB;
@property (nonatomic, assign) double doubleValue;

@property (nonatomic, assign) BOOL boolA;
@property (nonatomic, assign) BOOL boolB;
@property (nonatomic, assign) BOOL boolValue;

@property (nonatomic) char *charPointA;
@property (nonatomic) char *charPointB;
@property (nonatomic) char *charPointValue;


@property (nonatomic, assign) BOOL isClassA;
@property (nonatomic, assign) BOOL isClassB;
@property (nonatomic, strong) Class classValue;


@property (nonatomic, assign) BOOL isSELA;
@property (nonatomic, assign) BOOL isSELB;
@property (nonatomic, assign) SEL selValue;



@property (nonatomic, strong) UIViewController *vc;
///
@property (nonatomic, assign) NSInteger invokedCount;

@end

NS_ASSUME_NONNULL_END
