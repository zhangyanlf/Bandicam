//
//  AddMusicViewController.m
//  liangchenbufu
//
//  Created by 张彦林 on 17/6/12.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//

#import "AddMisicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZylEffectMusic.h"
#import "PlayVideoView.h"

@interface AddMisicViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) PlayVideoView *playvideoView;
@property (nonatomic, strong) NSURL *saveMovieUrl;
@property (nonatomic, strong) NSURL *saveMixAudioUrl;
@property (nonatomic, strong) UICollectionView *collectionView;
/**音乐名称*/
@property (nonatomic, strong) UILabel *selectedMusicLabel;
/**音乐🎵图标*/
@property (nonatomic, strong) UIImageView *musicIconImageView;
/**显示音乐背景*/
@property (nonatomic, strong) UIImageView *nameBackImageView;
/**音乐数组*/
@property (nonatomic, strong) NSMutableArray *musicDataArray;

@property (nonatomic, assign) NSInteger selectedMusic;
@end

@implementation AddMisicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self setupMusic];
    [self setupTopView];
    [self setupView];
    [self setupCollectionView];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    self.selectedMusic = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)dealloc {
    
    NSLog(@"add music controller --- ---dealloc");
    
    
    if (!self.playvideoView.player.currentItem) {
        
        NSLog(@"-----------item is nil");
        
    } else {
        [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//设置音乐
- (void)setupMusic{
    NSString *baseDir = [[NSBundle mainBundle] bundlePath];
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"json"];
    NSData *configData = [NSData dataWithContentsOfFile:configPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:configData options:NSJSONReadingAllowFragments error:nil];
    NSArray *items = dic[@"music"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in items) {
        NSString *path = [baseDir stringByAppendingPathComponent:item[@"resourceUrl"]];
        
        ZylEffectMusic *effect = [[ZylEffectMusic alloc] init];
        effect.name = item[@"name"];
        effect.eid = item[@"id"];
        effect.filePath = [path stringByAppendingPathComponent:@"audio.mp3"];
        effect.iconPath = [path stringByAppendingPathComponent:@"icon_without_name.png"];
        [array addObject:effect];
    }
    
    self.musicDataArray = array;
}

//设置假导航View
- (void)setupTopView{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.view addSubview:topView];
    topView.backgroundColor = COLOR_MAIN;
    
    //返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"chart_back.imageset"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width-120, 50)];
    nameLabel.text = @"添加背景音乐";
    nameLabel.font = [UIFont systemFontOfSize:20];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:nameLabel];
    
    UIButton *markButton = [[UIButton alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, SCREEN_HEIGHT-60, 200, 40)];
    //[markButton setImage:[UIImage ```imageNamed:@"login_button_confirm"] forState:UIControlStateNormal];
    
    [markButton setTitle:@"下一步" forState:UIControlStateNormal];
    [markButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [markButton setBackgroundColor:COLOR_MAIN];
    markButton.titleLabel.font = [UIFont systemFontOfSize:16];
    markButton.layer.cornerRadius = 15;
    markButton.layer.masksToBounds = YES;
    [markButton addTarget:self action:@selector(markButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:markButton];
    
}
- (void)backButtonClicked:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)markButtonClicked:(UIButton *)button {
    //最终确定
    [self.view makeToast:@"下一步暂未实现" duration:0.8 position:CSToastPositionCenter];
    /*
    if (self.selectedMusic == 0) {
        [self deleteMovieFile];
        [self.delegate addMusicFinsh:self.videoPath];
        
    } else {
        NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        urlStr = [urlStr stringByAppendingPathComponent:@"newMovie.mov"];
        [self.delegate addMusicFinsh:urlStr];
    }
     */
}
- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-200, [UIScreen mainScreen].bounds.size.width, 110) collectionViewLayout:flowLayout];
    
    [self.view addSubview:self.collectionView];
    _collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"SelectMusicCollectionCell"];
    
}

