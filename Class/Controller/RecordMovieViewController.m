//
//  RecordMovieViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/9.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//
/**
 *
 *录制视频
 */

#import "RecordMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GPUImage.h"
#import "UIView+Toast.h"



@interface RecordMovieViewController ()
/**为实时摄影添加滤镜*/
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
/**显示GPUImage输出*/
@property (strong, nonatomic) GPUImageView *filterView;
/**录制视频*/
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) NSMutableDictionary * videoSettings;
@property (nonatomic, strong) NSDictionary * audioSettings;
@property (nonatomic, strong) NSURL * urlToMovie;

@property (nonatomic, strong) UIButton *beautifyButton;
@property (nonatomic, strong) UILabel *degreeLabel;
/**美颜滤镜*/
@property (strong, nonatomic) GPUImageBeautifyFilter *beautifyFilter;
/**本地视频按钮*/
@property (nonatomic, strong) UIButton *localVideoButton;
/**删除按钮*/
@property (nonatomic, strong) UIButton *deleteButton;
/**录制按钮*/
@property (nonatomic, strong) UIButton *transcribeBtn;
/**录制完成按钮*/
@property (nonatomic, strong) UIButton *finishButton;
/**闪关灯按钮*/
@property (nonatomic, strong) UIButton *flashButton;
/**美颜框*/
@property (nonatomic, strong) UIView *changeBeautyView;
/**底部录制进度View*/
@property (nonatomic, strong) UIView *recordProgressView;
/**进度Label*/
@property (nonatomic, strong) UILabel *progressLabel;
/**添加一个能让我们以和屏幕刷新率相同的频率将内容画到屏幕上的定时器*/
@property (nonatomic, strong) CADisplayLink* dlink;

@property (nonatomic, assign) BOOL firstRecvVolume;

//test
@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) NSString *thumbnailPath;
@property (nonatomic, strong) NSString *originalVideoPath;
@property (nonatomic, strong) NSString *waterVideoPath;
/** NO:没有拍过*/
@property (nonatomic, assign) BOOL isStartRecord;
/**YES:正在拍摄*/
@property (nonatomic, assign) BOOL isRecording;
@end

@implementation RecordMovieViewController
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *waterWriter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR(0x2d, 0x2e, 0x33, 1);
    //不自动调整内容
    self.automaticallyAdjustsScrollViewInsets = NO;
//    在Caches目录下创建文件
    self.thumbnailPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    self.thumbnailPath = [_thumbnailPath stringByAppendingPathComponent:@"thumbnail.jpg"];
    
    self.originalVideoPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.originalVideoPath = [self.originalVideoPath stringByAppendingPathComponent:@"originalMovie.mov"];
    
    self.waterVideoPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.waterVideoPath = [self.waterVideoPath stringByAppendingPathComponent:@"waterMovie.mov"];
    
    self.firstRecvVolume = YES;
    
    [self setUpVideoCamera];
    
