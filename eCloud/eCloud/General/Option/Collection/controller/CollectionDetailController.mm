//
//  CollectionDetailController.m
//  eCloud
//
//  Created by Alex L on 15/10/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "CollectionDetailController.h"
#import "UserDisplayUtil.h"
#import "UserInterfaceUtil.h"
#import "RobotDisplayUtil.h"
#import "CustomQLPreviewController.h"
#import "CollectionController.h"
#import "LogUtil.h"
#import "IOSSystemDefine.h"
#import "UIAdapterUtil.h"

#import "AudioPlayForIOS6.h"

#import "CL_VoiceEngine.h"
#import "amrToWavMothod.h"
#import "VoiceConverter.h"

#import "FileRecord.h"
#import <QuickLook/QLPreviewController.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "talkSessionViewController.h"
#import "ForwardingRecentViewController.h"
#import "openWebViewController.h"
#import "NewOrgViewController.h"
#import "LookFileViewController.h"
#import "DisplayVideoViewController.h"
//#import "LookOverPhotoViewController.h"
#import "UIImageOfCrop.h"
#import "ConvRecord.h"

#import "MLEmojiLabel.h"

#import "ConvRecord.h"
#import "Conversation.h"
#import "LGNewsMdelARC.h"
#import "CollectionUtil.h"
#import "StringUtil.h"
#import "UserTipsUtil.h"
#import "UserDefaults.h"
#import "eCloudDAO.h"
#import "eCloudConfig.h"
#import "ViewPicUtil.h"
#import "LocationModel.h"
#import "Emp.h"
#import "EncryptFileManege.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>  //引入地图功能所有的头文件
#import "receiveMapViewController.h"


#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define USER_IMG_X 20
#define USER_IMG_Y 9
#define USER_IMG_WIRTH 40
#define USER_IMG_HEIGHT 50

#define USER_NAME_X 70
#define USER_NAME_Y 6
#define USER_NAME_HEIGHT 30

#define MARK_IMG_X 20
#define MARK_IMG_Y 71
#define MARK_IMG_WIRTH 15
#define MARK_IMG_HEIGHT 15

#define MARK_BUTTON_X 50
#define MARK_BUTTON_Y 71
#define MARK_BUTTON_HEIGHT 20

#define TAG_LABEL_X 0
#define TAG_LABEL_Y 0
#define TAG_LABEL_WIRTH 70
#define TAG_LABEL_HEIGHT 20

#define SEPARATE_VIEW_1_X 20
#define SEPARATE_VIEW_1_Y 68
#define SEPARATE_VIEW_1_HEIGHT 1

#define SEPARATE_VIEW_2_X 20
#define SEPARATE_VIEW_2_Y 94
#define SEPARATE_VIEW_2_HEIGHT 1

#define MESSAGE_X 20
#define MESSAGE_Y 84

#define TEXT_TIME_LABEL_X 20
#define TEXT_TIME_LABEL_WIRTH 180
#define TEXT_TIME_LABEL_HEIGHT 20

//#define QLPREVIEW_X 20
//#define QLPREVIEW_Y 111

//#define TIME_LABEL_X 20
//#define TIME_LABEL_WIRTH 150
//#define TIME_LABEL_HEIGHT 20

#define IMAGEVIEW_X 20
#define IMAGEVIEW_Y 91

#define PIC_TIME_LABEL_X 20
#define PIC_TIME_LABEL_WIRTH 150
#define PIC_TIME_LABEL_HEIGHT 20

#define TEXT_MESSAGE_FONT 15
#define USERNAME_FONT 15
#define TAG_LABEL_FONT 15
#define TIME_LABEL_FONT 12
#define ADDRESSFONT 15

#define ADDRESSFONT 15
#define VOICE_ORG_X 12
#define VOICE_WIDTH 63
#define VOICE_ORG_Y 93
#define VOICE_HEIGHT 37

#define AUDIO_PLAY_X 12.5
#define AUDIO_PLAY_Y 9.5
#define AUDIO_PLAY_WIRTH 15
#define AUDIO_PLAY_HEIGHT 18


#define AUDIO_TIME_X 42
#define AUDIO_TIME_Y 11.5
#define AUDIO_TIME_WIRTH 20
#define AUDIO_TIME_HEIGHT 14


@interface CollectionDetailController ()<QLPreviewControllerDataSource, MLEmojiLabelDelegate, UIActionSheetDelegate, FGalleryViewControllerDelegate,BMKMapViewDelegate>
{
    CGFloat _record_fileSize;
    CGFloat _currentTime;
    NSTimer *_timer;
    NSTimer *_progressTimer;
    amrToWavMothod *amrtowav;
    
    BOOL decryptFlag;
    
    // 是否是点击超链接
    BOOL flag2;
    
    // 录音是否正在播放
    BOOL isPlaying;
    
    //    播放语音
    AudioPlayForIOS6 *audioplayios6;
}
@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *voicePlayImg;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) MLEmojiLabel *messageLabel;
@property (nonatomic, strong) ConvRecord *forwardRecord;
@property (nonatomic, strong) talkSessionViewController *talkSessionCtl;

@property (nonatomic, strong) AVPlayerViewController *ios9PlayerViewController;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@end

@implementation CollectionDetailController
{
    NewLocationModel *_model;
}
- (void)dealloc
{
    // 视频
    if (self.ios9PlayerViewController)
    {
        [self.ios9PlayerViewController.player pause];
        self.ios9PlayerViewController = nil;
    }
    
    if (self.moviePlayerController) {
        [self.moviePlayerController stop];
        self.moviePlayerController = nil;
        //移除通知(用第二种播放器的时候开启)
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
    
    // 音频
    if (isPlaying)
    {
        [self.talkSessionCtl stopPlayAudio];
    }
    
    if (self.collectionModel.type == type_file && self.collectionModel.type == type_record)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.collectionModel.body error:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueStopped" object:nil];
}

#pragma mark - 懒加载
- (talkSessionViewController *)talkSessionCtl
{
    if (_talkSessionCtl == nil)
    {
        _talkSessionCtl = [talkSessionViewController getTalkSession];
    }
    return _talkSessionCtl;
}

- (UILabel *)messageLabel
{
    if (_messageLabel == nil)
    {
        // 根据文字多少计算Label的高度
        CGRect rect = [self.collectionModel.body boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]} context:nil];
        
        _messageLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(MESSAGE_X, MESSAGE_Y, KSCREEN_SIZE.width - 40, rect.size.height + 10)];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [_messageLabel setEmojiText:self.collectionModel.body];
        [_messageLabel setFont:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]];
        
        // 添加想要复制时的长按手势
        _messageLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *copyLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyLongPress:)];
        [_messageLabel addGestureRecognizer:copyLongPress];
        
        _messageLabel.emojiDelegate = self;
        
        // 不支持话题和@用户
        _messageLabel.isNeedAtAndPoundSign = NO;
        _messageLabel.customEmojiRegex = @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _messageLabel.customEmojiPlistName = @"expressionImage_custom.plist";
        
        [_messageLabel sizeToFit];
    }
    return _messageLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    audioplayios6 = [[AudioPlayForIOS6 alloc]init];
    
    
    // 设置标题
//    UILabel *titltLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
//    [titltLabel setFont:[UIFont systemFontOfSize:17]];
//    titltLabel.text = [StringUtil getLocalizableString:@"detail"];
//    [titltLabel setTextColor:[UIColor whiteColor]];
//    self.navigationItem.titleView = titltLabel;
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    UIButton *button =  [UIAdapterUtil setRightButtonItemWithImageName:@"ic_actbar_more" andTarget:self andSelector:@selector(editTheCollection)];
    [button setImage:[StringUtil getImageByResName:@"ic_actbar_more_pressed@"] forState:UIControlStateHighlighted];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_SIZE.width, KSCREEN_SIZE.height - 64)];
    self.scrollView.alwaysBounceVertical = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    [self addSubView];
}

