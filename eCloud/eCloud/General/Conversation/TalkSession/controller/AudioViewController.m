//
//  AudioViewController.m
//  eCloud
//
//  Created by Alex L on 16/4/8.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "AudioViewController.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "AudioUtil.h"
#import "ForwardingRecentViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface AudioViewController ()<AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate,ForwardingDelegate>
{
    /**
     *  播放进度定时器
     */
    NSTimer *_currentTimeTimer;
}
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) UIButton *playOrPauseButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) UILabel *fileNameLabel;

@end

@implementation AudioViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resetPlayingMusic];
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = self.fileName;
    
    NSLog(@"mainScreen = %f view = %f", kSCREEN_HEIGHT, self.view.frame.size.height);
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH/2-35, kSCREEN_HEIGHT/3.0, 70, 70)];
    self.imgView.image = [StringUtil getImageByResName:@"chat_files_music@2x.png"];
    self.imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, kSCREEN_HEIGHT/3.0+70, kSCREEN_WIDTH-60, 50)];
    [self.fileNameLabel setFont:[UIFont systemFontOfSize:16]];
    self.fileNameLabel.textAlignment = NSTextAlignmentCenter;
    self.fileNameLabel.numberOfLines = 0;
    self.fileNameLabel.text = self.fileName;
    self.fileNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0, kSCREEN_HEIGHT*(3.0/4.0), kSCREEN_WIDTH, 2);
    self.progressView.backgroundColor = [UIColor clearColor];
    [self.progressView setProgressTintColor:[UIColor colorWithRed:102/255.0 green:204/255.0 blue:1 alpha:1]];
    [self.progressView setTrackTintColor:[UIColor colorWithWhite:.9 alpha:1]];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat originY =  kSCREEN_HEIGHT*(3.0/4.0) + ((kSCREEN_HEIGHT - 55 - 10) - kSCREEN_HEIGHT*(3.0/4.0))/2.0 - 30;
    self.playOrPauseButton.frame = CGRectMake(kSCREEN_WIDTH/2-30, originY, 60, 60);
    [self.playOrPauseButton setBackgroundImage:[StringUtil getImageByResName:@"message_video_play@2x.png"] forState:UIControlStateNormal];
    [self.playOrPauseButton setBackgroundImage:[StringUtil getImageByResName:@"message_video_pause@2x.png"] forState:UIControlStateSelected];
    [self.playOrPauseButton addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    self.playOrPauseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, kSCREEN_HEIGHT*(3.0/4.0)+7, 70, 25)];
    self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.currentTimeLabel setFont:[UIFont systemFontOfSize:15]];
    self.currentTimeLabel.text = @"0:00";
    
    self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSCREEN_WIDTH-80, kSCREEN_HEIGHT*(3.0/4.0)+7, 70, 25)];
    [self.durationLabel setFont:[UIFont systemFontOfSize:15]];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    self.durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    self.durationLabel.text = @"0:00";
    
    self.durationLabel.text = [self strWithTime:[AudioUtil getAudioDuration:self.filePath]];
    
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREEN_HEIGHT - 55 - 10, kSCREEN_WIDTH, 1)];
    separateView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [openButton addTarget:self action:@selector(openUseOtherApp) forControlEvents:UIControlEventTouchUpInside];
    [openButton setTitle:[StringUtil getLocalizableString:@"open_with_other_app"] forState:UIControlStateNormal];
    [openButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    openButton.backgroundColor = [UIColor colorWithWhite:0.45 alpha:1];
    openButton.frame = CGRectMake(10, kSCREEN_HEIGHT - 52, kSCREEN_WIDTH/2.0 - 20, 42);
    openButton.layer.cornerRadius = 3;
    openButton.clipsToBounds = YES;
    
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardButton addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
    [forwardButton setTitle:[StringUtil getLocalizableString:@"forward"] forState:UIControlStateNormal];
    [forwardButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    forwardButton.backgroundColor = [UIColor colorWithWhite:0.45 alpha:1];
    forwardButton.frame = CGRectMake(kSCREEN_WIDTH/2.0 + 10, kSCREEN_HEIGHT - 52, kSCREEN_WIDTH/2.0 - 20, 42);
    forwardButton.layer.cornerRadius = 3;
    forwardButton.clipsToBounds = YES;
    
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.fileNameLabel];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.playOrPauseButton];
    [self.view addSubview:self.currentTimeLabel];
    [self.view addSubview:self.durationLabel];
//    [self.view addSubview:separateView];
//    [self.view addSubview:openButton];
//    [self.view addSubview:forwardButton];
}

- (void)openUseOtherApp
{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.filePath]];
    self.documentController.delegate = self;
    [self.documentController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

#pragma mark - UIDocumentInteractionController_delegate
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    NSLog(@"willBeginSend");
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSLog(@"endSend");
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    NSLog(@"dismiss");
}

#pragma mark - 转发
- (void)forward
{
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc]init];
    forwarding.fromType = transfer_from_collection;
    forwarding.forwardingDelegate = self;
    
    forwarding.forwardRecordsArray = @[self.convRecord];
    
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [self presentModalViewController:nav animated:YES];
}

