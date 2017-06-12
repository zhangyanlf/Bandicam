//
//  ViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/9.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "ViewController.h"
#import "makeVideoViewController.h"
#import "RecordMovieViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ClickBandicamButton:(UIButton *)sender {
    makeVideoViewController *MVCV = [[makeVideoViewController alloc] init];
    [self presentViewController:MVCV animated:YES completion:nil];
//    RecordMovieViewController *RMVc = [[RecordMovieViewController alloc] init];
//    [self presentViewController:RMVc animated:YES completion:nil];
    
}

@end