- (void)backButtonPressed:(id)sender
{
    [audioplayios6 stopPlayAudio];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)editTheCollection
{
    if (IOS8_OR_LATER)
    {
        UIAlertController *alertCtl = [[UIAlertController alloc] init];
        
        UIAlertAction *sendToAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"send_to_someone"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [self sendThisCollect];
        }];
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"delete"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            
            [self deleteThisCollect];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [self popoverPresentationController];
        }];
        
        
#ifdef _XIANGYUAN_FLAG_
        if (self.collectionModel.type != type_record)
        {
            [alertCtl addAction:sendToAction];
        }
#else
        [alertCtl addAction:sendToAction];
#endif
        
        [alertCtl addAction:deleteAction];
        [alertCtl addAction:cancelAction];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
    }
    else
    {
#ifdef _XIANGYUAN_FLAG_
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"delete"], nil];
        [menu showInView:self.view];
#else
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"send_to_someone"],[StringUtil getLocalizableString:@"delete"], nil];
        [menu showInView:self.view];
#endif
    }
}

// navigationBar是否上移
static BOOL flag1 = NO;
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [StringUtil getLocalizableString:@"detail"];

    CGFloat origanY =  CGRectGetMaxY(self.navigationController.navigationBar.frame);
    if (origanY == 0)
    {
        CGRect rect1 = self.navigationController.navigationBar.frame;
        rect1.origin.y += 64;
        self.navigationController.navigationBar.frame = rect1;
        
        flag1 = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_timer.isValid)
    {
        [_timer invalidate];
        _timer = nil ;
    }
    if ([_progressTimer isValid])
    {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
    
    if (flag1)
    {
        CGRect rect1 = self.navigationController.navigationBar.frame;
        rect1.origin.y -= 64;
        self.navigationController.navigationBar.frame = rect1;
    }
    
    flag1 = NO;
}

- (void)addTag
{
    
}

- (void)empDetails
{
    Emp *emp = self.collectionModel.emp;
    [NewOrgViewController openUserInfoById:[NSString stringWithFormat:@"%d",emp.emp_id] andCurController:self];
}

