//
//  PlayVideoView.h
//  Bandicam
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoView : UIView
@property(nonatomic)AVPlayer *player;
@property(nonatomic,readonly)AVPlayerLayer * playerLayer;

@end
