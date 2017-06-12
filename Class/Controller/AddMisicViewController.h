//
//  AddMisicViewController.h
//  Bandicam
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddMisicViewControllerDelegate <NSObject>

- (void)addMusicFinsh:(NSString *)videoPath;
@end

@interface AddMisicViewController : UIViewController
@property (nonatomic, weak) id<AddMisicViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *resolution;

@end
