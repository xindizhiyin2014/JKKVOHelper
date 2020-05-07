#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JKKVOHelper.h"
#import "JKKVOItemManager.h"
#import "NSMutableArray+JKKVOHelper.h"
#import "NSObject+JKKVOHelper.h"

FOUNDATION_EXPORT double JKKVOHelperVersionNumber;
FOUNDATION_EXPORT const unsigned char JKKVOHelperVersionString[];