#pragma mark - Collection Delegate/DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.musicDataArray.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90,105);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectMusicCollectionCell" forIndexPath:indexPath];
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    if (indexPath.item == 0) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 80, 80)];
        imageView.image = [UIImage imageNamed:@"music_0"];
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 85, 90, 20)];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:13];
        nameLabel.text = @"原音";
        [cell.contentView addSubview:nameLabel];
        
        cell.selectedBackgroundView.backgroundColor = COLOR_MAIN;
        
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 105)];
        cell.selectedBackgroundView.backgroundColor = COLOR_MAIN;
        return cell;
    } else {
        ZylEffectMusic *effect = self.musicDataArray[indexPath.item-1];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 80, 80)];
        imageView.image = [UIImage imageWithContentsOfFile:effect.iconPath];
        [cell.contentView addSubview:imageView];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 85, 90, 20)];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:13];
        nameLabel.text = effect.name;
        [cell.contentView addSubview:nameLabel];
        
        cell.selectedBackgroundView.backgroundColor = COLOR_MAIN;
        
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 90, 105)];
        cell.selectedBackgroundView.backgroundColor = COLOR_MAIN;
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZylEffectMusic *effect;
    
    if (indexPath.item == 0) {
        self.musicIconImageView.image = [UIImage imageNamed:@"edit_ico_music"];
        self.selectedMusicLabel.text = @"原音";
    } else {
        self.musicIconImageView.image = [UIImage imageNamed:@"edit_ico_music_1"];
        
        effect = self.musicDataArray[indexPath.item-1];
        self.selectedMusicLabel.text = effect.name;
    }
    
    CGRect rect = [self.selectedMusicLabel textRectForBounds:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, 30) limitedToNumberOfLines:1];
    self.nameBackImageView.frame = CGRectMake(0, 0, rect.size.width+30+30, 30);
    self.selectedMusicLabel.frame = CGRectMake(40, 0, rect.size.width, 30);

    self.view.userInteractionEnabled = NO;
    
    if (indexPath.item == 0) {
        [self resetPlayerOrigin];
    } else {
        [self makeMixAudio:effect.filePath];
    }
    
}


- (void)setupView
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    if ([self.resolution isEqualToString:@"480*640"]) {
        self.playvideoView = [[PlayVideoView alloc]initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width/3*4)];
    } else {
        self.playvideoView = [[PlayVideoView alloc]initWithFrame:CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    }
    
    self.playvideoView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.playvideoView];
    
    UIImageView *nameBackImageView = [[UIImageView alloc]init];
    nameBackImageView.image = [UIImage imageNamed:@"shadow_size"];
    [self.playvideoView addSubview:nameBackImageView];
    
    self.selectedMusicLabel = [[UILabel alloc]init];
    self.selectedMusicLabel.text = @"原音";
    CGRect rect = [self.selectedMusicLabel textRectForBounds:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/2, 30) limitedToNumberOfLines:1];
    nameBackImageView.frame = CGRectMake(0, 0, rect.size.width+30+30, 30);
    
    self.selectedMusicLabel.frame = CGRectMake(40, 0, rect.size.width, 30);
    self.selectedMusicLabel.textColor = [UIColor whiteColor];
    [nameBackImageView addSubview:self.selectedMusicLabel];
    
    UIImageView *musicIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 6, 15, 17)];
    musicIconImageView.image = [UIImage imageNamed:@"edit_ico_music"];
    self.musicIconImageView = musicIconImageView;
    [nameBackImageView addSubview:musicIconImageView];
    
    self.nameBackImageView = nameBackImageView;
    
    
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
    
    self.playvideoView.player = player;
    self.playvideoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playvideoView.player seekToTime:kCMTimeZero];
    
    [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(catchTap:)];
    [self.playvideoView addGestureRecognizer:tap];
    
    [self.playvideoView.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playvideoView.player.currentItem];
    
}

- (void)resetPlayer {
    [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AVPlayer *player = [AVPlayer playerWithURL:self.saveMovieUrl];
    self.playvideoView.player = player;
    self.playvideoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playvideoView.player seekToTime:kCMTimeZero];
    [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playvideoView.player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playvideoView.player.currentItem];
    NSLog(@"重新播放");
    self.view.userInteractionEnabled = YES;
    self.selectedMusic = 1;
}

