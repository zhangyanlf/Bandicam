//
//  ZylUploadViewController.h
//  Bandicam
//
//  Created by 张彦林 on 17/6/13.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZylUploadViewController : UIViewController
@property (nonatomic, strong) NSString *thumbImagePath;
@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, strong) NSMutableDictionary *goodsDict;
@end