- (void)addSubView
{
    UIImageView *userImg = [UserDisplayUtil getUserLogoViewWithLogoHeight:USER_IMG_HEIGHT];// [[UIImageView alloc] initWithFrame:CGRectMake(USER_IMG_X, USER_IMG_Y, USER_IMG_WIRTH, USER_IMG_HEIGHT)];
    
#ifdef _LANGUANG_FLAG_
    
//    [userImg.layer setMasksToBounds:YES];
//    [userImg.layer setCornerRadius:5];
    userImg = [UserDisplayUtil getUserLogoViewWithLogoHeight:USER_IMG_WIRTH];
    userImg.frame = CGRectMake(USER_IMG_X , USER_IMG_Y + 5, USER_IMG_WIRTH, USER_IMG_WIRTH);
#endif
    
#ifdef _XIANGYUAN_FLAG_
    
//    [userImg.layer setMasksToBounds:YES];
//    [userImg.layer setCornerRadius:5];
    userImg = [UserDisplayUtil getUserLogoViewWithLogoHeight:USER_IMG_WIRTH];
    userImg.frame = CGRectMake(USER_IMG_X, USER_IMG_Y + 5, USER_IMG_WIRTH, USER_IMG_WIRTH);
    
#endif
    
    userImg.image = nil;
    
    UIImageView *realLogoView = [UserDisplayUtil getSubLogoFromLogoView:userImg];
    realLogoView.image = self.collectionModel.icon;
    if ([self.collectionModel.icon isEqual:default_logo_image] ) {
        Emp *_emp = [[Emp alloc]init];
        _emp.emp_name = self.collectionModel.userName;
        NSDictionary *mDic = [UserDisplayUtil getUserDefinedLogoDicOfEmp:_emp];
        [UserDisplayUtil setUserDefinedLogo:userImg andLogoDic:mDic];
        
    }else{
        [UserDisplayUtil hideLogoText:userImg];
    }
    [UserDisplayUtil hideStatusView:userImg];
    
    userImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(empDetails)];
    [userImg addGestureRecognizer:tap];
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_X, USER_NAME_Y, 140, USER_NAME_HEIGHT)];
    userName.numberOfLines = 0;
    userName.text = self.collectionModel.userName;
    [userName setFont:[UIFont systemFontOfSize:USERNAME_FONT]];
    //    UIImageView *markImg = [[UIImageView alloc] initWithFrame:CGRectMake(MARK_IMG_X, MARK_IMG_Y, MARK_IMG_WIRTH, MARK_IMG_HEIGHT)];
    //    UIButton *markButton = [[UIButton alloc] initWithFrame:CGRectMake(MARK_BUTTON_X, MARK_BUTTON_Y, KSCREEN_SIZE.width - 70, MARK_BUTTON_HEIGHT)];
    //    [markButton addTarget:self action:@selector(addTag) forControlEvents:UIControlEventTouchUpInside];
    //    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(TAG_LABEL_X, TAG_LABEL_Y, TAG_LABEL_WIRTH, TAG_LABEL_HEIGHT)];
    //    [tagLabel setFont:[UIFont systemFontOfSize:TAG_LABEL_FONT]];
    //    tagLabel.text = @"";
    //    [tagLabel setTextColor:[UIColor lightGrayColor]];
    //    [markButton addSubview:tagLabel];
    
    //    UILabel *sendTime = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_X, 15, 100, 25)];
    //    sendTime.text = [StringUtil getLocalizableString:@"send_in"];
    //    [sendTime setTextColor:[UIColor lightGrayColor]];
    //    [sendTime setFont:[UIFont systemFontOfSize:12]];
    //    [self.scrollView addSubview:sendTime];
    UILabel *msgTime = [[UILabel alloc] initWithFrame:CGRectMake(USER_NAME_X, 35, 150, 25)];
    NSString *time = [self.collectionModel.msgTime stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    msgTime.text = time;
    [msgTime setTextColor:[UIColor lightGrayColor]];
    [msgTime setFont:[UIFont systemFontOfSize:12]];
    [self.scrollView addSubview:msgTime];
    
    UIButton *talksessionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    talksessionBtn.frame = CGRectMake(KSCREEN_SIZE.width - 50 - 20, 10, 50, 50);
    [talksessionBtn addTarget:self action:@selector(comeToTalkSession) forControlEvents:UIControlEventTouchUpInside];
    talksessionBtn.backgroundColor = [UIColor lightGrayColor];
    talksessionBtn.alpha = 0.2;
    
    UIView *separateView1 = [[UIView alloc] initWithFrame:CGRectMake(SEPARATE_VIEW_1_X, SEPARATE_VIEW_1_Y, KSCREEN_SIZE.width - 40, SEPARATE_VIEW_1_HEIGHT)];
    separateView1.backgroundColor = [StringUtil colorWithHexString:@"#A9A9A9"];
    //    UIView *separateView2 = [[UIView alloc] initWithFrame:CGRectMake(SEPARATE_VIEW_2_X, SEPARATE_VIEW_2_Y, KSCREEN_SIZE.width - 40, SEPARATE_VIEW_2_HEIGHT)];
    //    separateView2.backgroundColor = [UIColor lightGrayColor];
    
    [self.scrollView addSubview:userImg];
    [self.scrollView addSubview:userName];
    //    [self.scrollView addSubview:markImg];
    //    [self.scrollView addSubview:talksessionBtn];
    //    [self.scrollView addSubview:markButton];
    [self.scrollView addSubview:separateView1];
    //    [self.scrollView addSubview:separateView2];
    
    
    switch (self.collectionModel.realType) {
        case type_text:
        {
            NSMutableArray *array = [NSMutableArray array];
            if (self.collectionModel.type == type_text) {
                //                普通文本或者图文
                [StringUtil seperateMsg:self.collectionModel.body andImageArray:array];
            }else{
                //                长消息
                [array addObject:self.collectionModel.body];
            }
            BOOL firstFlag = YES;
            CGFloat originY = 0;
            for(NSString *str in array)
            {
                NSLog(@"%s str is %@",__FUNCTION__,str);
                //                NSString *imageUrl = []
                if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
                {
                    NSString *imageUrl = [StringUtil getPicMsgUrlByMsgBody:str];
                    if(imageUrl.length > 0)
                    {
                        //图片
                        NSString *messageStr = imageUrl;
                        NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
                        NSString *picpath = [[CollectionUtil newCollectFilePath] stringByAppendingPathComponent:picname];
                        UIImage *image = [UIImage imageWithContentsOfFile:picpath];
                        
                        // 根据图片大小改变imageView的大小
                        CGFloat pictureWidth = image.size.width;
                        CGFloat pictureHeight = image.size.height;
                        CGFloat imgWidth1 = pictureWidth > pictureHeight ? (KSCREEN_SIZE.width - 40) : (KSCREEN_SIZE.width - 40);
                        
                        CGFloat imgWidth = pictureWidth > (KSCREEN_SIZE.width/2) ? imgWidth1 : pictureWidth;
                        
                        CGFloat ratio = image.size.width / image.size.height;
                        NSInteger height = imgWidth / ratio;
                        CGFloat imageviewY = firstFlag ? IMAGEVIEW_Y + originY : originY;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGEVIEW_X, imageviewY, imgWidth, height)];
                        imageView.image = image;
                        [self.scrollView addSubview:imageView];
                        
                        originY += height + 10;
                        if (firstFlag)
                        {
                            originY += imageviewY;
                            firstFlag = NO;
                        }
                    }
                }
                else
                {
                    // 根据文字多少计算Label的高度
                    CGRect rect = [str boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]} context:nil];
                    CGFloat labelY = firstFlag ? MESSAGE_Y + originY : originY;
                    MLEmojiLabel *label = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(MESSAGE_X, labelY, KSCREEN_SIZE.width - 40, rect.size.height + 10)];
                    label.bundle = [StringUtil getBundle];
                    label.numberOfLines = 0;
                    label.lineBreakMode = NSLineBreakByCharWrapping;
                    [label setEmojiText:str];
                    [label setFont:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]];
                    
                    label.userInteractionEnabled = YES;
                    
                    label.emojiDelegate = self;
                    
                    // 不支持话题和@用户
                    label.isNeedAtAndPoundSign = NO;
                    label.customEmojiRegex = @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
                    label.customEmojiPlistName = @"expressionImage_custom.plist";
                    
                    [label sizeToFit];
                    [self.scrollView addSubview:label];
                    
                    originY += label.frame.size.height + 20;
                    if (firstFlag)
                    {
                        originY += labelY;
                        firstFlag = NO;
                    }
                }
            }
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_TIME_LABEL_X, originY, TEXT_TIME_LABEL_WIRTH, TEXT_TIME_LABEL_HEIGHT)];
            [timeLabel setTextColor:[UIColor lightGrayColor]];
            NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
            
            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
            [self.scrollView addSubview:timeLabel];
            
            if (self.collectionModel.groupName.length)
            {
                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, originY-15, KSCREEN_SIZE.width - 120, 50)];
                groupName.numberOfLines = 0;
                [groupName setTextColor:[UIColor lightGrayColor]];
                groupName.textAlignment = NSTextAlignmentLeft;
                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:groupName];
            }
            
            self.scrollView.contentSize = CGSizeMake(0, originY + 15 + TEXT_TIME_LABEL_HEIGHT);
            
        }
            break;
            
        case type_long_msg:
        {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, KSCREEN_SIZE.width-40, 50)];
            messageLabel.text = self.collectionModel.body;
            messageLabel.numberOfLines = 0;
            messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [messageLabel setFont:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]];
            [messageLabel sizeToFit];
            
            [self.scrollView addSubview:messageLabel];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_TIME_LABEL_X, 10+80+messageLabel.frame.size.height, TEXT_TIME_LABEL_WIRTH, TEXT_TIME_LABEL_HEIGHT)];
            [timeLabel setTextColor:[UIColor lightGrayColor]];
            NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
            
            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
            [self.scrollView addSubview:timeLabel];
            
            if (self.collectionModel.groupName.length)
            {
                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 10+80+messageLabel.frame.size.height-15, KSCREEN_SIZE.width - 120, 50)];
                groupName.numberOfLines = 0;
                [groupName setTextColor:[UIColor lightGrayColor]];
                groupName.textAlignment = NSTextAlignmentLeft;
                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:groupName];
            }
            
            self.scrollView.contentSize = CGSizeMake(0, 10+80+messageLabel.frame.size.height + 15 + TEXT_TIME_LABEL_HEIGHT);
        }
            break;
            
        case type_file:
        {
            //            QLPreviewController* previewController=[[QLPreviewController alloc] init];
            //            previewController.dataSource = self;
            //            CGFloat previewHeight = (KSCREEN_SIZE.width - 40)*(5/4.0);
            //            previewController.view.frame = CGRectMake(IMAGEVIEW_X, IMAGEVIEW_Y, KSCREEN_SIZE.width - 40, previewHeight);
            [self initFileMsgView];
//            
//            UIImageView *backgroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80,  KSCREEN_SIZE.width-40, 60)];
//            backgroupImg.image = [StringUtil getImageByResName:@"frameCircle.png"];
//            
//            UIImageView *fileType = [[UIImageView alloc] initWithFrame:CGRectMake(28, 87, 45, 45)];
//            fileType.image = [StringUtil getFileDefaultImage:self.collectionModel.fileName];
//            UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(78, 87, KSCREEN_SIZE.width-102, 30)];
//            [fileName setFont:[UIFont systemFontOfSize:13]];
//            fileName.text = self.collectionModel.fileName;
//            UILabel *fileSize = [[UILabel alloc] initWithFrame:CGRectMake(78, 107, 100, 30)];
//            [fileSize setFont:[UIFont systemFontOfSize:12]];
//            [fileSize setTextColor:[UIColor grayColor]];
//            fileSize.text = [StringUtil getDisplayFileSize:self.collectionModel.fileSize.intValue];
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//            button.frame = CGRectMake(20, 80, KSCREEN_SIZE.width-40, 50);
//            [button addTarget:self action:@selector(pushQLPreviewCtl) forControlEvents:UIControlEventTouchUpInside ];
//            [self.scrollView addSubview:backgroupImg];
//            [self.scrollView addSubview:button];
//            [self.scrollView addSubview:fileType];
//            [self.scrollView addSubview:fileName];
//            [self.scrollView addSubview:fileSize];
//            
//            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, 150, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
//            [timeLabel setTextColor:[UIColor lightGrayColor]];
//            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], self.collectionModel.timeText];
//            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
//            
//            if (self.collectionModel.groupName.length)
//            {
//                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 150-15, KSCREEN_SIZE.width - 120, 50)];
//                groupName.numberOfLines = 0;
//                [groupName setTextColor:[UIColor lightGrayColor]];
//                groupName.textAlignment = NSTextAlignmentLeft;
//                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
//                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
//                [self.scrollView addSubview:groupName];
//            }
//            
//            self.scrollView.contentSize = CGSizeMake(0, IMAGEVIEW_Y + 15 + PIC_TIME_LABEL_HEIGHT);
//            //            [self.scrollView addSubview:previewController.view];
//            [self.scrollView addSubview:timeLabel];
        }
            break;
            
        case type_pic:
        {
            // 根据图片大小改变imageView的大小
            CGFloat pictureWidth = self.collectionModel.picture.size.width;
            CGFloat pictureHeight = self.collectionModel.picture.size.height;
            CGFloat imgWidth1 = pictureWidth > pictureHeight ? (KSCREEN_SIZE.width - 40) : (KSCREEN_SIZE.width - 40);
            
            CGFloat imgWidth = pictureWidth > (KSCREEN_SIZE.width/2) ? imgWidth1 : pictureWidth;
            
            CGFloat ratio = self.collectionModel.picture.size.width / self.collectionModel.picture.size.height;
            NSInteger height = imgWidth / ratio;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGEVIEW_X, IMAGEVIEW_Y, imgWidth, height)];
            imageView.image = self.collectionModel.picture;
            
            // 添加点击手势
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookOverThePic)];
            
            [imageView addGestureRecognizer:tap];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, IMAGEVIEW_Y + height + 15, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
            [timeLabel setTextColor:[UIColor lightGrayColor]];
            NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
            
            if (self.collectionModel.groupName.length)
            {
                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, IMAGEVIEW_Y + height + 15-15, KSCREEN_SIZE.width - 120, 50)];
                groupName.numberOfLines = 0;
                [groupName setTextColor:[UIColor lightGrayColor]];
                groupName.textAlignment = NSTextAlignmentLeft;
                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:groupName];
            }
            
            self.scrollView.contentSize = CGSizeMake(0, IMAGEVIEW_Y + height + 15 + PIC_TIME_LABEL_HEIGHT);
            [self.scrollView addSubview:imageView];
            [self.scrollView addSubview:timeLabel];
        }
            break;
            
        case type_record:
        {
            if (self.collectionModel.title) {
//                小万的语音也要显示为文件格式
                [self initFileMsgView];
                
            }else{
                UIView *greenBackground = [[UIView alloc] init];
                greenBackground.layer.cornerRadius = 4;
                greenBackground.layer.masksToBounds = YES;
                greenBackground.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
                greenBackground.backgroundColor =  [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
                greenBackground.layer.borderWidth = 0.5;
                [self.scrollView addSubview:greenBackground];
                
                UIButton *playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [playOrPauseBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
                // 添加播放时的动画
                self.voicePlayImg = [[UIImageView alloc] initWithFrame:CGRectMake(AUDIO_PLAY_X, AUDIO_PLAY_Y, AUDIO_PLAY_WIRTH, AUDIO_PLAY_HEIGHT)];
                self.voicePlayImg.image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
                
                NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
                for (int i = 1; i < 4; i++)
                {
                    UIImage *voice_rcv_play = [StringUtil getImageByResName:[NSString stringWithFormat:@"voice_rcv_play_%d.png",i]];
                    [images addObject:voice_rcv_play];
                }
                self.voicePlayImg.animationImages = images;
                self.voicePlayImg.animationRepeatCount = 0;
                self.voicePlayImg.animationDuration = 1.1;
                
                
                
                self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(AUDIO_TIME_X, AUDIO_TIME_Y, AUDIO_TIME_WIRTH, AUDIO_TIME_HEIGHT)];
                self.durationLabel.text = [NSString stringWithFormat:@"%@''",self.collectionModel.fileSize];
                self.durationLabel.font = [UIFont systemFontOfSize:10];
                if (self.collectionModel.fileSize == nil) {
                    self.durationLabel.hidden = YES;
                }
                
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(VOICE_ORG_X, 95 + 40 + 15, TEXT_TIME_LABEL_WIRTH, PIC_TIME_LABEL_X)];
                [timeLabel setTextColor:[UIColor lightGrayColor]];
                NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
                timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];                [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                
                CGFloat voicLength = [self.durationLabel.text floatValue];
                greenBackground.frame = CGRectMake(VOICE_ORG_X, VOICE_ORG_Y, VOICE_WIDTH + VOICE_WIDTH/20*(voicLength-1), VOICE_HEIGHT);
                playOrPauseBtn.frame = CGRectMake(0, 0, greenBackground.frame.size.width, greenBackground.frame.size.height);


                if (self.collectionModel.groupName.length)
                {
                    UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 95 + 40 + 15-15, KSCREEN_SIZE.width - 120, 50)];
                    groupName.numberOfLines = 0;
                    [groupName setTextColor:[UIColor lightGrayColor]];
                    groupName.textAlignment = NSTextAlignmentLeft;
                    groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                    [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                    [self.scrollView addSubview:groupName];
                }
                
                [playOrPauseBtn addSubview:self.voicePlayImg];
                [greenBackground addSubview:playOrPauseBtn];
                [greenBackground addSubview:self.durationLabel];
                [self.scrollView addSubview:timeLabel];
                
                // 让自己成为录音播放结束时发出的通知的观察者
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
            }
        }
            break;
            
        case type_normal_imgtxt:
        {
            NSMutableArray *array = [NSMutableArray array];
            [StringUtil seperateMsg:self.collectionModel.body andImageArray:array];
            
            BOOL firstFlag = YES;
            CGFloat originY = 0;
            for(NSString *str in array)
            {
                NSLog(@"%s str is %@",__FUNCTION__,str);
                if([str hasPrefix:PC_CROP_PIC_START] && [str hasSuffix:PC_CROP_PIC_END])
                {
                    NSString *imageUrl = [StringUtil getPicMsgUrlByMsgBody:str];
                    if(imageUrl.length > 0)
                    {
                        //图片
                        NSString *messageStr = imageUrl;
                        NSString *picname=[NSString stringWithFormat:@"%@.png",messageStr];
                        NSString *picpath = [[CollectionUtil newCollectFilePath] stringByAppendingPathComponent:picname];
                        UIImage *image = [UIImage imageWithContentsOfFile:picpath];
                        
                        // 根据图片大小改变imageView的大小
                        CGFloat pictureWidth = image.size.width;
                        CGFloat pictureHeight = image.size.height;
                        CGFloat imgWidth1 = pictureWidth > pictureHeight ? (KSCREEN_SIZE.width - 40) : (KSCREEN_SIZE.width - 40);
                        
                        CGFloat imgWidth = pictureWidth > (KSCREEN_SIZE.width/2) ? imgWidth1 : pictureWidth;
                        
                        CGFloat ratio = image.size.width / image.size.height;
                        NSInteger height = imgWidth / ratio;
                        CGFloat imageviewY = firstFlag ? IMAGEVIEW_Y + originY : originY;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGEVIEW_X, imageviewY, imgWidth, height)];
                        imageView.image = image;
                        [self.scrollView addSubview:imageView];
                        
                        originY += height + 10;
                        if (firstFlag)
                        {
                            originY += imageviewY;
                            firstFlag = NO;
                        }
                    }
                }
                else
                {
                    // 根据文字多少计算Label的高度
                    CGRect rect = [str boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT+1]} context:nil];
                    CGFloat labelY = firstFlag ? MESSAGE_Y + originY : originY;
                    MLEmojiLabel *label = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(MESSAGE_X, labelY, KSCREEN_SIZE.width - 40, rect.size.height + 10)];
                    label.bundle = [StringUtil getBundle];
                    label.numberOfLines = 0;
                    label.lineBreakMode = NSLineBreakByCharWrapping;
                    [label setEmojiText:str];
                    [label setFont:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]];
                    
                    label.userInteractionEnabled = YES;
                    
                    label.emojiDelegate = self;
                    
                    // 不支持话题和@用户
                    label.isNeedAtAndPoundSign = NO;
                    label.customEmojiRegex = @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
                    label.customEmojiPlistName = @"expressionImage_custom.plist";
                    
                    [label sizeToFit];
                    [self.scrollView addSubview:label];
                    
                    originY += label.frame.size.height + 20;
                    if (firstFlag)
                    {
                        originY += labelY;
                        firstFlag = NO;
                    }
                }
            }
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_TIME_LABEL_X, originY, TEXT_TIME_LABEL_WIRTH, TEXT_TIME_LABEL_HEIGHT)];
            [timeLabel setTextColor:[UIColor lightGrayColor]];
            NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
            [self.scrollView addSubview:timeLabel];
            
            if (self.collectionModel.groupName.length)
            {
                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, originY-15, KSCREEN_SIZE.width - 120, 50)];
                groupName.numberOfLines = 0;
                [groupName setTextColor:[UIColor lightGrayColor]];
                groupName.textAlignment = NSTextAlignmentLeft;
                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:groupName];
            }
            
            self.scrollView.contentSize = CGSizeMake(0, originY + 15 + TEXT_TIME_LABEL_HEIGHT);
            
        }
            break;
            
        case type_imgtxt:
        {
            UIImageView *backgroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80,  KSCREEN_SIZE.width-40, 82)];
            backgroupImg.image = [StringUtil getImageByResName:@"frameCircle.png"];
            [self.scrollView addSubview:backgroupImg];
            
            UIButton *contentView = [[UIButton alloc] initWithFrame:CGRectMake(28, 82, [UIScreen mainScreen].bounds.size.width - 40, 70)];
            [contentView addTarget:self action:@selector(openDetailWeb) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:contentView];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 25, 45, 45)];
            imgView.image = self.collectionModel.picture;
            [contentView addSubview:imgView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, -5, [UIScreen mainScreen].bounds.size.width - 50, 35)];
            titleLabel.text = self.collectionModel.title;
            [titleLabel setFont:[UIFont systemFontOfSize:15]];
            [contentView addSubview:titleLabel];
            
            UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 23, [UIScreen mainScreen].bounds.size.width - 102, 50)];
            desLabel.text = self.collectionModel.fileName;
            desLabel.numberOfLines = 0;
            [desLabel setTextColor:[UIColor grayColor]];
            [desLabel setFont:[UIFont systemFontOfSize:13]];
            [contentView addSubview:desLabel];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(TEXT_TIME_LABEL_X, 175, TEXT_TIME_LABEL_WIRTH, TEXT_TIME_LABEL_HEIGHT)];
            [timeLabel setTextColor:[UIColor lightGrayColor]];
            NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];            [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
            [self.scrollView addSubview:timeLabel];
            
            if (self.collectionModel.groupName.length)
            {
                UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 175-15, KSCREEN_SIZE.width - 120, 50)];
                groupName.numberOfLines = 0;
                [groupName setTextColor:[UIColor lightGrayColor]];
                groupName.textAlignment = NSTextAlignmentLeft;
                groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:groupName];
            }
            
        }
            break;
            
        case type_video:
        {
            if (self.collectionModel.title)
            {
                UIImageView *fileType = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 45, 45)];
                fileType.image = [StringUtil getFileDefaultImage:self.collectionModel.title];
                UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(70, 80, KSCREEN_SIZE.width-40, 30)];
                [fileName setFont:[UIFont systemFontOfSize:13]];
                fileName.text = self.collectionModel.title;
                UILabel *fileSize = [[UILabel alloc] initWithFrame:CGRectMake(70, 100, 100, 30)];
                [fileSize setFont:[UIFont systemFontOfSize:12]];
                [fileSize setTextColor:[UIColor grayColor]];
                fileSize.text = self.collectionModel.fileSize;//[StringUtil getDisplayFileSize:.intValue];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(20, 80, KSCREEN_SIZE.width-40, 50);
                [button addTarget:self action:@selector(pushQLPreviewCtl) forControlEvents:UIControlEventTouchUpInside ];
                [self.scrollView addSubview:button];
                [self.scrollView addSubview:fileType];
                [self.scrollView addSubview:fileName];
                [self.scrollView addSubview:fileSize];
                
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, 135, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
                [timeLabel setTextColor:[UIColor lightGrayColor]];
                NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
                timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
                [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                [self.scrollView addSubview:timeLabel];
                
                if (self.collectionModel.groupName.length)
                {
                    UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 135-15, KSCREEN_SIZE.width - 120, 50)];
                    groupName.numberOfLines = 0;
                    [groupName setTextColor:[UIColor lightGrayColor]];
                    groupName.textAlignment = NSTextAlignmentLeft;
                    groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                    [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                    [self.scrollView addSubview:groupName];
                }
            }
            else
            {
                CGFloat _moviePlayerViewHeight = (KSCREEN_SIZE.width-40)*(self.collectionModel.picture.size.height/self.collectionModel.picture.size.width);
                
                NSString *filePath = self.collectionModel.title ? self.collectionModel.fileName : self.collectionModel.body;
                
                if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
                    if (IOS9_OR_LATER)
                    {
                        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
                        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                        _ios9PlayerViewController = [AVPlayerViewController new];
                        _ios9PlayerViewController.player = player;
                        _ios9PlayerViewController.view.frame = CGRectMake(20, 80, KSCREEN_SIZE.width - 40, _moviePlayerViewHeight);
                        
                        [self.scrollView addSubview:_ios9PlayerViewController.view];
                    }
                    else
                    {
                        _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
                        // 重复播放属性 MPMovieRepeatModeNone播放一次后停止
                        _moviePlayerController.repeatMode = MPMovieRepeatModeNone;
                        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
                        _moviePlayerController.view.frame = CGRectMake(20, 80, KSCREEN_SIZE.width - 40, _moviePlayerViewHeight);
                        
                        //        [_moviePlayerController setScalingMode:MPMovieScalingModeFill];
                        _moviePlayerController.controlStyle=MPMovieControlStyleEmbedded;
                        _moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
                        
                        [_moviePlayerController prepareToPlay];
                        [self.scrollView addSubview:_moviePlayerController.view];
                    }
                    
                    
                    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _moviePlayerViewHeight + 100, 150, 20)];
                    [timeLabel setTextColor:[UIColor lightGrayColor]];
                    NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
                    timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
                    [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                    
                    [self.scrollView addSubview:timeLabel];
                    self.scrollView.contentSize = CGSizeMake(0, _moviePlayerViewHeight+150);
                }
                
                if (self.collectionModel.groupName.length)
                {
                    UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, _moviePlayerViewHeight + 100-15, KSCREEN_SIZE.width - 120, 50)];
                    groupName.numberOfLines = 0;
                    [groupName setTextColor:[UIColor lightGrayColor]];
                    groupName.textAlignment = NSTextAlignmentLeft;
                    groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
                    [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
                    [self.scrollView addSubview:groupName];
                }
            }
        }
            break;
            case type_location:
        {
            
            [self addLocatinView];
        }
            break;
        case type_news:
        {
            [self addNewsView];
        }
            break;
            
        default:
            break;
    }
}