- (void)resetPlayerOrigin {
    [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.playvideoView.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.videoPath]];
    self.playvideoView.player = player;
    self.playvideoView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playvideoView.player seekToTime:kCMTimeZero];
    [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playvideoView.player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playvideoView.player.currentItem];
    NSLog(@"重新播放");
    self.view.userInteractionEnabled = YES;
    self.selectedMusic = 0;
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    [self.playvideoView.player seekToTime:kCMTimeZero];
    [self.playvideoView.player play];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            
            AVPlayerItem *playerItem=object;
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            //self.videoTotalTime = CMTimeGetSeconds(playerItem.duration);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        
#ifdef _MY_DEBUG_NSTimeInterval
        AVPlayerItem *playerItem=object;
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        NSLog(@"共缓冲：%.2f",totalBuffer);
#endif
        
        
    }
}
#pragma mark - 点击视频
-(void)catchTap:(UITapGestureRecognizer *)tap{
    [self.playvideoView.player seekToTime:kCMTimeZero];
    [self.playvideoView.player play];
}


- (void)makeVideoAudio { //音视 合成
    //创建Composition
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    //向Composition中 添加Composition Track
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
  
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:self.saveMixAudioUrl options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    if (!audioAsset) {
        
        NSLog(@"audioBackAsset error");
        
        
        return;
    }
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoPath] options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    if (!videoAsset) {
        
        NSLog(@"videoAsset error");
    }
    
    //创建Asset track
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    if (!audioAssetTrack) {
        
        NSLog(@"audioAssetTrack error");
        
    }
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo]objectAtIndex:0];
    if (!videoAssetTrack) {
        
        NSLog(@"videoAssetTrack error");
        
    }
    
    NSError *error;
    //向Composition track 中 添加 Asset track
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:&error];
    if (error) {
        
        NSLog(@"添加videoAssetTrack error:%@",error.userInfo);
        
    }
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    if (error) {
        NSLog(@"添加audioASsetTrack error:%@",error.userInfo);
        
    }
    
    //检查一下视频方向，是不是 肖像模式。
    CGAffineTransform firstTransform = videoAssetTrack.preferredTransform;
    if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
        
        NSLog(@"视频是肖像模式");
        
        
    } else {
        
        NSLog(@"视频不是肖像模式");
        
        
    }
    
    //Exporting: 输出 音频 视频 合成后的Movie文件, 以时间作为文件名，类型自动生成
    static NSDateFormatter *kDateFormatter;
    if (!kDateFormatter) {
        kDateFormatter = [[NSDateFormatter alloc] init];
        kDateFormatter.dateStyle = NSDateFormatterMediumStyle;
        kDateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    [self deleteMovieFile];
    
    exporter.outputURL = self.saveMovieUrl;
    
    exporter.outputFileType = AVFileTypeMPEG4;//AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    //exporter.videoComposition = mutableVideoComposition;
    
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                
                NSLog(@"音频视频合成输出完成");
                
                
                
                [self deleteMixAudioFile];
                [self resetPlayer];
                
            }
            switch (exporter.status) {
                case AVAssetExportSessionStatusUnknown:
                    
                    NSLog(@"?");
                    
                    
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"-");
                    
                    
                    break;
                case AVAssetExportSessionStatusExporting:
                    
                    NSLog(@".");
                    
                    
                    break;
                case AVAssetExportSessionStatusCompleted:
                    
                    NSLog(@"export completed!");
                    
                    
                    break;
                case AVAssetExportSessionStatusFailed:
                    
                    NSLog(@"export failed!");
                    
                    
                    break;
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"export cancelled!");
                    
                    
                    break;
                default:
                    break;
            }
        });
    }];
    
    
}

- (NSURL *)saveMovieUrl {
    if (!_saveMovieUrl) {
        NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        urlStr = [urlStr stringByAppendingPathComponent:@"newMovie.mov"];
        _saveMovieUrl = [NSURL fileURLWithPath:urlStr];
    }
    return _saveMovieUrl;
}
- (void)deleteMovieFile {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"newMovie.mov"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:urlStr]) {
        [[NSFileManager defaultManager]removeItemAtPath:urlStr error:nil];
    }
}
- (NSURL *)saveMixAudioUrl {
    if (!_saveMixAudioUrl) {
        NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        urlStr = [urlStr stringByAppendingPathComponent:@"mixAudio.mov"];
        _saveMixAudioUrl = [NSURL fileURLWithPath:urlStr];
    }
    return _saveMixAudioUrl;
}
- (void)deleteMixAudioFile {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"mixAudio.mov"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:urlStr]) {
        [[NSFileManager defaultManager]removeItemAtPath:urlStr error:nil];
    }
}