//    添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(volumeClicked:) name:@"VolumeDidChangeNotification" object:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *audio = [AVAudioSession sharedInstance];
    [audio setActive:YES error:nil];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-20, -20, 10, 10)];
    volumeView.hidden = NO;
    [self.view addSubview:volumeView];
    
    [self setUpButton];
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.videoCamera stopCameraCapture];
    [self.videoCamera removeAudioInputsAndOutputs];
    [_dlink invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)dealloc {
    NSLog(@"--------- record movie vc dealloc----------");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpVideoCamera {
    
    //初始化Video
    /**
     *AVVideoCodecKey
     *AVVideoWidthKey
     *AVVideoHeightKey
     *AVVideoCompressionPropertiesKey
     */
    self.videoSettings = [[NSMutableDictionary alloc] init];
    [self.videoSettings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [self.videoSettings setObject:[NSNumber numberWithInt:480] forKey:AVVideoWidthKey];
    [self.videoSettings setObject:[NSNumber numberWithInt:640] forKey:AVVideoHeightKey];
    
    NSMutableDictionary *compressionProperties = [[NSMutableDictionary alloc] init];
    [compressionProperties setObject:[NSNumber numberWithLong:1500*1000] forKey:AVVideoAverageBitRateKey];
    
    [self.videoSettings setObject:compressionProperties forKey:AVVideoCompressionPropertiesKey];
    
    //初始化audio
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    self.audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
        [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
        [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
        [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
        [NSNumber numberWithInt:32000], AVEncoderBitRateKey,
                           nil];
    
    
    //初始化文件路径和视频写入对象
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.originalVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.originalVideoPath error:nil];
    }
    
    _urlToMovie = [NSURL fileURLWithPath:self.originalVideoPath];
    
    //摄像头
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    [_videoCamera addAudioInputsAndOutputs];
    
    //屏幕显示
    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / 3 * 4)];
    [self.view addSubview:_filterView];
    
    //美颜
    _beautifyFilter= [[GPUImageBeautifyFilter alloc] init];
    _beautifyFilter.degree = 0.5;
    
    [self.videoCamera addTarget:_beautifyFilter];
    
    [_beautifyFilter addTarget:self.filterView];
    
    [self.videoCamera startCameraCapture];
    
    _dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [_dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _dlink.paused = NO;
    
    
    
}


- (void) setUpButton {
    //关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame =CGRectMake(0, 0, 60, 50);
    [self.view addSubview:closeButton];
    [closeButton setImage:[UIImage imageNamed:@"record_btn_colse_24_24"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    //闪关灯
    UIButton *flashButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 180, 0, 60, 50)];
    [flashButton setImage:[UIImage imageNamed:@"record_btn_light_off_24_24"] forState:UIControlStateNormal];
    [self.view addSubview:flashButton];
    [flashButton addTarget:self action:@selector(openFlashBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.flashButton = flashButton;
    self.flashButton.enabled = NO;
    
    
    //美颜
    UIButton *beautyButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0, 60, 50)];
    [beautyButton setImage:[UIImage imageNamed:@"record_btn_beauty_24_24"] forState:UIControlStateNormal];
    [self.view addSubview:beautyButton];
    [beautyButton addTarget:self action:@selector(beautyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //翻转摄像头
    UIButton *rollingOverButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, 50)];
    [rollingOverButton setImage:[UIImage imageNamed:@"record_btn_change_24_24"] forState:UIControlStateNormal];
    [self.view addSubview:rollingOverButton];
    [rollingOverButton addTarget:self action:@selector(rollingOverBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //美颜框
    self.changeBeautyView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 30, 60, SCREEN_WIDTH/2 + 30, 30)];
    self.changeBeautyView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    [self.view addSubview:self.changeBeautyView];
    self.changeBeautyView.layer.cornerRadius = 15;
    self.changeBeautyView.layer.masksToBounds = YES;
    
    UILabel *beautylabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
    [self.changeBeautyView addSubview:beautylabel];
    beautylabel.textColor = [UIColor blackColor];
    beautylabel.text = @"美颜";
    beautylabel.textAlignment = NSTextAlignmentCenter;
    beautylabel.font = [UIFont systemFontOfSize:13];
    
    UISlider *beautySlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 0, self.changeBeautyView.frame.size.width - 40, 30)];
    [self.changeBeautyView addSubview:beautySlider];
    beautySlider.value = 0.5;
    beautySlider.tintColor = COLOR_MAIN;
    [beautySlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.changeBeautyView.hidden = YES;
    
    //底部录制进度View
    self.recordProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH / 3 * 4, 0, 6)];
    self.recordProgressView.backgroundColor = COLOR_MAIN;
    [self.view addSubview:self.recordProgressView];
    
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.recordProgressView.frame.origin.y - 20, 40, 20)];
    self.progressLabel.backgroundColor = [UIColor whiteColor];
    self.progressLabel.textColor = [UIColor blackColor];
    self.progressLabel.font = [UIFont systemFontOfSize:10];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.layer.cornerRadius = 10;
    self.progressLabel.layer.masksToBounds = YES;
    
    [self.view addSubview:self.progressLabel];
    self.progressLabel.hidden = YES;
    
    //删除按钮
    UIButton *delButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH / 2 - 100)/2, SCREEN_WIDTH / 3 * 4 + 40, 60, 60)];
    delButton.layer.cornerRadius = 30;
    delButton.layer.masksToBounds = YES;
    delButton.backgroundColor = COLOR(0x39, 0x3c, 0x43, 1);
    [delButton setImage:[UIImage imageNamed:@"record_btn_del_25_25"] forState:UIControlStateNormal];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    delButton.hidden = YES;
    self.deleteButton = delButton;
    
    //录制按钮
    UIButton *transcribeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, SCREEN_WIDTH /3 * 4 + 30, 80, 80)];
    transcribeBtn.layer.cornerRadius = 40;
    transcribeBtn.layer.masksToBounds = YES;
    transcribeBtn.backgroundColor = [UIColor clearColor];
    [transcribeBtn setTitle:@"录制" forState:UIControlStateNormal];
    [transcribeBtn setBackgroundImage:[UIImage imageNamed:@"record_btn_start_79_79"] forState:UIControlStateNormal];
    [self.view addSubview:transcribeBtn];
    [transcribeBtn addTarget:self action:@selector(transcribeClick:) forControlEvents:UIControlEventTouchUpInside];
    self.transcribeBtn = transcribeBtn;
    
    //选择相册按钮
     UIButton *localVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     localVideoBtn.frame = CGRectMake((SCREEN_WIDTH-150)/2-5, SCREEN_HEIGHT-40, 150, 40);
    localVideoBtn.backgroundColor = [UIColor clearColor];
    [localVideoBtn setTitle:@"从相册中选择" forState:UIControlStateNormal];
    [localVideoBtn setImage:[UIImage imageNamed:@"login_button_next"] forState:UIControlStateNormal];
    [localVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    localVideoBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 115, 0, 0);
    localVideoBtn.titleEdgeInsets =UIEdgeInsetsMake(0, -50, 0, 0);
    [localVideoBtn addTarget:self action:@selector(clickLocalVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:localVideoBtn];
    self.localVideoButton = localVideoBtn;
    
    //完成按钮
    UIButton *finishButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 40 + (SCREEN_WIDTH / 2 - 100) / 2, SCREEN_WIDTH / 3 * 4 + 40, 60, 60)];
    finishButton.layer.cornerRadius = 30;
    finishButton.layer.masksToBounds = YES;
    finishButton.backgroundColor = COLOR(0x39, 0x3c, 0x43, 1);
    [finishButton setImage:[UIImage imageNamed:@"record_btn_ok_25_25"] forState:UIControlStateNormal];
    [self.view addSubview:finishButton];
    [finishButton addTarget:self action:@selector(clickFinishBtn) forControlEvents:UIControlEventTouchUpInside];
    finishButton.hidden = YES;
    self.finishButton = finishButton;
 
}
/**重新初始化*/
- (void) restartWriter {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.originalVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.originalVideoPath error:nil];
    }
        _urlToMovie = [NSURL fileURLWithPath:self.originalVideoPath];
        
        //初始化movieWriter
        self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:_urlToMovie size:CGSizeMake(480.0, 640.0) fileType:AVFileTypeQuickTimeMovie outputSettings:self.videoSettings];
        self.movieWriter.hasAudioTrack = YES;
        self.movieWriter.shouldPassthroughAudio = YES;
        self.movieWriter.encodingLiveVideo = YES;
        
        [self.movieWriter enableSynchronizationCallbacks];
        
        [_beautifyFilter addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = self.movieWriter;
        
        self.movieWriter.paused = NO;
        [self.movieWriter startRecording];
    
}

