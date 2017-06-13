//
//  ChangeThumbViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/13.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "ChangeThumbViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ChangeThumbViewController ()
@property (nonatomic, strong) AVURLAsset *videoAsset;
@property (nonatomic, strong) UIImageView *showThumbImageView;
@property (nonatomic, strong) NSMutableArray *showImageArray;
@property (nonatomic, strong) NSMutableArray *selectViewImageArray;
@property (nonatomic, strong) NSMutableArray *times;

@property (nonatomic, strong) UIView *selectView;
@property (nonatomic, assign) CGFloat selectViewWidth;
@property (nonatomic, assign) CGFloat selectImageHeight;
@property (nonatomic, strong) UIImageView *pointerView;
@property (nonatomic, strong) UILabel *pointerTimerLabel;
@end
#define KCachesPath   \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
@implementation ChangeThumbViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self setupTopView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self.view makeToastActivity:CSToastPositionCenter];
    
    [self processImage1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
}
- (void)dealloc {
    NSLog(@"----------change thumb dealloc");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupTopView{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.view addSubview:topView];
    topView.backgroundColor = COLOR_MAIN;
    
    //返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"seek_btn_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width-120, 50)];
    nameLabel.text = @"更换缩略图";
    nameLabel.font = [UIFont systemFontOfSize:20];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:nameLabel];
    
    UIButton *markButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, SCREEN_HEIGHT-60, 200, 40)];
    [markButton setTitle:@"确定" forState:UIControlStateNormal];
    [markButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [markButton setBackgroundColor:COLOR_MAIN];
    markButton.titleLabel.font = [UIFont systemFontOfSize:16];
    markButton.layer.cornerRadius = 15;
    markButton.layer.masksToBounds = YES;
    
    [markButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:markButton];
    
}
- (void)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)okButtonClick:(UIButton *)button {
    
    
    UIImage *image = self.showThumbImageView.image;
    
    if (!image) {
        return;
    }
    
    NSString *changeNewThumbPath = [KCachesPath stringByAppendingPathComponent:@"thumbnail.jpg"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:changeNewThumbPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:changeNewThumbPath error:nil];
    }
    if (![UIImageJPEGRepresentation(image, 0.5) writeToFile:changeNewThumbPath atomically:YES]) {
        NSLog(@"缩略图保存到沙盒出错");
    } else {
        NSLog(@"缩略图保存文件成功");
    }
    
    [self.delegate ChangeThumb:changeNewThumbPath ThumbImage:image];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupShowThumbView {
    self.showThumbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    [self.view addSubview:self.showThumbImageView];
    self.showThumbImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.showThumbImageView.image = self.showImageArray[0];
}

- (void)setupSelectView {
    _selectViewWidth = [UIScreen mainScreen].bounds.size.width-40;
    _selectImageHeight = _selectViewWidth/6;
    
    _selectView = [[UIView alloc]initWithFrame:CGRectMake(20, _showThumbImageView.frame.origin.y+_showThumbImageView.frame.size.height, _selectViewWidth, _selectImageHeight+60)];
    [self.view addSubview:_selectView];
    
    for (NSInteger i = 0; i < self.selectViewImageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*_selectImageHeight, 30, _selectImageHeight, _selectImageHeight)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        UIImage *image = self.selectViewImageArray[i];
        imageView.image = image;
        [_selectView addSubview:imageView];
    }
    
    _pointerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 60, _selectImageHeight)];
    _pointerView.center = CGPointMake(0, 30+_selectImageHeight/2);
    _pointerView.image = [UIImage imageNamed:@"select_180_150"];
    [_selectView addSubview:_pointerView];
    
    
    UIPanGestureRecognizer *panGestureRecognizerRightImage = [[UIPanGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(handlePan:)];
    panGestureRecognizerRightImage.minimumNumberOfTouches = 1;
    panGestureRecognizerRightImage.maximumNumberOfTouches = 1;
    [_pointerView addGestureRecognizer:panGestureRecognizerRightImage];
    _pointerView.userInteractionEnabled = YES;
    
    _pointerTimerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30+_selectImageHeight, _selectViewWidth, 20)];
    _pointerTimerLabel.textColor = [UIColor whiteColor];
    _pointerTimerLabel.font = [UIFont systemFontOfSize:13];
    _pointerTimerLabel.textAlignment = NSTextAlignmentCenter;
    _pointerTimerLabel.text = @"0.00";
    [_selectView addSubview:_pointerTimerLabel];
    
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer {
    CGPoint translation = [recognizer translationInView:_selectView];
    
    CGFloat newX = recognizer.view.center.x + translation.x;
    if (newX < 0 || newX > _selectViewWidth) {
        [recognizer setTranslation:CGPointZero inView:_selectView];
        return;
    }
    
    
    _pointerView.center = CGPointMake(newX,30+_selectImageHeight/2);
    
    
    [recognizer setTranslation:CGPointZero inView:_selectView];
    
    
    int current = ((newX/_selectViewWidth)*CMTimeGetSeconds(_videoAsset.duration))/0.2;
    
    NSLog(@"array:%lu,current:%d",(unsigned long)_showImageArray.count,current);
    if (_showImageArray.count > current) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = _showImageArray[current];
            _showThumbImageView.image = image;
        });
    }
    
    _pointerTimerLabel.text = [NSString stringWithFormat:@"%0.2f",(newX/_selectViewWidth)*CMTimeGetSeconds(_videoAsset.duration)];
    
}


