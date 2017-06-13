//
//  makeVideoViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/9.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "makeVideoViewController.h"
#import "RecordMovieViewController.h"
#import "AddMisicViewController.h"
#import "ZylUploadViewController.h"

@interface makeVideoViewController ()<RecordMovieViewControllerDelegate,AddMisicViewControllerDelegate>

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
    
    AddMisicViewController *addVC = [[AddMisicViewController alloc] init];
    addVC.delegate =self;
    addVC.videoPath = [videoPath copy];
    addVC.resolution = @"480*640";
//    [self.navigationController pushViewController:addVC animated:YES];
    [self setViewControllers:@[addVC] animated:YES];
   
    
}


- (void)addMusicFinsh:(NSString *)videoPath {
    NSLog(@"music video: %@",videoPath);
    ZylUploadViewController *vc = [[ZylUploadViewController alloc]init];
    vc.goodsDict = [self.goodsDict copy];
    vc.thumbImagePath = self.thumbImagePath;
    vc.videoPath = [videoPath copy];
    [self setViewControllers:@[vc] animated:YES];
}

- (void)changeLocalVideo {
    NSLog(@"change to local video");
}
@end
