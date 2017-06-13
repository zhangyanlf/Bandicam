//
//  ZylUploadViewController.m
//  Bandicam
//
//  Created by 张彦林 on 17/6/13.
//  Copyright © 2017年 zhangyanlf. All rights reserved.
//



#import "ZylUploadViewController.h"
#import "AddMisicViewController.h"
#import "ChangeThumbViewController.h"
#import "UserInfo.h"
#import "ToolCommon.h"
#import "AFNRequestData.h"
#import "UIImageView+WebCache.h"



@interface ZylUploadViewController ()<UITextViewDelegate,UIScrollViewDelegate,ChangeThumbViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *ThumbButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *addLinkButton;
@property (nonatomic, strong) UIButton *uploadButton;

@property (nonatomic, assign) BOOL isClose;

//商品信息
@property (nonatomic, strong) UIView *goodsView;
@property (nonatomic, strong) UIImageView *goodsImageView;
@property (nonatomic, strong) UILabel *goodsNameLabel;
@property (nonatomic, strong) UILabel *goodsPriceLabel;
@property (nonatomic, strong) UILabel *goodsInfoLabel1;
@property (nonatomic, strong) UILabel *goodsInfoLabel2;
@property (nonatomic, strong) UILabel *goodsInfoLabel3;
@property (nonatomic, strong) UIButton *goodsDeleteButton;
@property (nonatomic, strong) NSString *goodsId;
@property (nonatomic, strong) NSString *goodsExtendId;
@property (nonatomic, strong) NSString *goodsImageStr;
@property (nonatomic, strong) NSString *goodsName;
@property (nonatomic, strong) NSString *goodsPrice;
@property (nonatomic, strong) NSString *goodsInfo1;
@property (nonatomic, strong) NSString *goodsInfo2;
@property (nonatomic, strong) NSString *goodsInfo3;
@property (nonatomic, strong) NSString *goodsSizeId;
@property (nonatomic, strong) NSString *goodsUrl;
@property (nonatomic, assign) BOOL isKucun;

@property (nonatomic, strong) NSString *goodsType;
@property (nonatomic, assign) BOOL isPushSizeVC;
@end

@implementation ZylUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.isPushSizeVC = YES;
    self.goodsId = @"";
    [self setupTopView];
    [self setupView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGoodsLink:) name:@"Notification_GoodsLink" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGoodsLink2:) name:@"Notification_GoodsLink2" object:nil];
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
    if (_isClose) {
        self.navigationController.navigationBar.hidden = NO;
    }
    
}

//- (void)viewDidAppear:(BOOL)animated {
//    if (self.goodsDict && self.isPushSizeVC) {
//        SelectSizeViewController *vc = [[SelectSizeViewController alloc]init];
//        vc.goodsDict = [self.goodsDict copy];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"----------- upload video dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//--------------------

