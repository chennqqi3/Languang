//
//  LookOverPhotoViewController.m
//  OpenCtx
//
//  Created by Alex L on 16/3/16.
//  Copyright © 2016年 mimsg. All rights reserved.
//

#import "LookOverPhotoViewController.h"
#import "VIPhotoView.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"

#define KSCREEN_SIZE [UIScreen mainScreen].bounds.size

@interface LookOverPhotoViewController ()<VIPhotoDelegate>

@end

@implementation LookOverPhotoViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        [UIAdapterUtil processController:self];
        self.automaticallyAdjustsScrollViewInsets = NO;
        VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) andImage:image];
        photoView.photoDelegate = self;
        photoView.backgroundColor = [UIColor blackColor];
        photoView.showsVerticalScrollIndicator = FALSE;
        
        photoView.showsHorizontalScrollIndicator = FALSE;
        
        [self.view addSubview:photoView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - VIPhotoDelegate
- (void)popToLastController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

@end