-(void)addNewsView
{
    LGNewsMdelARC *model = [self getNewsModleFrom:self.collectionModel.body];
    
    CGRect rect1 = [model.title boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40 - MARK_IMG_HEIGHT*2, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ADDRESSFONT]} context:nil];
    CGRect rect2 = [model.url boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40 - MARK_IMG_HEIGHT *2, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ADDRESSFONT]} context:nil];
    
    UIView *view = [[UIView alloc]init];
    view.tag = 703;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
    view.backgroundColor =   [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
    view.layer.cornerRadius = 3;
    [self.scrollView addSubview:view];
    
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MARK_IMG_WIRTH, MARK_IMG_HEIGHT, KSCREEN_SIZE.width-40-MARK_IMG_HEIGHT*2, rect1.size.height)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 0;
    titleLabel.tag = 702;
    titleLabel.text = model.title;
    titleLabel.font = [UIFont systemFontOfSize:ADDRESSFONT];
    [view addSubview:titleLabel];
    
    //            CGFloat labelY = firstFlag ? MESSAGE_Y + originY : originY;
    MLEmojiLabel *label = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(MARK_IMG_WIRTH, CGRectGetMaxY(titleLabel.frame), KSCREEN_SIZE.width - 40 - MARK_IMG_HEIGHT *2, rect2.size.height + 10)];
    label.bundle = [StringUtil getBundle];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [label setEmojiText:model.url];
    [label setFont:[UIFont systemFontOfSize:TEXT_MESSAGE_FONT]];
    
    label.userInteractionEnabled = YES;
    
    label.emojiDelegate = self;
    
    // 不支持话题和@用户
    label.isNeedAtAndPoundSign = NO;
    label.customEmojiRegex = @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    label.customEmojiPlistName = @"expressionImage_custom.plist";
    
    [label sizeToFit];
    [view addSubview:label];
    
    
    view.frame =CGRectMake(IMAGEVIEW_X, IMAGEVIEW_Y, KSCREEN_SIZE.width - 40, CGRectGetMaxY(label.frame)+5);
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, CGRectGetMaxY(view.frame)+15, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
    [timeLabel setTextColor:[UIColor lightGrayColor]];
    NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
    [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
    [self.scrollView addSubview:timeLabel];
    
    if (self.collectionModel.groupName.length)
    {
        UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, CGRectGetMaxY(view.frame)+15, KSCREEN_SIZE.width - 120, PIC_TIME_LABEL_HEIGHT)];
        groupName.numberOfLines = 0;
        [groupName setTextColor:[UIColor lightGrayColor]];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
        [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
        [self.scrollView addSubview:groupName];
    }
    
    //            self.scrollView.contentSize = CGSizeMake(0, IMAGEVIEW_Y + height + 15 + PIC_TIME_LABEL_HEIGHT);
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(view.frame) + PIC_TIME_LABEL_HEIGHT);
    

}
- (void)addLocatinView
{
    _model = [self getLocationModleFrom:self.collectionModel.body];
    NSString *mapPath = [StringUtil getMapPath:_model.lantitudeStr withLongitude:_model.longtitudeStr];
    UIImage *img=[UIImage imageWithContentsOfFile:mapPath];
    
    UIView *view = [[UIView alloc]init];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
    view.backgroundColor =   [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
    view.layer.cornerRadius = 0.5;
    [self.scrollView addSubview:view];
    
    
    CGRect rect = [_model.address boundingRectWithSize:CGSizeMake(KSCREEN_SIZE.width - 40 - TIME_LABEL_FONT*2, 50000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:ADDRESSFONT]} context:nil];
    UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(TIME_LABEL_FONT, 0, KSCREEN_SIZE.width - 40-TIME_LABEL_FONT*2, rect.size.height+8)];
    address.textColor = [UIColor blackColor];
    address.font = [UIFont systemFontOfSize:15];
    address.backgroundColor = [UIColor whiteColor];
    address.numberOfLines = 0;
    address.text = _model.address;
    [view addSubview:address];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(address.frame), KSCREEN_SIZE.width - 40, TEXT_TIME_LABEL_WIRTH)];
    UIImage *image = [img imageByScalingAndCroppingForSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];

    imageView.image = image;
    [view addSubview:imageView];
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedLocatinView)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tap];
    
    view.frame = CGRectMake(IMAGEVIEW_X, IMAGEVIEW_Y, KSCREEN_SIZE.width - 40, rect.size.height+8+TEXT_TIME_LABEL_WIRTH);
    
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, CGRectGetMaxY(view.frame)+15, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
    [timeLabel setTextColor:[UIColor lightGrayColor]];
    NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];
    
    [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
    [self.scrollView addSubview:timeLabel];
    
    if (self.collectionModel.groupName.length)
    {
        UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, CGRectGetMaxY(view.frame)+15, KSCREEN_SIZE.width - 120, PIC_TIME_LABEL_HEIGHT)];
        groupName.numberOfLines = 0;
        [groupName setTextColor:[UIColor lightGrayColor]];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
        [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
        [self.scrollView addSubview:groupName];
    }
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(view.frame) + PIC_TIME_LABEL_HEIGHT);
}
- (void)clickedLocatinView
{
    NSLog(@"跳转到地图页面");
    receiveMapViewController *mapViewCtl = [[receiveMapViewController alloc] init];
    mapViewCtl.latitude = _model.lantitude;
    mapViewCtl.longitude = _model.longtitude;
    NSString *address = _model.address;
    NSArray *addressArr = [address componentsSeparatedByString:@"-"];
    if (addressArr.count == 1) {
        mapViewCtl.buildingName = addressArr[0];
        mapViewCtl.address = addressArr[0];
    }else{
        mapViewCtl.buildingName = addressArr[0];
        mapViewCtl.address = addressArr[1];
    }
    //    mapViewCtl.forwardRecord = _convRecord;
    
    [self.navigationController pushViewController:mapViewCtl animated:YES];
}


