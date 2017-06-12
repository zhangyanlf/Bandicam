//
//  makeVideoViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/9.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "makeVideoViewController.h"
#import "RecordMovieViewController.h"

@interface makeVideoViewController ()<RecordMovieViewControllerDelegate>

@property (nonatomic, strong)NSString *thumbImagePath;
@property (nonatomic, strong)NSString *videoPath;
@end

@implementation makeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    RecordMovieViewController *rmVC = [[RecordMovieViewController alloc] init];
    rmVC.delegate = self;
    
    [self setViewControllers:@[rmVC] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)RecordFinsh:(NSString *)videoPath ThumbImage:(NSString *)thumbImagePath
{
    NSLog(@"new video:%@,%@",videoPath,thumbImagePath);
    self.thumbImagePath = [thumbImagePath copy];
}
- (void)changeLocalVideo {
    NSLog(@"change to local video");
}
@end
