//
//  AFNRequestData.m
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "AFNRequestData.h"
#import <AFNetworking.h>


@implementation AFNRequestData
//默认网络请求时间
static const NSUInteger kDefaultTimeoutInterval = 15;
static AFHTTPSessionManager  *manager = nil;


//pragma GET请求--------------
+(void)requestMethodGetUrl:(NSString*)url
                       dic:(NSDictionary*)dic
                    Succed:(Success)succed
                   failure:(Failure)failure{
    //1.数据请求接口 2.请求方法 3.参数
    //请求成功   返回数据
    //请求失败   返回错误
    [AFNRequestData Manager:url Method:@"GET"  dic:dic requestSucced:^(id responseObject) {
        succed(responseObject);
        
    } requestfailure:^(NSError *error) {
        
        failure(error);
        
    }];
}
//pragma POST请求--------------
+(void)requestMethodPOSTUrl:(NSString*)url
                        dic:(NSDictionary*)dic
                     Succed:(Success)succed
                    failure:(Failure)failure{
    [AFNRequestData Manager:url Method:@"POST"  dic:dic requestSucced:^(id responseObject) {
        
        succed(responseObject);
        
    } requestfailure:^(NSError *error) {
        
        failure(error);
    }];
}

//解决AFNetworking内存泄漏
+(AFHTTPSessionManager *)sharedHTTPSession{
    static dispatch_once_t onceToken;
    dispatch_once(& onceToken, ^{
        manager= [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = kDefaultTimeoutInterval; //默认网络请求时间
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer]; //申明返回的结果是json类型
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/json", @"text/javascript",@"text/html", nil];
        
    });
    
    return manager;
}
//配置网络请求
+(void)Manager:(NSString*)url Method:(NSString*)Method dic:(NSDictionary*)dic requestSucced:(Success)Succed requestfailure:(Failure)failure
{
    [AFNRequestData sharedHTTPSession];
    //======POST=====
    if ([Method isEqualToString:@"POST"]) {
        [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            Succed(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failure(error);
        }];
        
        
        //=========GET======
    }else{
        
        [manager GET:url parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            Succed(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failure(error);
            
        }];
    }
    
}

@end