// 查看大图
- (void)lookOverThePic
{
    FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    [self.navigationController pushViewController:localGallery animated:YES];
    
    
//    LookOverPhotoViewController *viewCtl = [[LookOverPhotoViewController alloc] initWithImage:self.collectionModel.picture];
//    viewCtl.view.backgroundColor = [UIColor lightGrayColor];
//    viewCtl.view.frame = CGRectMake(0, -64, KSCREEN_SIZE.width, KSCREEN_SIZE.height);
//    
//    self.navigationController.navigationBarHidden = YES;
//    // 设置返回按钮的标题
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    self.navigationItem.backBarButtonItem = backItem;
//    backItem.title = [StringUtil getLocalizableString:@"back"];
//    [self.navigationController pushViewController:viewCtl animated:YES];
}

#pragma mark - FGalleryViewControllerDelegate
- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController*)gallery
{
    return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController*)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
    return FGalleryPhotoSourceTypeLocal;
}

- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    //    return self.collectionModel.title ? self.collectionModel.title : self.collectionModel.body;
    NSString *pathStr ;
    if (size == FGalleryPhotoSizeThumbnail) {
        pathStr = [[NSString alloc] initWithFormat:@"%@",[ViewPicUtil getPicPathWithMsgBody:self.collectionModel.body andPicType:pic_type_small]];
    }else {
        pathStr =  [[NSString alloc] initWithFormat:@"%@",[ViewPicUtil getPicPathWithMsgBody:self.collectionModel.body andPicType:pic_type_origin]];
    }
    return pathStr;
}