- (void)processImage1 {
    __weak ChangeThumbViewController *weakSelf = self;
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:self.haveCutVideoPath] options:nil];
    self.videoAsset = videoAsset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    _times = [NSMutableArray array];
    
    CMTime duration = videoAsset.duration;
    CMTimeValue intervalSeconds = duration.value / 6;
    
    CMTime time = kCMTimeZero;
    
    for (NSUInteger i = 0; i < 6; i++) {
        [_times addObject:[NSValue valueWithCMTime:time]];
        time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
    }
    
    
    self.selectViewImageArray  = [NSMutableArray array];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:_times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (image) {
            UIImage *myImage = [UIImage imageWithCGImage:image];
            [weakSelf.selectViewImageArray addObject:myImage];
        }
        
        if (weakSelf.times.count == weakSelf.selectViewImageArray.count) {
            NSLog(@"视频转图片1完成:%lu,requestedTime:%lld actualTime:%lld",(unsigned long)weakSelf.selectViewImageArray.count,requestedTime.value,actualTime.value);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processImage2];
            });
            
            
        } else {
            NSLog(@"1图片:%lu,requestedTime:%lld actualTime:%lld",(unsigned long)weakSelf.selectViewImageArray.count,requestedTime.value,actualTime.value);
        }
        
    }];
}

- (void)processImage2 {
    __weak ChangeThumbViewController *weakSelf = self;
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:self.haveCutVideoPath] options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    _times = [NSMutableArray array];
    
    int count = CMTimeGetSeconds(videoAsset.duration)/0.2;
    
    for (int i = 0; i <= count; i++) {
        //CMTime time = CMTimeMake(0.2*i*videoAsset.duration.timescale, videoAsset.duration.timescale);
        CMTime time = CMTimeMakeWithSeconds(0.2f*i, videoAsset.duration.timescale);
        //CMTime time = CMTimeMake(0.2, 1);
        [_times addObject:[NSValue valueWithCMTime:time]];
        
        
    }
    
    
    self.showImageArray  = [NSMutableArray array];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:_times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
        if (image) {
            UIImage *myImage = [UIImage imageWithCGImage:image];
            [weakSelf.showImageArray addObject:myImage];
        }
        
        if (weakSelf.times.count == weakSelf.showImageArray.count) {
            NSLog(@"视频转图片2完成:%lu,requestedTime:%lld actualTime:%lld",(unsigned long)weakSelf.showImageArray.count,requestedTime.value,actualTime.value);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupShowThumbView];
                [self setupSelectView];
                
                [self.view hideToastActivity];
            });
            
            
        } else {
            NSLog(@"2图片:%lu,requestedTime:%lld actualTime:%lld",(unsigned long)weakSelf.showImageArray.count,requestedTime.value,actualTime.value);
        }
        
    }];
}

@end
