//
//  UserInfo.m
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "UserInfo.h"
#import "UICKeyChainStore.h"
#import <UIKit/UIKit.h>
#import "AccountModel.h"
@implementation UserInfo

static UserInfo *_instance = nil;
+ (instancetype)shareUserInfo {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        
        
        NSString *deviceId = [UICKeyChainStore stringForKey:@"deviceId" service:@"Devices"];
        if(deviceId != nil) {
            NSLog(@"已保存的：%@",deviceId);
        } else {
            deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [UICKeyChainStore setString:deviceId forKey:@"deviceId" service:@"Devices"];
            NSLog(@"第一次生成：%@",deviceId);
        }
        _instance.userUuid = deviceId;
        [_instance creatTable];
    }) ;
    return _instance ;
}



- (void)creatTable{
   // NSFileManager *fileManage = [NSFileManager defaultManager];
    //if (![fileManage fileExistsAtPath:[NSString stringWithFormat:@"%@/Library/Caches/Account.db",NSHomeDirectory()]] ) {
        _path = [NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()];
        _path = [_path stringByAppendingPathComponent:@"Account.db"];
        //NSLog(@"账号数据库的路径为:%@",path);
        _dataBase = [FMDatabase databaseWithPath:_path];
        [_dataBase open];
        BOOL ret = [_dataBase executeUpdate:@"create table if not exists Account (userId text primary key,userName text,userAvatar text,userGender text,userIntroduce text,usershowId text,userBindPhone text,userPhoneNumber text,userPasswordSet text,userOpen text,showIdPassword text,uid3rd text,avatar3rd text,name3rd text,gender3rd text)"];
        NSLog(@"创建表：%@",ret ? @"成功！":@"失败！");
        
        [_dataBase close];
    //}
    
    
}
- (void)insertData{
    
    //@"open":self.uid3rd,@"avatar":self.avatar3rd,@"username":self.name3rd,@"gender":self.gender3rd
    [_dataBase open];
   BOOL ret = [_dataBase executeUpdate:@"insert into Account (userId,userName,userAvatar,userGender,userIntroduce,usershowId,userBindPhone,userPhoneNumber,userPasswordSet,userOpen,showIdPassword,uid3rd,avatar3rd,name3rd,gender3rd) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",_instance.userId,_instance.userName,_instance.userAvatar,_instance.userGender,_instance.userIntroduce,_instance.usershowId,_instance.userBindPhone,_instance.userPhoneNumber,_instance.userPasswordSet,_instance.userOpen,_instance.showIdPassword,_instance.uid3rd,_instance.avatar3rd,_instance.name3rd,_instance.gender3rd];
    NSLog(@"插入数据： %@",ret ? @"成功":@"失败！");
    [_dataBase close];
    
}
- (BOOL)dataExist:(NSString *)searchStr{
    BOOL ret = NO;
    [_dataBase open];
    
    FMResultSet *result = [_dataBase executeQuery:searchStr];
    ret = [result next];
    [_dataBase close];
    
    
    return ret;
}
- (void)upDataAccount:(NSString *)updataStr{
    [_dataBase open];
   BOOL ret =  [_dataBase executeUpdate:updataStr];
    NSLog(@"更新数据： %@",ret ? @"成功":@"失败！");
    [_dataBase close];
}
- (void)deleteAccountData:(NSString *)deleteStr{
    [_dataBase open];
    BOOL ret = [_dataBase executeUpdate:deleteStr];
    NSLog(@"删除:%@",ret ? @"成功" : @"失败");
    
    
    
    [_dataBase close];
}
- (NSMutableArray *)getAllAccount{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [_dataBase open];
    FMResultSet *result = [_dataBase executeQuery:@"select * from Account"];
    while ([result next]) {
        //insert into Account (userId,userName,userAvatar,userGender,userIntroduce,usershowId,userBindPhone,userPhoneNumber,userPasswordSet,userOpen
        AccountModel *account = [[AccountModel alloc] init];
        account.userid = [result stringForColumn:@"userId"];
        account.username = [result stringForColumn:@"userName"];
        account.avatar = [result stringForColumn:@"userAvatar"];
        account.gender = [result stringForColumn:@"userGender"];
        account.introduce = [result stringForColumn:@"userIntroduce"];
        account.showId = [result stringForColumn:@"usershowId"];
        account.bindPhone = [result stringForColumn:@"userBindPhone"];
        account.phoneNumber = [result stringForColumn:@"userPhoneNumber"];
        account.passwordSet = [result stringForColumn:@"userPasswordSet"];
        account.open = [result stringForColumn:@"userOpen"];
        account.showIdPassword = [result stringForColumn:@"showIdPassword"];
        //uid3rd,avatar3rd,name3rd,gender3rd
        account.uid3rd = [result stringForColumn:@"uid3rd"];
        account.avatar3rd = [result stringForColumn:@"avatar3rd"];
        account.name3rd = [result stringForColumn:@"name3rd"];
        account.gender3rd = [result stringForColumn:@"gender3rd"];
        [arr addObject:account];
    }
    
    return arr;
}
+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [UserInfo shareUserInfo] ;
}

- (id) copyWithZone:(struct _NSZone *)zone
{
    return [UserInfo shareUserInfo] ;
}


- (void)updateUserId:(NSString *)userId {
    _instance.userId = [userId copy];
}
- (void)updateUserName:(NSString *)userName {
    _instance.userName = [userName copy];
}
- (void)updateUserAvatar:(NSString *)userAvatar {
    _instance.userAvatar = [userAvatar copy];
}
- (void)updateUserGender:(NSString *)userGender {
    _instance.userGender = [userGender copy];
}
- (void)updateUserIntroduce:(NSString *)userIntroduce {
    _instance.userIntroduce = [userIntroduce copy];
}
- (void)updateUserShowId:(NSString *)showId{
    _instance.usershowId = [showId copy];
}
- (void)updateUserBlidPhone:(NSString *)bindPhone{
    _instance.userBindPhone = [bindPhone copy];
}
- (void)updateUserPhoneNumber:(NSString *)phoneNumber{
    _instance.userPhoneNumber = phoneNumber;
}
- (void)updateUserpasswordSet:(NSString *)passwordSet{
    _instance.userPasswordSet = passwordSet;
}
- (void)updateUserOpen:(NSString *)open{
    _instance.userOpen = open;
}
- (void)updateUserShowIdPassword:(NSString *)showIdPassword{
   
    _instance.showIdPassword = showIdPassword;

}
-(void)updateUid3rd:(NSString *)uid3rd{
    _instance.uid3rd = uid3rd;
}
- (void)updateAvatar3rd:(NSString *)avatar3rd{
    _instance.avatar3rd = avatar3rd;
}
- (void)updatename3rd:(NSString *)name3rd{
    _instance.name3rd = name3rd;
}
- (void)updategender3rd:(NSString *)gender3rd{
    _instance.gender3rd = gender3rd;
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
#ifdef _MY_DEBUG_
    NSString *callbackString =
    [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
    [self logSet:tags], alias];
    
    NSLog(@"TagsAlias回调:%@", callbackString);
#endif
    
}
- (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
//    //[NSPropertyListSerialization propertyListFromData:tempData
//                                     mutabilityOption:NSPropertyListImmutable
//                                               format:NULL
//                                     errorDescription:NULL];
    [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return str;
}
@end