- (NSString *)fileNameOfGalleryPhoto:(NSUInteger)index
{
    NSString *fileName = nil;
    if(index >= 0 && index < 1) {
        NSString *picPath = [ViewPicUtil getPicPathWithMsgBody:self.collectionModel.body andPicType:pic_type_origin];
        if ([[NSFileManager defaultManager]fileExistsAtPath:picPath]) {
            fileName = [[NSString alloc] initWithFormat:@"%@",[ViewPicUtil getPicNameWithMsgBody:self.collectionModel.body andPicType:pic_type_origin]];
        }else{
            fileName = [[NSString alloc] initWithFormat:@"%@",[ViewPicUtil getPicNameWithMsgBody:self.collectionModel.body andPicType:pic_type_small]];
        }
    }
    return fileName;
}

- (void)pushQLPreviewCtl
{
    ConvRecord *_convRecord = [[ConvRecord alloc] init];
    _convRecord.file_name = self.collectionModel.title ? self.collectionModel.title : self.collectionModel.fileName;
    _convRecord.msg_body = self.collectionModel.title ? self.collectionModel.fileName : self.collectionModel.body;
    
    
    if ([StringUtil isVideoFile:[_convRecord.file_name pathExtension]])
    {
        NSString *filePath = self.collectionModel.title ? self.collectionModel.fileName : self.collectionModel.body;
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
            DisplayVideoViewController *videoCtrl = [[DisplayVideoViewController alloc]init];
            videoCtrl.message = filePath;
            [self.navigationController pushViewController:videoCtrl animated:YES];
        }
    }
    else
    {
        // 换用webView展示文件内容 excel类型文件使用自定义的loolfileviewcontroller,其它则继续使用系统程序
        if ([StringUtil isExcelFile:_convRecord.file_name])
        {
            LookFileViewController *lookFileViewController = [[LookFileViewController alloc]init];
            FileRecord *_fileRecord = [[FileRecord alloc]init];
            _fileRecord.convRecord = _convRecord;
            
            
            // 定制文件浏览界面的返回按钮
            UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: [StringUtil getLocalizableString:@"back"] style: UIBarButtonItemStyleBordered target: nil action: nil];
            [[self navigationItem] setBackBarButtonItem: newBackButton];
            
            lookFileViewController.fileRecord = _fileRecord;
            [self.navigationController pushViewController:lookFileViewController animated:NO];
        }
        else
        {
            [[RobotDisplayUtil getUtil]openNormalFile:self andCurVC:self];
        }
    }
}

