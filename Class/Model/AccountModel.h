//
//  AccountModel.h
//  liangchenbufu
//
//  Created by River on 16/7/10.
//  Copyright © 2016年 MJRB. All rights reserved.
//

#import <Foundation/Foundation.h>
//[UserLogStatus userLoginUserId:userid UserName:username UserAvatar:avatar UserGender:gender UserIntroduce:introduce UserShowId:showId UserBindPhone:bindPhone UserPhoneNumber:phoneNumber UserPasswordSet:passwordSet UserOpen:open];
@interface AccountModel : NSObject
@property(nonatomic,copy)NSString *userid;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *avatar;
@property(nonatomic,copy)NSString *gender;
@property(nonatomic,copy)NSString *introduce;
@property(nonatomic,copy)NSString *showId;
@property(nonatomic,copy)NSString *bindPhone;
@property(nonatomic,copy)NSString *phoneNumber;
@property(nonatomic,copy)NSString *passwordSet;
@property(nonatomic,copy)NSString *open;
@property(nonatomic,copy)NSString *showIdPassword;  
//uid3rd,avatar3rd,name3rd,gender3rd
@property(nonatomic,copy)NSString *uid3rd;
@property(nonatomic,copy)NSString *avatar3rd;
@property(nonatomic,copy)NSString *name3rd;
@property(nonatomic,copy)NSString *gender3rd;
@end
