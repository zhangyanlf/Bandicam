//
//  UserInfo.h
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface UserInfo : NSObject
{
    FMDatabase  *_dataBase;
    NSString    *_path;
}
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatar;
@property (nonatomic, strong) NSString *userGender;
@property (nonatomic, strong) NSString *userIntroduce;
@property (nonatomic, assign) BOOL userIsLogin;
@property(nonatomic,strong) NSString *usershowId;
@property(nonatomic,strong) NSString *userBindPhone;
@property(nonatomic,strong) NSString *userPhoneNumber;
@property(nonatomic,strong) NSString *userPasswordSet;
@property(nonatomic,strong)NSString *userOpen;
@property(nonatomic,strong)NSString *showIdPassword;

@property(nonatomic,strong)NSString *uid3rd;
@property(nonatomic,strong)NSString *avatar3rd;
@property(nonatomic,strong)NSString *name3rd;
@property(nonatomic,strong)NSString *gender3rd;


@property (nonatomic,strong) NSString *fuwu;

+ (instancetype)shareUserInfo;
- (void)updateUserId:(NSString *)userId;
- (void)updateUserName:(NSString *)userName;
- (void)updateUserAvatar:(NSString *)userAvatar;
- (void)updateUserGender:(NSString *)userGender;
- (void)updateUserIntroduce:(NSString *)userIntroduce;
- (void)updateUserShowId:(NSString *)showId;
- (void)updateUserBlidPhone:(NSString *)bindPhone;
- (void)updateUserPhoneNumber:(NSString *)phoneNumber;
- (void)updateUserpasswordSet:(NSString *)passwordSet;
- (void)updateUserOpen:(NSString *)open;
- (void)updateUserShowIdPassword:(NSString *)showIdPassword;
- (void)updateUid3rd:(NSString *)uid3rd;
- (void)updateAvatar3rd:(NSString *)avatar3rd;
- (void)updatename3rd:(NSString *)name3rd;
- (void)updategender3rd:(NSString *)gender3rd;



- (void)tagsAliasCallback:(int)iResCode
                       tags:(NSSet *)tags
                      alias:(NSString *)alias;
- (void)creatTable;
- (void)insertData;
- (BOOL)dataExist:(NSString *)searchStr;
- (void)upDataAccount:(NSString *)updataStr;
- (NSMutableArray *)getAllAccount;
- (void)deleteAccountData:(NSString *)deleteStr;
@end
