//
//  ToolCommon.h
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface ToolCommon : NSObject
+ (NSString *)md5:(NSString *)str;
+ (NSString *)getToken;
+ (NSString *)valiMobile:(NSString *)mobile;
+ (BOOL) isEmpty:(NSString *) str;
+ (NSString *)getNetconnType;
+ (NSArray *)getRefreshImageArray;
+ (NSString *)judgeValue:(NSString *)str;
@end
