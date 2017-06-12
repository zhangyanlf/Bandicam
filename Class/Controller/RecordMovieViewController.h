//
//  RecordMovieViewController.h
//  Bandicam
//
//  Created by 张彦林 on 17/6/9.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RecordMovieViewControllerDelegate <NSObject>

- (void)RecordFinsh:(NSString *)videoPath ThumbImage:(NSString *)thumbImagePath;
- (void)changeLocalVideo;

@end

@interface RecordMovieViewController : UIViewController
/**定义协议*/
@property (nonatomic, weak) id<RecordMovieViewControllerDelegate> delegate;
@end