- (void)playOrPause {
    self.playOrPauseButton.selected = !self.playOrPauseButton.selected;
    if (self.player.isPlaying)
    {
        // 暂停
        self.playOrPauseButton.selected = NO;
        [AudioUtil pauseMusic:self.filePath];
        [self removeCurrentTimeTimer];
    }
    else   // 播放
    {
        self.playOrPauseButton.selected = YES;
        if (self.player) {
            [AudioUtil playMusic:self.filePath];
            [self addCurrentTimeTimer];
        }
        else
        {
            [self startPlayingMusic];
        }
    }
}

/**
 *  重置正在播放的音乐
 */
- (void)resetPlayingMusic
{
    // 1.停止播放
    [AudioUtil stopMusic:self.filePath];
    self.player = nil;
    
    // 2.停止定时器
    [self removeCurrentTimeTimer];
    
    // 3.设置播放按钮状态
    self.playOrPauseButton.selected = NO;
    self.currentTimeLabel.text = self.durationLabel.text;
}

/**
 *  开始播放音乐
 */
- (void)startPlayingMusic
{
    // 1.开始播放
    self.player = [AudioUtil playMusic:self.filePath];
    // 设置音量
    self.player.delegate = self;
    
    // 2.设置时长
//    self.durationLabel.text = [self strWithTime:self.player.duration];
    
    // 3.开始定时器
    [self addCurrentTimeTimer];
    
    // 4.设置播放按钮状态
    self.playOrPauseButton.selected = YES;
    
    // 5.更新锁屏状态的信息
    [self updateLockedScreenMusic];
}

#pragma mark - 定时器处理
- (void)addCurrentTimeTimer
{
    if (self.player.isPlaying == NO) return;
    
    [self removeCurrentTimeTimer];
    
    // 保证定时器的工作是及时的
    [self updateCurrentTime];
    
    _currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_currentTimeTimer forMode:NSRunLoopCommonModes];
}

- (void)removeCurrentTimeTimer
{
    [_currentTimeTimer invalidate];
    _currentTimeTimer = nil;
}

/**
 *  更新播放进度
 */
- (void)updateCurrentTime
{
    // 1.计算进度值
    double progress = self.player.currentTime / self.player.duration;
    
    // 2.设置当前时间的值
    self.currentTimeLabel.text = [self strWithTime:self.player.currentTime];
    
    // 3.设置进度条的宽度
    self.progressView.progress = progress;
}

#pragma mark - 私有方法
/**
 *  时长长度 -> 时间字符串
 */
- (NSString *)strWithTime:(NSTimeInterval)time
{
    int minute = time / 60;
    int second = (int)time % 60;
    return [NSString stringWithFormat:@"%d:%02d", minute, second];
}

#pragma mark - AVAudioPlayerDelegate
// 播放完毕后就会调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self resetPlayingMusic];
}

// 更新锁屏状态的信息
- (void)updateLockedScreenMusic
{
    // 1.播放信息中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.初始化播放信息
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    // 歌手
    info[MPMediaItemPropertyArtist] = self.fileName;
    // 歌曲名称
    info[MPMediaItemPropertyTitle] = self.fileName;
    // 设置图片
    //    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[StringUtil getImageByResName:@"chat_files_music@2x.png"]];
    
    // 设置持续时间（歌曲的总时间）
    info[MPMediaItemPropertyPlaybackDuration] = @([self.player duration]);
    // 设置当前播放进度
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.player.currentTime);
    
    // 3.切换播放信息
    center.nowPlayingInfo = info;
    
    // 远程控制事件 Remote Control Event
    // 加速计事件 Motion Event
    // 触摸事件 Touch Event
    
    // 4.开始监听远程控制事件
    // 4.1.成为第一响应者（必备条件）
    [self becomeFirstResponder];
    // 4.2.开始监控
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

// 响应锁屏状态下的暂停和播放
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        self.playOrPauseButton.selected = !self.playOrPauseButton.selected;
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
            {
                self.playOrPauseButton.selected = YES;
                if (self.player) {
                    [AudioUtil playMusic:self.filePath];
                    [self addCurrentTimeTimer];
                }
                else
                {
                    [self startPlayingMusic];
                }
            }
                break;
                
            case UIEventSubtypeRemoteControlPause:
            {
                self.playOrPauseButton.selected = NO;
                [AudioUtil pauseMusic:self.filePath];
                [self removeCurrentTimeTimer];
            }
                
            default:
                break;
        }
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
 
    CGRect _frame;
    _frame = self.progressView.frame;
    if (_frame.origin.y == SCREEN_HEIGHT * 0.75) {
        return;
    }
    
    _frame.origin.y = SCREEN_HEIGHT * 0.75;
    self.progressView.frame = _frame;
    
    _frame = self.imgView.frame;
    _frame.origin.y = SCREEN_HEIGHT / 3.0;
    self.imgView.frame = _frame;
    
    _frame = self.fileNameLabel.frame;
    _frame.origin.y = self.imgView.frame.origin.y + 70.0;
    self.fileNameLabel.frame = _frame;
    
    _frame = self.currentTimeLabel.frame;
    _frame.origin.y = self.progressView.frame.origin.y + 7;
    self.currentTimeLabel.frame = _frame;
    
    _frame = self.durationLabel.frame;
    _frame.origin.y = self.currentTimeLabel.frame.origin.y;
    self.durationLabel.frame = _frame;
    
    _frame = self.playOrPauseButton.frame;
    _frame.origin.y = self.currentTimeLabel.frame.origin.y + 40;
    self.playOrPauseButton.frame = _frame;
}

@end