#pragma mark - ButtonClickSelector
//关闭按钮
- (void) closeBtnClick {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//闪关灯
- (void) openFlashBtClicked:(UIButton *)btn {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]) {
        NSLog(@"no torch");
    } else {
        [device lockForConfiguration:nil];
        
        if (btn.tag == 0) {
            btn.tag = 1;
            [btn setImage:[UIImage imageNamed:@"record_btn_light_on_24_24"] forState:UIControlStateNormal];
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            btn.tag = 0;
            [btn setImage:[UIImage imageNamed:@"record_btn_light_off_24_24"] forState:UIControlStateNormal];
             [device setTorchMode: AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

//美颜
- (void) beautyBtnClick:(UIButton *)btn {
    
    if (btn.tag == 0) {
        btn.tag = 1;
        self.changeBeautyView.hidden = NO;
    } else {
        btn.tag = 0;
        self.changeBeautyView.hidden = YES;
    }
    
}

//翻转摄像头
- (void) rollingOverBtnClick:(UIButton *)btn {
    self.firstRecvVolume = YES;
    if (btn.tag == 0) {
        btn.tag = 1;
        
        [self rollingCamera:1];
    } else {
        btn.tag = 0;
        [self rollingCamera:2];
    }
    
}

//slider方法
- (void) sliderChanged:(UISlider *)slider {
    NSLog(@"slider:%f",slider.value);
    _beautifyFilter.degree = slider.value;
}

//删除按钮
- (void) delBtnClick:(UIButton *)btn {
    btn.hidden = YES;
    self.finishButton.hidden = YES;
    self.transcribeBtn.tag = 0;
    self.isStartRecord = NO;
    self.isRecording = NO;
    
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [_movieWriter cancelRecording];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.transcribeBtn.hidden = NO;
            [self.transcribeBtn setBackgroundImage:[UIImage imageNamed:@"record_btn_start_79_79"] forState:UIControlStateNormal];
        });
    }];
    self.recordProgressView.frame = CGRectMake(0, SCREEN_WIDTH / 3 * 4, 0, 6);
    self.progressLabel.hidden = YES;
}