- (void)setupTopView{
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.view addSubview:topView];
    topView.backgroundColor = COLOR_MAIN;
    
    //返回按钮
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"record_btn_colse_24_24"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width-120, 50)];
    nameLabel.text = @"发布视频";
    nameLabel.font = [UIFont systemFontOfSize:20];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:nameLabel];
}
- (void)backButtonClicked:(id)sender {
    self.isClose = YES;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//------------------------
- (void)setupView {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT-50)];
    scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    scrollView.delegate = self;
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    UIImage *videoImage = [UIImage imageWithContentsOfFile:self.thumbImagePath];
    _videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/4, 25, SCREEN_WIDTH/2, SCREEN_WIDTH/2/videoImage.size.width*videoImage.size.height)];
    _videoImageView.userInteractionEnabled = YES;
    _videoImageView.image = videoImage;
    
    _progressView = [[UIView alloc]initWithFrame:CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y-10, 0, 5)];
    _progressView.backgroundColor = COLOR_MAIN;
    [scrollView addSubview:_progressView];
    
    _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(_progressView.frame.origin.x+_progressView.frame.size.width+5, _videoImageView.frame.origin.y-20, 40, 20)];
    _progressLabel.textColor = COLOR_MAIN;
    _progressLabel.font = [UIFont systemFontOfSize:9];
    _progressLabel.text = @"-";
    [scrollView addSubview:_progressLabel];
    
    
    _ThumbButton = [[UIButton alloc]initWithFrame:CGRectMake(0, _videoImageView.frame.size.height-40, _videoImageView.frame.size.width/2-1, 40)];
    _ThumbButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_ThumbButton setTitle:@"设置封面" forState:UIControlStateNormal];
    _ThumbButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_ThumbButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_ThumbButton addTarget:self action:@selector(thumbButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_videoImageView addSubview:_ThumbButton];
    
    _saveButton = [[UIButton alloc]initWithFrame:CGRectMake(_videoImageView.frame.size.width/2+1, _videoImageView.frame.size.height-40, _videoImageView.frame.size.width/2-1, 40)];
    _saveButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_saveButton setTitle:@"保存到相册" forState:UIControlStateNormal];
    _saveButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_videoImageView addSubview:_saveButton];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, _videoImageView.frame.origin.y+_videoImageView.frame.size.height+30, SCREEN_WIDTH-20, 85)];
    _textView.font = [UIFont systemFontOfSize:14];
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 8,100, 20)];
    self.placeholderLabel.font = [UIFont systemFontOfSize:14];
    self.placeholderLabel.text = @"随便写点什么，描述下视频";
    self.placeholderLabel.textColor = COLOR(0x99, 0x99, 0x99, 1);
    [self.textView addSubview:self.placeholderLabel];
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.textView.frame.size.height+self.textView.frame.origin.y, self.textView.frame.size.width, 18)];
    self.countLabel.textColor = COLOR(0x99, 0x99, 0x99, 1);
    self.countLabel.backgroundColor = [UIColor whiteColor];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.text = @"100字内 ";
    self.countLabel.font = [UIFont systemFontOfSize:14];
    self.textView.delegate = self;
    
    
    _addLinkButton = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2, _textView.frame.origin.y+_textView.frame.size.height+30, 80, 80)];
    _addLinkButton.backgroundColor = [UIColor clearColor];
    [_addLinkButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    //[_addLinkButton setTitle:@"添加商品链接" forState:UIControlStateNormal];
    [_addLinkButton setImage:[UIImage imageNamed:@"videogoodadd"] forState:UIControlStateNormal];
    _addLinkButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_addLinkButton addTarget:self action:@selector(addLinkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(-20, 0, 120, 15)];
    addLabel.textColor = [UIColor lightGrayColor];
    addLabel.textAlignment = NSTextAlignmentCenter;
    addLabel.text = @"添加商品链接";
    addLabel.font = [UIFont systemFontOfSize:12];
    [_addLinkButton addSubview:addLabel];
    
    
    _uploadButton = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, _addLinkButton.frame.origin.y+_addLinkButton.frame.size.height+30, 200, 40)];
    _uploadButton.backgroundColor = [UIColor redColor];
    [_uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_uploadButton setTitle:@"上传" forState:UIControlStateNormal];
    _uploadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _uploadButton.layer.cornerRadius = 15;
    _uploadButton.layer.masksToBounds = YES;
    [_uploadButton addTarget:self action:@selector(uploadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT+200);
    
    [scrollView addSubview:_videoImageView];
    [scrollView addSubview:_textView];
    [scrollView addSubview:_countLabel];
    [scrollView addSubview:_addLinkButton];
    [scrollView addSubview:_uploadButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    tap.numberOfTapsRequired = 1;
    [scrollView addGestureRecognizer:tap];
}
- (void)thumbButtonClicked {
    ChangeThumbViewController *vc = [[ChangeThumbViewController alloc]init];
    vc.delegate = self;
    vc.haveCutVideoPath = self.videoPath;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)saveButtonClicked {
    [self.view makeToastActivity:CSToastPositionCenter];
    if ([[NSFileManager defaultManager]fileExistsAtPath:self.videoPath]) {
        UISaveVideoAtPathToSavedPhotosAlbum(self.videoPath, nil, nil, nil);
        [self.view hideToastActivity];
        [self.saveButton setTitle:@"已保存到相册" forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
        
        [self.view makeToast:@"保存到相册成功" duration:3.0 position:CSToastPositionCenter];
    } else {
        [self.view hideToastActivity];
        [self.view makeToast:@"保存到相册失败" duration:3.0 position:CSToastPositionCenter];
    }
}
- (void)addLinkButtonClicked {
    [self.view makeToast:@"商品描述暂不提供" duration:0.5 position:CSToastPositionCenter];
//    AddLinkTypeVC *vc = [[AddLinkTypeVC alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (void)uploadButtonClicked {
    
    [self.view makeToast:@"请根据自己需求上传视频" duration:0.8 position:CSToastPositionCenter];
    /*
     NSString *resolution;
     if (!self.videoPath || !self.thumbImagePath) {
     NSLog(@"上传视频，视频路径不存在 self.videoPath,self.thumbImagePath");
     [self.view makeToast:@"视频已损坏" duration:2.0 position:CSToastPositionCenter];
     return;
     } else {
     UIImage *videoImage = [UIImage imageWithContentsOfFile:self.thumbImagePath];
     NSLog(@"分辨率：%f,%f",videoImage.size.width,videoImage.size.height);
     if (videoImage.size.width/videoImage.size.height >= 1 ) {
     resolution = @"480*480";
     } else {
     resolution = @"480*640";
     }
     }
     
     NSString *videoText = self.textView.text;
     if(videoText.length == 0) {
     [self.view makeToast:@"请随便写点什么，描述下视频"duration:3.0 position:CSToastPositionCenter];
     return;
     } else {
     videoText = [videoText stringByReplacingOccurrencesOfString:@" " withString:@""];
     if(videoText.length == 0) {
     [self.view makeToast:@"请随便写点什么，描述下视频"duration:3.0 position:CSToastPositionCenter];
     return;
     }
     }
     
     [self.view makeToastActivity:CSToastPositionCenter];
     self.uploadButton.enabled = NO;
     
     UserInfo *userInfo = [UserInfo shareUserInfo];
     AFHTTPSessionManager *manager = [AFNRequestData sharedHTTPSession];
     NSString *token = [ToolCommon getToken];
     NSDictionary *parameters = nil;
     NSString *urlStr = [NSString stringWithFormat:@"%@upload/video10",HTTP_SERVER_V2_1];
     if ([self.goodsId isEqualToString:@""]) {//生活视频
     parameters = @{@"userid":userInfo.userId,@"uuid":userInfo.userUuid,@"token":token,@"goodsid":@"0",@"introduce":self.textView.text,@"resolution":resolution};
     } else if ([self.goodsId isEqualToString:@"taobao"]) {//淘宝商品视频
     parameters = @{@"userid":userInfo.userId,@"uuid":userInfo.userUuid,@"token":token,@"taobaourl":self.goodsUrl,@"sizeid":self.goodsSizeId,@"introduce":self.textView.text,@"resolution":resolution};
     } else if (self.isKucun) {//体验馆库存商品
     parameters = @{@"userid":userInfo.userId,@"uuid":userInfo.userUuid,@"token":token,@"goodsid":self.goodsId,@"extendid":self.goodsExtendId,@"type":self.goodsType,@"introduce":self.textView.text,@"resolution":resolution};
     } else {
     parameters = @{@"userid":userInfo.userId,@"uuid":userInfo.userUuid,@"token":token,@"goodsid":self.goodsId,@"extendid":self.goodsExtendId,@"sizeid":self.goodsSizeId,@"type":self.goodsType,@"introduce":self.textView.text,@"resolution":resolution};
     }
     NSLog(@"上传视频参数，%@",parameters);
     [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
     
     
     NSURL *videoFileUrl = [NSURL fileURLWithPath:self.videoPath];
     NSURL *imageFileUrl = [NSURL fileURLWithPath:self.thumbImagePath];
     
     NSError *error = nil;
     
     [formData appendPartWithFileURL:imageFileUrl name:@"image" fileName:@"iOS_upload_image" mimeType:@"image/png" error:&error];
     if (error) {
     NSLog(@"获取图片文件失败，%@",error.userInfo);
     [self.view makeToast:@"获取视频缩率图失败" duration:2.0f position:CSToastPositionCenter];
     }
     
     [formData appendPartWithFileURL:videoFileUrl name:@"video" fileName:@"iOS_upload_video" mimeType:@"video/mp4" error:&error];
     if (error) {
     NSLog(@"获取视频文件失败，%@",error.userInfo);
     [self.view makeToast:@"获取视频文件失败" duration:2.0f position:CSToastPositionCenter];
     }
     } progress:^(NSProgress * _Nonnull uploadProgress) {
     float complateRate = (float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount;
     NSLog(@"总共:%lld 完成:%lld, %f",uploadProgress.totalUnitCount,uploadProgress.completedUnitCount,complateRate);
     dispatch_async(dispatch_get_main_queue(), ^{
     //            self.progressView.progress = complateRate;
     //            self.nameLabel.text = [NSString stringWithFormat:@"完成%.2f%%",complateRate*100];
     
     _progressView.frame = CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y-10, _videoImageView.frame.size.width*complateRate, 5);
     
     _progressLabel.frame = CGRectMake(_progressView.frame.origin.x+_progressView.frame.size.width+5, _videoImageView.frame.origin.y-20, 40, 20);
     _progressLabel.text = [NSString stringWithFormat:@"%.2f%%",complateRate*100];
     
     if (complateRate == 1) {
     // [self.view hideToastActivity];
     }
     });
     
     
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     //        NSString *status = responseObject[@"status"];
     //        if([status isEqualToString:@"200"]) {
     //            [self.view makeToast:responseObject[@"reason"] duration:3.0f position:CSToastPositionCenter];
     //        } else {
     //            [self.view makeToast:@"上传视频成功" duration:2.0f position:CSToastPositionCenter];
     //        }
     
     [self.view hideToastActivity];
     [self.view makeToast:responseObject[@"reason"] duration:3.0f position:CSToastPositionCenter];
     [[NSNotificationCenter defaultCenter]postNotificationName:@"UploadVideoSuccess" object:nil];
     
     if ([[NSFileManager defaultManager]fileExistsAtPath:self.videoPath]) {
     [[NSFileManager defaultManager]removeItemAtPath:self.videoPath error:nil];
     }
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*3.0f), dispatch_get_main_queue(), ^{
     [self.navigationController dismissViewControllerAnimated:YES completion:nil];
     });
     
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     NSLog(@"%@",error.userInfo);
     [self.view makeToast:@"网络出错，上传失败" duration:3.0f position:CSToastPositionCenter];
     self.uploadButton.enabled = YES;
     }];
     */
    
}
//-----------------delegate
- (void)ChangeThumb:(NSString *)thumbnailPath ThumbImage:(UIImage *)thumbImage {
    self.thumbImagePath = thumbnailPath;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoImageView.image = thumbImage;
    });
}