- (void)openDetailWeb
{
    openWebViewController *openWeb = [[openWebViewController alloc] init];
    openWeb.urlstr = self.collectionModel.imgtextURL;
    
    self.navigationController.navigationItem.backBarButtonItem.title = [StringUtil getLocalizableString:@"back"];
    openWeb.title = self.collectionModel.title;
    [self.navigationController pushViewController:openWeb animated:YES];
}

- (void)comeToTalkSession
{
    /*
     eCloudDAO *_ecloud = [eCloudDAO getDatabase];
     
     ConvRecord *_convRecord = [_ecloud getConvRecordByMsgId:[NSString stringWithFormat:@"%d",self.collectionModel.ID]];
     
     Conversation *conv = [_ecloud getConversationByConvId:_convRecord.conv_id];
     
     conv.last_record = _convRecord;
     
     talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
     talkSession.talkType = conv.conv_type;
     talkSession.convId = conv.conv_id;
     talkSession.needUpdateTag = 1;
     talkSession.titleStr = [conv getConvTitle];
     talkSession.convEmps = [conv getConvEmps];
     talkSession.fromConv = conv;
     
     //    代表从会话查询结果来到会话界面的
     talkSession.fromType = talksession_from_conv_query_result_need_position;
     
     [self.navigationController pushViewController:talkSession animated:YES];
     */
}

#pragma mark - 复制时的长按手势
- (void)copyLongPress:(UIGestureRecognizer *)sender
{
    CGPoint point;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        point = [sender locationInView:self.view];
        
        UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"复制"                                                          action:@selector(copy1:)];
        
        [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
        [[UIMenuController sharedMenuController] setTargetRect:CGRectMake(point.x, point.y, 50, 50) inView:self.view];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

//针对于响应方法的实现
-(void)copy1:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.messageLabel.text;
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy1:))
    {
        return YES;
    }
    return NO;
}

- (void)relayLongPress:(UIGestureRecognizer *)sender
{
    return;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (IOS8_OR_LATER)
        {
            UIAlertController *alertCtl = [[UIAlertController alloc] init];
            
            //        UIAlertAction *relayAction = [UIAlertAction actionWithTitle:@"转发" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            //        }];
            
            UIAlertAction *sendToAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"send_to_someone"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
                NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
                
                //存入本地
                NSString *picpath = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
                
                NSData *imageData = UIImageJPEGRepresentation(self.collectionModel.picture, 1);
                
                
                ConvRecord *_convRecord = nil;
                if (imageData)
                {
                    BOOL success = [imageData writeToFile:picpath atomically:YES];
                    if (success)
                    {
                        _convRecord = [[ConvRecord alloc]init];
                        _convRecord.msg_type = type_pic;
                        _convRecord.msg_body = currenttimeStr;
                        self.forwardRecord = _convRecord;
                    }
                }
                if (_convRecord)
                {
                    [self openRecentContacts];
                }
                
            }];
            
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"delete"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                
                if (_delegate && [_delegate respondsToSelector:@selector(deleteCollection:)])
                {
                    [_delegate deleteCollection:self.collectionModel];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                [self popoverPresentationController];
            }];
            
            [alertCtl addAction:sendToAction];
            [alertCtl addAction:deleteAction];
            [alertCtl addAction:cancelAction];
            
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
        else
        {
            UIActionSheet *menu = [[UIActionSheet alloc]
                                   initWithTitle:nil
                                   delegate:self
                                   cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:[StringUtil getLocalizableString:@"send_to_someone"],[StringUtil getLocalizableString:@"delete"], nil];
            [menu showInView:self.view];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex is %d",buttonIndex);
#ifdef _LANGUANG_FLAG_
    if (self.collectionModel.type == type_record)
    {
        if (buttonIndex == 0)
        {
            [self deleteThisCollect];
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            [self sendThisCollect];
        }
        else if (buttonIndex == 1)
        {
            [self deleteThisCollect];
        }
    }
#else
    if (buttonIndex == 0)
    {
        [self sendThisCollect];
    }
    else if (buttonIndex == 1)
    {
        [self deleteThisCollect];
    }
#endif
}

#pragma mark - 发送给朋友（借用转发功能）
//打开最近的联系人，用来转发
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc] initWithConvRecord:self.forwardRecord];
    forwarding.fromType = transfer_from_collection;
    forwarding.fromVC = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:nav animated:YES];
}

#pragma mark =======转发提示=======
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