//录制按钮
- (void) transcribeClick:(UIButton *)btn {
    if (btn.tag == 0) {
        btn.tag = 1;
        [btn setTitle:@"暂停" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"record_btn_stop_79_79"] forState:UIControlStateNormal];
     
        if (!_isStartRecord) {
            //重新初始化
            [self restartWriter];
            
            self.isStartRecord = YES;
            self.isRecording = YES;
        } else {
            //继续拍摄
            _movieWriter.paused = NO;
            self.isRecording = YES;
            self.finishButton.hidden = YES;
            self.deleteButton.hidden = YES;
        }
        
    } else if (btn.tag == 1) {
        btn.tag = 0;
        [btn setTitle:@"录制" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"record_btn_start_79_79"] forState:UIControlStateNormal];
        
        _movieWriter.paused = YES; //暂停录制
        self.isRecording = NO;
        
        self.deleteButton.hidden = NO;
        //录制时间
        float exceedSecond = (float)_movieWriter.duration.value / _movieWriter.duration.timescale;
        
        NSLog(@"_movieWriter.duration.value--%lld",_movieWriter.duration.value);
        NSLog(@"_movieWriter.duration.timesca--%d",_movieWriter.duration.timescale);
        NSLog(@"exceedSecond-----%f",exceedSecond);
        
#warning  (float) _movieWriter.duration.value / _movieWriter.duration.timescale 打印nan 已解决  初始化_movieWriter问题
        if (exceedSecond >= 2) {
            self.finishButton.hidden = NO;
        }
    }
    
}

//选择本地视频
- (void) clickLocalVideo {
    [self.view makeToast:@"本地视频功能未开发" duration:0.8 position:CSToastPositionCenter];
    [self.delegate changeLocalVideo];
}

//录制完成动作
- (void) clickFinishBtn {
    NSLog(@"movie: value---%lld,timescale---%d",_movieWriter.duration.value, _movieWriter.duration.timescale);
    
    _movieWriter.paused = YES;
    _videoCamera.audioEncodingTarget = nil;
    
    [self.filterView makeToastActivity:CSToastPositionCenter];
    _finishButton.enabled = NO;
    _transcribeBtn.enabled = NO;
    _deleteButton.enabled = NO;
    
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [_movieWriter cancelRecording];
        
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
           [self processThumbImage];
       });
    }];
    
}