- (void)makeMixAudio:(NSString *)backAudiofilePath{
    //创建Composition
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    //向Composition中 添加Composition Track
    AVMutableCompositionTrack *audioBackCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //创建Assets
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoPath] options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    if (!audioAsset) {
        
        NSLog(@"audioAsset error");
        
        
        return;
    }
    //NSString *backAudioFilePath = [[NSBundle mainBundle] pathForResource:@"music_qingshu1" ofType:@"mp3"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:backAudiofilePath]) {
        
        NSLog(@"文件存在");
        
        
    }
    NSURL *backAudioFileUrl = [NSURL fileURLWithPath:backAudiofilePath];
    AVURLAsset *audioBackAsset = [AVURLAsset URLAssetWithURL:backAudioFileUrl options:@{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    if (!audioBackAsset) {
        
        NSLog(@"audioBackAsset error");
        
        
        return;
    }
    
    //创建Asset track
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    if (!audioAssetTrack) {
        
        NSLog(@"audioAssetTrack error");
        
        return;
    }
    AVAssetTrack *audioBackAssetTrack = [[audioBackAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    if (!audioBackAssetTrack) {
        
        NSLog(@"audioBackAssetTrack error");
        
        
        return;
    }
    
    NSError *error;
    //向Composition track 中 添加 Asset track
    
    CGFloat backAssetTimeValue = audioBackAssetTrack.timeRange.duration.value/audioBackAssetTrack.timeRange.duration.timescale;
    
    CGFloat audioAssetTimeValue = audioAsset.duration.value/audioAsset.duration.timescale;
    
    
    NSLog(@"back: %f,  audio: %f",backAssetTimeValue,audioAssetTimeValue);
    
    
    
    if (backAssetTimeValue >= audioAssetTimeValue) {
        [audioBackCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioBackAssetTrack atTime:kCMTimeZero error:&error];
        if (error) {
            
            NSLog(@"添加audioBackAssetTrack error1:%@",error.userInfo);
            
            return;
        }
    } else {
        [audioBackCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioBackAssetTrack.timeRange.duration) ofTrack:audioBackAssetTrack atTime:kCMTimeZero error:&error];
        if (error) {
            
            NSLog(@"添加audioBackAssetTrack error2:%@",error.userInfo);
            
            return;
        }
        
        CMTime audioDuration = audioAsset.duration;
        CMTime backAudioDuration = audioBackAssetTrack.timeRange.duration;
        
        CGFloat needTime = audioDuration.value/audioDuration.timescale - backAudioDuration.value/backAudioDuration.timescale;
        
        
        NSLog(@"needTime: %f",needTime);
        

        CMTime time = CMTimeMake(needTime*backAudioDuration.timescale, backAudioDuration.timescale);
        
        [audioBackCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, time) ofTrack:audioBackAssetTrack atTime:audioBackAssetTrack.timeRange.duration error:&error];
        if (error) {
            
            NSLog(@"添加audioBackAssetTrack error3:%@",error.userInfo);
            
            return;
        }
    }
    
    [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:&error];
    if (error) {
        
        NSLog(@"添加audioAssetTrack error:%@",error.userInfo);
        
        
        return;
    } else {
        
        NSLog(@"set ok");
        
        
    }
    
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    exporter.outputURL = self.saveMixAudioUrl;
    [self deleteMixAudioFile];
    
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
        
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exporter.status == AVAssetExportSessionStatusCompleted) {
                
                NSLog(@"音频合成输出完成");
                
                
                [self makeVideoAudio];
            }
            switch (exporter.status) {
                case AVAssetExportSessionStatusUnknown:
                    
                    NSLog(@"?");
                    
                    
                    break;
                case AVAssetExportSessionStatusWaiting:
                    
                    NSLog(@"-");
                    
                    
                    break;
                case AVAssetExportSessionStatusExporting:
                    
                    NSLog(@".");
                    
                    
                    break;
                case AVAssetExportSessionStatusCompleted:
                    
                    NSLog(@"export completed!");
                    
                    
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"export failed!");
                    
                    
                    break;
                case AVAssetExportSessionStatusCancelled:
                    
                    NSLog(@"export cancelled!");
                    
                    
                    break;
                default:
                    break;
            }
        });
    }];
}

@end