#pragma mark - 播放结束发送的通知
- (void)playbackQueueStopped:(NSNotification *)note
{
    isPlaying = NO;
    // 停止动画
    [self.voicePlayImg stopAnimating];
    
    if ([_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
    if ([_progressTimer isValid])
    {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
    
    //    self.progressView.progress = 0;
    
    self.durationLabel.text = [NSString stringWithFormat:@"%@''",self.collectionModel.fileSize];
}

- (void)_timerAction:(id)timer
{
    if (_record_fileSize > 0)
    {
        self.durationLabel.text = [NSString stringWithFormat:@"%.f''",--_record_fileSize];
    }
}


- (void)_progressTimerAction:(id)timer
{
    //    self.progressView.progress = (_currentTime += .1f) / _record_fileSize;
}

- (void)playOrPause
{
    _currentTime = 0.0;
    
    if (isPlaying)
    {
        if ([_timer isValid])
        {
            [_timer invalidate];
            _timer = nil;
        }
        if ([_progressTimer isValid])
        {
            [_progressTimer invalidate];
            _progressTimer = nil;
        }
        
        
        // 结束动画
        [self.voicePlayImg stopAnimating];
        
        if ([audioplayios6 stopPlayAudio]) //[self.talkSessionCtl stopPlayAudio]
        {
            isPlaying = NO;
            return;
        }
    }
    
    //开始动画
    [self.voicePlayImg startAnimating];
    
    //    self.progressView.progress = (_currentTime += .3f) / _record_fileSize;
    
    // 初始化时长
    _record_fileSize = [self.collectionModel.fileSize integerValue] - 1;
    self.durationLabel.text = [NSString stringWithFormat:@"%.f''",_record_fileSize];
    
    
    // 更新时间的计时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop  currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    // 更新进度的定时器
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(_progressTimerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
    
    isPlaying = YES;
    
    
    NSString *filePath = self.collectionModel.title ? self.collectionModel.fileName : self.collectionModel.body;
    if (decryptFlag == NO)
    {
        if ([eCloudConfig getConfig].needFixSecurityGap)
        {
            NSData *data = [EncryptFileManege getDataWithPath:filePath];
            NSString *tmpDir = NSTemporaryDirectory();
            NSArray *arr = [filePath componentsSeparatedByString:@"/"];
            NSString *newPath = [tmpDir stringByAppendingPathComponent:[arr lastObject]];
            [data writeToFile:newPath atomically:YES];
            
            filePath = newPath;
        }
        
        decryptFlag = YES;
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        
        NSRange range = [filePath rangeOfString:@".amr"];
        
        if (range.length > 0)
        {//需要转换
            NSString * docFilePath        = [[CollectionUtil newRcvFilePath] stringByAppendingPathComponent:@"amrAudio.wav"];
            if (amrtowav == nil) {
                amrtowav = [[amrToWavMothod alloc] init];
            }
            [amrtowav startAMRtoWAV:filePath tofile:docFilePath];
            
            
            [audioplayios6 playAudio:docFilePath];
            
            return;
        }
        
        [audioplayios6 playAudio:filePath];
    }
}

#pragma mark - MLEmojiLabelDelegate
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
        {
            flag2 = NO;
            
            openWebViewController *openWeb = [[openWebViewController alloc] init];
            openWeb.urlstr = link;
            
            [self.navigationController pushViewController:openWeb animated:YES];
            
            NSLog(@"点击了链接%@",link);
        }
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
            NSLog(@"点击了电话%@",link);
            break;
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            break;
        case MLEmojiLabelLinkTypeAt:
            NSLog(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            NSLog(@"点击了话题%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
    }
}

#pragma mark QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller;
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSString *filePath = [CollectionUtil getTheFilePath:self.collectionModel.body with:self.collectionModel.fileName];
        
        NSData *data = [EncryptFileManege getDataWithPath:filePath];
        NSString *tmpDir = NSTemporaryDirectory();
        NSString *newPath = [tmpDir stringByAppendingPathComponent:self.collectionModel.fileName];
        [data writeToFile:newPath atomically:YES];
        
        self.collectionModel.body = newPath;
        
        return [NSURL fileURLWithPath:newPath];
    }
    else
    {
        
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        
        _convRecord.file_name = self.collectionModel.fileName;
        
        _convRecord.msg_body = self.collectionModel.body;
        _convRecord.robotModel = self.collectionModel.robotModel;
        _convRecord.msg_type = self.collectionModel.realType;
        
        FileRecord *_fileRecord = [[FileRecord alloc]init];
        _fileRecord.convRecord = _convRecord;
        
        return _fileRecord;
        
        //        return [NSURL fileURLWithPath:[CollectionUtil getTheFilePath:self.collectionModel.body with:self.collectionModel.fileName]];
    }
    
    return nil;
}

- (void)exitting
{
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//转发当前收藏
- (void)sendThisCollect
{
    NSMutableArray *mArr = [NSMutableArray array];
    ConvRecord *_convRecord = [CollectionDetailController getConvRecordByCollectModel:self.collectionModel];
    
    if (!_convRecord) {
        return;
    }
    
    [mArr addObject:_convRecord];
    
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc]init];
    forwarding.fromType = transfer_from_collection;
    forwarding.fromVC = self;
    
    forwarding.forwardRecordsArray = [NSArray arrayWithArray:mArr];
    
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [self presentModalViewController:nav animated:YES];
}

//删除这条收藏
- (void)deleteThisCollect
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteCollection:)])
    {
        [_delegate deleteCollection:self.collectionModel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initFileMsgView
{
    UIImageView *backgroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80,  KSCREEN_SIZE.width-40, 60)];
    backgroupImg.image = [StringUtil getImageByResName:@"frameCircle.png"];
    
    backgroupImg.backgroundColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
    backgroupImg.layer.cornerRadius = 3;
    backgroupImg.layer.borderWidth = 0.5;
    backgroupImg.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
    UIImageView *fileType = [[UIImageView alloc] initWithFrame:CGRectMake(28, 87, 45, 45)];
    
    UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(78, 87, KSCREEN_SIZE.width-102, 30)];
    [fileName setFont:[UIFont systemFontOfSize:13]];
   
    UILabel *fileSize = [[UILabel alloc] initWithFrame:CGRectMake(78, 107, 100, 30)];
    [fileSize setFont:[UIFont systemFontOfSize:12]];
    [fileSize setTextColor:[UIColor grayColor]];
    
    if (self.collectionModel.title) {
        fileType.image = [StringUtil getFileDefaultImage:self.collectionModel.title];
        fileName.text = self.collectionModel.title;
        fileSize.text = self.collectionModel.fileSize;
    }else{
        fileType.image = [StringUtil getImageByResName:@"ic_chat_file"];
        fileName.text = self.collectionModel.fileName;
        fileSize.text = [StringUtil getDisplayFileSize:self.collectionModel.fileSize.intValue];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 80, KSCREEN_SIZE.width-40, 50);
    [button addTarget:self action:@selector(pushQLPreviewCtl) forControlEvents:UIControlEventTouchUpInside ];
    
    [self.scrollView addSubview:backgroupImg];
    [self.scrollView addSubview:button];
    [self.scrollView addSubview:fileType];
    [self.scrollView addSubview:fileName];
    [self.scrollView addSubview:fileSize];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(PIC_TIME_LABEL_X, 150, PIC_TIME_LABEL_WIRTH, PIC_TIME_LABEL_HEIGHT)];
    [timeLabel setTextColor:[UIColor lightGrayColor]];
    NSString *time = [self.collectionModel.timeText stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    timeLabel.text = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"collected_in"], time];    [timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
    
    if (self.collectionModel.groupName.length)
    {
        UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(120, 150-15, KSCREEN_SIZE.width - 120, 50)];
        groupName.numberOfLines = 0;
        [groupName setTextColor:[UIColor lightGrayColor]];
        groupName.textAlignment = NSTextAlignmentLeft;
        groupName.text = [NSString stringWithFormat:@"%@: %@",[StringUtil getLocalizableString:@"messageFrom"], self.collectionModel.groupName];
        [groupName setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
        [self.scrollView addSubview:groupName];
    }
    
    self.scrollView.contentSize = CGSizeMake(0, IMAGEVIEW_Y + 15 + PIC_TIME_LABEL_HEIGHT);
    //            [self.scrollView addSubview:previewController.view];
    [self.scrollView addSubview:timeLabel];
}

+ (ConvRecord *)getConvRecordByCollectModel:(MyCollectionModel *)collectionModel
{
    ConvRecord *_convRecord = [[ConvRecord alloc]init];
    _convRecord.msg_type = collectionModel.type;
    
    switch (_convRecord.msg_type) {
        case type_text:
        case type_normal_imgtxt:
        {
            _convRecord.msg_body = collectionModel.body;
        }
            break;
        case type_record:
        {
            _convRecord.msg_body = collectionModel.fileName;
            _convRecord.file_name = [NSString stringWithFormat:@"%@.amr",_convRecord.msg_body];
            _convRecord.file_size = collectionModel.fileSize;
            
        }
            break;
        case type_long_msg:
        {
            //                    长消息对应的URL
            _convRecord.msg_body = collectionModel.fileName;
        }
            break;
        case type_video:
        {
            //                    视频消息对应的URL
            _convRecord.msg_body = collectionModel.fileName;
            _convRecord.file_name = [StringUtil getVideoNameByVideoUrl:_convRecord.msg_body];
            _convRecord.file_size = collectionModel.fileSize;
        }
            break;
        case type_file:
        {
            _convRecord.msg_body = collectionModel.body;
            _convRecord.file_name = collectionModel.fileName;
            _convRecord.file_size = collectionModel.fileSize;
            
        }
            break;
        case type_pic:
        {
            //                    图片对应的URL
            _convRecord.msg_body = collectionModel.body;
        }
            break;
            
        default:
        {
            return nil;
        }
            break;
    }
    
    return _convRecord;
}

-(NewLocationModel *)getLocationModleFrom:(NSString *)body
{
    
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    NSDictionary *dics = [dic objectForKey:@"location"];
    
    NewLocationModel *model = [[NewLocationModel alloc]init];
    model.address = [dics objectForKey:@"address"];
    
    
    model.lantitudeStr = [dics objectForKey:@"latitude"];
    model.longtitudeStr = [dics objectForKey:@"longitude"];
    model.lantitude = [[dics objectForKey:@"latitude"] floatValue];
    model.longtitude = [[dics objectForKey:@"longitude"] floatValue];
    return  model;
}

-(LGNewsMdelARC *)getNewsModleFrom:(NSString *)body
{
    
    NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    LGNewsMdelARC *model = [[LGNewsMdelARC alloc]init];
    model.type = [dic objectForKey:@"type"];
    model.title = [dic objectForKey:@"title"] ;
    model.url = [dic objectForKey:@"url"] ;
    
    return  model;
}


@end