#pragma mark - NSNotification
- (void) volumeClicked:(NSNotification *)notification {
    NSLog(@"volume:%@",notification.userInfo);
    
    if (self.firstRecvVolume) {
        self.firstRecvVolume = NO;
        return;
    }
    if (self.transcribeBtn.hidden == YES) {
        return;
    }
    [self transcribeClick:self.transcribeBtn];
    
}




#pragma mark - CADisplayLinkSelector
- (void) updateProgress {
    
    if (self.isRecording) {
        float second = (float)_movieWriter.duration.value/_movieWriter.duration.timescale;
        float progressPerSecond = SCREEN_WIDTH/15;
        float progressPerSecond2 = (SCREEN_WIDTH-40)/15;
        
        self.recordProgressView.frame = CGRectMake(0, SCREEN_WIDTH/3*4,progressPerSecond*second, 6);
        self.progressLabel.center = CGPointMake(20+progressPerSecond2*second, self.progressLabel.frame.origin.y+10);
        self.progressLabel.text = [NSString stringWithFormat:@"%2.1f",second];
        self.progressLabel.hidden = NO;
        if (second > 15) {
            
            _movieWriter.paused = YES;
            self.transcribeBtn.hidden = YES;
            self.finishButton.hidden = NO;
            self.deleteButton.hidden = NO;
        }
    }
    
}

#pragma mark - Other

- (void) rollingCamera:(int)camera {
    //前置摄像头和后置摄像头之间的翻转
    [_videoCamera rotateCamera];
    
    if (_videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        self.flashButton.tag = 0;
        [self.flashButton setImage:[UIImage imageNamed:@"record_btn_light_off_24_24"] forState:UIControlStateNormal];
        self.flashButton.enabled = NO;
    } else {
        self.flashButton.enabled = YES;
    }
    
}

//使用GPUImage加载水印
- (void) processThumbImage {
    // 滤镜
    filter = [[GPUImageAlphaBlendFilter alloc] init];
    [(GPUImageAlphaBlendFilter *)filter setMix:1.0];
    
    // 播放
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.originalVideoPath]) {
        NSLog(@"合成水印，视频文件不存在");
    }
    
    NSURL *sampleURL= [NSURL fileURLWithPath:self.originalVideoPath];
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = NO;
    
    
    UIImage *image = [UIImage imageNamed:@""];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 640)];
    subView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(480-88, 640-55, 52/2*3, 45);
    [subView addSubview:imageView];
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.waterVideoPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.waterVideoPath error:nil];
    }
    NSURL *movieURL= [NSURL fileURLWithPath:self.waterVideoPath];
    
    waterWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0) fileType:AVFileTypeQuickTimeMovie outputSettings:self.videoSettings];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [movieFile addTarget:progressFilter];
    [progressFilter addTarget:filter];
    [uielement addTarget:filter];
    waterWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = waterWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:waterWriter];
    // 显示到界面
    // [filter addTarget:filterView];
    [filter addTarget:waterWriter];
 
    [movieFile startProcessing];
    [waterWriter startRecording];
    
    __weak typeof(self) weakSelf = self;
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        NSLog(@"%f",(float)time.value/time.timescale);
        if (weakSelf.thumbImage == nil && (float)time.value/time.timescale >0.5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [output useNextFrameForImageCapture];
                UIImage *image = [output imageFromCurrentFramebuffer];
                NSLog(@"image:%@",image);
                weakSelf.thumbImage = image;
                
            });
        }
        
        [uielement updateWithTimestamp:time];
    }];
    
    [waterWriter setCompletionBlock:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf->waterWriter finishRecording];
        [weakSelf.dlink invalidate];
        [weakSelf.videoCamera stopCameraCapture];
        [strongSelf->filter removeTarget:strongSelf->waterWriter];
        NSLog(@"处理完成");
        NSData *imageData = UIImageJPEGRepresentation(weakSelf.thumbImage, 0.5);
        if (![imageData writeToFile:weakSelf.thumbnailPath atomically:YES]){
            NSLog(@"缩略图写入文件失败");
        }
        [weakSelf.filterView hideToastActivity];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate RecordFinsh:weakSelf.waterVideoPath ThumbImage:weakSelf.thumbnailPath];
        });
        
        
    }];
}

@end





