//------------------处理消息
- (void) processGoodsLink: (NSNotification*) aNotification {
    NSDictionary *dict = aNotification.userInfo;
    
    NSLog(@"收到消息：%@",dict);
    
    self.isKucun = NO;
    
    
    
    self.goodsType = @"rexiao";
    self.goodsId = dict[@"goodsId"];
    if ([self.goodsId isEqualToString:@"taobao"]) {
        self.goodsUrl = dict[@"taobaoUrl"];
    }
    self.goodsExtendId = dict[@"extendId"];
    self.goodsImageStr = dict[@"goodsThumb"];
    self.goodsName = dict[@"goodsName"];
    self.goodsPrice = dict[@"goodsPrice"];
    self.goodsInfo1 = dict[@"goodsSize"];
    self.goodsSizeId = dict[@"goodsSizeId"];
    self.goodsInfo2 = dict[@"goodsWozhuan"];
    self.goodsInfo3 = dict[@"goodsFanxian"];
    
    
    self.isPushSizeVC = NO;
    [self setupGoodsView];
}

//库存商品的处理
- (void) processGoodsLink2: (NSNotification*) aNotification {
    NSDictionary *dict = aNotification.userInfo;
    
    NSLog(@"收到消息：%@",dict);
    
    self.isKucun = YES;
    //@{@"goodsId":self.goodsId,@"extendId":self.extendId,@"goodsThumb":self.goodsThumbStr,@"goodsName":self.goodsTitleStr,@"goodsPrice":self.goodsPriceStr,@"goodsKucunPrice":self.goodsFanliStr,@"goodsWozhuan":self.goodsWozhuanStr};
    
    self.goodsType = @"kucun";
    self.goodsId = dict[@"goodsId"];
    self.goodsExtendId = dict[@"extendId"];
    self.goodsImageStr = dict[@"goodsThumb"];
    self.goodsName = dict[@"goodsName"];
    self.goodsPrice = dict[@"goodsPrice"];
    self.goodsInfo1 = @"";
    self.goodsInfo2 = dict[@"goodsWozhuan"];
    self.goodsInfo3 = dict[@"goodsKucunPrice"];
    
    [self setupGoodsView];
    
}
- (void)setupGoodsView {
    if (!_goodsView) {
        _goodsView = [[UIView alloc]initWithFrame:CGRectMake(10, self.addLinkButton.frame.origin.y, SCREEN_WIDTH-20, 100)];
        _goodsView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:_goodsView];
        
        _goodsImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 75, 75)];
        _goodsImageView.backgroundColor = [UIColor lightGrayColor];
        [_goodsView addSubview:_goodsImageView];
        
        _goodsDeleteButton = [[UIButton alloc]initWithFrame:CGRectMake(_goodsView.frame.size.width-50, 0, 50, 30)];
        _goodsDeleteButton.backgroundColor = [UIColor whiteColor];
        [_goodsDeleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[_goodsDeleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_goodsDeleteButton setImage:[UIImage imageNamed:@"videogooddel"] forState:UIControlStateNormal];
        _goodsDeleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_goodsDeleteButton addTarget:self action:@selector(goodsDeleteClicked) forControlEvents:UIControlEventTouchUpInside];
        [_goodsView addSubview:_goodsDeleteButton];
        
        if (self.goodsDict) {
            _goodsDeleteButton.hidden = YES;
        }
        
        _goodsNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, _goodsView.frame.size.width-80-55, 60)];
        _goodsNameLabel.textColor = [UIColor grayColor];
        _goodsNameLabel.font = [UIFont systemFontOfSize:14];
        _goodsNameLabel.numberOfLines = 3;
        [_goodsView addSubview:_goodsNameLabel];
        
        _goodsInfoLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(80, 65, _goodsView.frame.size.width-85, 15)];
        _goodsInfoLabel1.textColor = [UIColor blackColor];
        _goodsInfoLabel1.font = [UIFont systemFontOfSize:14];
        _goodsInfoLabel1.textAlignment = NSTextAlignmentRight;
        [_goodsView addSubview:_goodsInfoLabel1];
        
        _goodsPriceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 80, 100, 20)];
        _goodsPriceLabel.textColor = [UIColor blackColor];
        _goodsPriceLabel.font = [UIFont systemFontOfSize:16];
        [_goodsView addSubview:_goodsPriceLabel];
        
        _goodsInfoLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(105, 80, _goodsView.frame.size.width-105-110, 20)];
        _goodsInfoLabel2.textColor = COLOR_MAIN;
        _goodsInfoLabel2.font = [UIFont systemFontOfSize:14];
        _goodsInfoLabel2.textAlignment = NSTextAlignmentCenter;
        [_goodsView addSubview:_goodsInfoLabel2];
        
        _goodsInfoLabel3 = [[UILabel alloc]initWithFrame:CGRectMake(_goodsView.frame.size.width-150, 80, 145, 20)];
        _goodsInfoLabel3.textColor = COLOR_MAIN;
        _goodsInfoLabel3.font = [UIFont systemFontOfSize:14];
        _goodsInfoLabel3.textAlignment = NSTextAlignmentRight;
        [_goodsView addSubview:_goodsInfoLabel3];
        
    }
    _goodsView.hidden = NO;
    _addLinkButton.hidden = YES;
    _uploadButton.center = CGPointMake(_uploadButton.center.x, _uploadButton.center.y+20);
    
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:self.goodsImageStr]];
    
    _goodsNameLabel.text = self.goodsName;
    _goodsPriceLabel.text = self.goodsPrice;
    _goodsInfoLabel1.text = self.goodsInfo1;
    _goodsInfoLabel2.text = self.goodsInfo2;
    _goodsInfoLabel3.text = self.goodsInfo3;
    
}
- (void)goodsDeleteClicked {
    _goodsView.hidden = YES;
    _addLinkButton.hidden = NO;
    _uploadButton.center = CGPointMake(_uploadButton.center.x, _uploadButton.center.y-20);
    
    self.goodsId = @"";
}

//------textView delegate
- (void)textViewDidChange:(UITextView *)textView{
    if ( [textView.text length] == 0) {
        self.placeholderLabel.hidden = NO;
    }
    else {
        self.placeholderLabel.hidden = YES;
        
    }
    self.countLabel.text = [NSString stringWithFormat:@"%ld/100 ",(unsigned long)[textView.text length]];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ((range.location+text.length) >= 100) {
        return NO;
    }
    else {
        return YES;
    }
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //[_textView endEditing:YES];
}
- (void)tap {
    [_textView endEditing:YES];
}
@end





