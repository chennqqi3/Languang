//
//  PlayVideoViewController.m
//  eCloud
//
//  Created by Ji on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoViewController ()<AVAudioPlayerDelegate>
{
    UIImageView *_photo;
}
@property (strong ,nonatomic) AVPlayer *player;
@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *videoStr = [user objectForKey:@"videoPath"];
    if (videoStr) {
        _photo = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]autorelease];
        [self.view addSubview:_photo];
        NSURL *url=[NSURL fileURLWithPath:videoStr];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=_photo.frame;
        [_photo.layer addSublayer:playerLayer];
        [_player play];
    
    }
}

- (void)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
