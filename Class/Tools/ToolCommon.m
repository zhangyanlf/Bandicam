//
//  ToolCommon.m
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "ToolCommon.h"
#include "UserInfo.h"
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIKit.h>
static NSMutableArray *refreshImageArray;

@implementation ToolCommon
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    
    CC_MD5( cStr,[num intValue], result );
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];

}


+ (NSString *)getToken {
    //NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    // NSString *str = [NSString stringWithFormat:@"lhq%.0f",time];
#ifdef _MY_DEBUG_
    //NSLog(@"token:%@",str);
#endif
    //
    UserInfo *userInfo = [UserInfo shareUserInfo];
    NSString *str = [NSString stringWithFormat:@"%@liujiang",userInfo.userUuid];
    
    NSString *token =  [ToolCommon md5:str];
    token = [NSString stringWithFormat:@"%@;%@;ios",token,userInfo.userUuid];
    return token;
}


//判断是否是手机号码，如果是返回Nil
+ (NSString *)valiMobile:(NSString *)mobile{
    if (mobile.length < 11)
    {
        return @"手机号长度只能是11位";
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return nil;
        }else{
            return @"请输入正确的电话号码";
        }
    }
    return nil;
}

+ (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString;
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        if ([str isKindOfClass:[NSNull class]]) {
            trimedString = @"";
        }
        else {
            trimedString = [str stringByTrimmingCharactersInSet:set];
        }
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

+ (NSString *)getNetconnType{
    
    NSString *netconnType = @"";
    
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            
            netconnType = @"no network";
        }
            break;
            
        case ReachableViaWiFi:// Wifi
        {
            netconnType = @"Wifi";
        }
            break;
            
        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            
            NSString *currentStatus = info.currentRadioAccessTechnology;
            
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                
                netconnType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                
                netconnType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                
                netconnType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                
                netconnType = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                
                netconnType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                
                netconnType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                
                netconnType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                
                netconnType = @"4G";
            }
        }
            break;
            
        default:
            break;
    }
    
    return netconnType;
}


+ (NSArray *)getRefreshImageArray {
    if (!refreshImageArray) {
        NSArray *images = @[@"refresh00",@"refresh01",@"refresh02",@"refresh03",@"refresh04",@"refresh05",@"refresh06",@"refresh07",@"refresh08",@"refresh09",@"refresh10",@"refresh11"];
        refreshImageArray = [NSMutableArray array];
        for (NSInteger i = 0; i < images.count; i++) {
            [refreshImageArray addObject:[UIImage imageNamed:images[i]]];
        }
    }
    return refreshImageArray;
}

+ (NSString *)judgeValue:(NSString *)str{
    if (str == nil || [str isKindOfClass:[NSNull class]]) {
        return @"";
    }
    else{
        return str;
    }
}

@end
