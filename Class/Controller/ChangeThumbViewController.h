//
//  ChangeThumbViewController.h
//  Bandicam
//
//  Created by 张彦林 on 17/6/13.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChangeThumbViewControllerDelegate <NSObject>

- (void)ChangeThumb:(NSString *)thumbnailPath ThumbImage:(UIImage *)thumbImage;

@end
@interface ChangeThumbViewController : UIViewController

@property (nonatomic, strong) NSString *haveCutVideoPath;
@property (nonatomic, weak)id<ChangeThumbViewControllerDelegate> delegate;

@end
