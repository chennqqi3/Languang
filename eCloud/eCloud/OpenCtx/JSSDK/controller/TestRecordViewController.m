//
//  TestRecordViewController.m
//  eCloud
//
//  Created by shisuping on 16/3/22.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "TestRecordViewController.h"
#import "IOSSystemDefine.h"
#import "RecordUtil.h"
#import "FunctionButtonModel.h"
#import "StringUtil.h"

#import "UIAdapterUtil.h"

@interface TestRecordViewController () <RecordStatusDelegate>

@end

@implementation TestRecordViewController
{
    NSMutableArray *functionArray;
    
    UILabel *statusLabel;
}

- (void)dealloc{
    
    if ([[RecordUtil getUtil]isRecording]) {
        [self stopRecord];
    }
    [self stopVoice];
    
    [RecordUtil getUtil].delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    [RecordUtil getUtil].delegate = self;

    functionArray = [NSMutableArray array];
    
    self.title = @"录音测试";
    
    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(self.view.frame));
    
//生成 scroll view
    UIScrollView *parentScrollView = [[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT)]autorelease];
    
    [self.view addSubview:parentScrollView];
    
    //    增加一个label，提示正在录音
    statusLabel = [[[UILabel alloc]init]autorelease];
    [statusLabel setFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 30)];
    [statusLabel setTextColor:[UIColor redColor]];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [statusLabel setTextAlignment:NSTextAlignmentCenter];
    [statusLabel setText:@"录音测试"];
    [parentScrollView addSubview:statusLabel];
    
    [self prepareButtonItem];
    
    
//    开始录音按钮
    
//    每个按钮的垂直间隔
    float cellSpacingY = 20;
    
//    每个按钮的高度
    float buttonHeight = 45;
    
//    float
    
    for (int i = 0; i < functionArray.count; i++) {
        FunctionButtonModel *_buttonModel = functionArray[i];
//        生成一个button
        UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
//        设置frame
        CGRect _frame = CGRectMake(10, statusLabel.frame.size.height + (cellSpacingY + buttonHeight) * i, SCREEN_WIDTH - 20, buttonHeight);
        [_button setFrame:_frame];
        
//        增加点击事件
        [_button addTarget:self action:_buttonModel.clickSelector forControlEvents:UIControlEventTouchUpInside];
        
//        设置title
        [_button setTitle:_buttonModel.functionName forState:UIControlStateNormal];
        
//        设置字体颜色
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
//        设置背景颜色
        [_button setBackgroundColor:[UIColor blueColor]];
        
        [parentScrollView addSubview:_button];
    }
    
//    设置 scroll view content size
    float scrollHeight =  statusLabel.frame.size.height + (cellSpacingY + buttonHeight) * functionArray.count;
    
    parentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, scrollHeight);
}

- (void)prepareButtonItem
{
    
    //    开始录音按钮
    FunctionButtonModel *_button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"startRecord";
    _button.clickSelector = @selector(startRecord);
    [functionArray addObject:_button];
    [_button release];
    
//    停止录音
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"stopRecord";
    _button.clickSelector = @selector(stopRecord);
    [functionArray addObject:_button];
    [_button release];
    
//    播放录音
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"playVoice";
    _button.clickSelector = @selector(playVoice);
    [functionArray addObject:_button];
    [_button release];
    
    //    暂停播放录音
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"pauseVoice";
    _button.clickSelector = @selector(pauseVoice);
    [functionArray addObject:_button];
    [_button release];
    
//    停止播放录音
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"stopVoice";
    _button.clickSelector = @selector(stopVoice);
    [functionArray addObject:_button];
    [_button release];
    
//    上传录音
    _button = [[FunctionButtonModel alloc]init];
    _button.functionName = @"uploadVoice";
    _button.clickSelector = @selector(uploadVoice);
    [functionArray addObject:_button];
    [_button release];

}

- (void)startRecord
{
    [[RecordUtil getUtil]startRecord];
}

- (void)stopRecord
{
    [[RecordUtil getUtil]stopRecord];
}

- (void)playVoice
{
    [[RecordUtil getUtil]playVoice];
}

- (void)stopVoice
{
    [[RecordUtil getUtil]stopVoice];
}

- (void)pauseVoice
{
    [[RecordUtil getUtil]pauseVoice];
}

- (void)uploadVoice
{
    [[RecordUtil getUtil]uploadVoice];
}

#pragma mark =======record status delegate========
- (void)willStartRecord
{
    statusLabel.text = @"开始录音...";
}

- (void)willStopRecord
{
    statusLabel.text = @"停止录音";
}

- (void)recordTime:(NSNumber *)_second
{
    statusLabel.text = [NSString stringWithFormat:@"录音持续时间:%d",[_second intValue]];
}

- (void)willPlayVoice
{
    statusLabel.text = @"播放录音...";
}

- (void)willStopVoice
{
    statusLabel.text = @"停止播放录音";
}

- (void)willPauseVoice
{
    statusLabel.text = @"暂停播放录音";
}

// 显示状态
- (void)dspStatus:(NSString *)statusStr
{
    statusLabel.text = statusStr;
}

@end
