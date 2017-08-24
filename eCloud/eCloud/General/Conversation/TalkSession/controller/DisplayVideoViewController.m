//
//  DisplayVideoViewController.m
//  eCloud
//
//  Created by yanlei on 15/10/23.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "DisplayVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "StringUtil.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"

@interface DisplayVideoViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerView;

@end

@implementation DisplayVideoViewController
- (MPMoviePlayerController *)moviePlayerController {
    if (!_moviePlayerController) {
        _moviePlayerController = [[MPMoviePlayerController alloc] init];
        // 重复播放属性 MPMovieRepeatModeNone播放一次后停止
        _moviePlayerController.repeatMode = MPMovieRepeatModeNone;
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
        _moviePlayerController.view.frame = self.view.frame;
//        [_moviePlayerController setScalingMode:MPMovieScalingModeAspectFit];
        _moviePlayerController.controlStyle=MPMovieControlStyleEmbedded;
        _moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
        //播放模式，全屏播放，不考虑分辨率和拉伸问题。
        _moviePlayerController.scalingMode = MPMovieScalingModeNone;
        [_moviePlayerController prepareToPlay];
        
//        UITapGestureRecognizer *tapGestureRecoginizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
//        [_moviePlayerController addGestureRecognizer:tapGestureRecoginizer];
        [self.view addSubview:_moviePlayerController.view];
        
//        player.shouldAutoplay=YES;
//        [player setControlStyle:MPMovieControlStyleNone];
        
//        [_moviePlayerController setFullscreen:YES];
    }
    return _moviePlayerController;
}

#pragma mark - Life cycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [StringUtil getLocalizableString:@"video"];
    
    // 第一种播放器
    self.moviePlayerController.contentURL = [NSURL fileURLWithPath:self.message];
    [self.moviePlayerController play];
    
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    // 第二种播放器
    /*
    self.moviePlayerView = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:self.message]];
    //设定播放模式
    self.moviePlayerView.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    //控制模式(触摸)
    self.moviePlayerView.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playingDone) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    //开始播放
    [[[UIApplication sharedApplication]keyWindow]addSubview:self.moviePlayerView.view];*/
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.moviePlayerController stop];
    self.moviePlayerController = nil;
    
    //移除通知(用第二种播放器的时候开启)
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 第二种播放完成后的通知处理方法
-(void)playingDone
{
//    [self.moviePlayerView.view removeFromSuperview];
//    self.moviePlayerView = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_moviePlayerController.view.frame.size.width == SCREEN_WIDTH) {
        return;
    }
    _moviePlayerController.view.frame = self.view.frame;
}
@end
