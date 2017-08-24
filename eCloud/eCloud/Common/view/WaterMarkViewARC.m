//
//  WaterMarkViewARC.m
//  eCloud
//
//  Created by Ji on 17/6/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WaterMarkViewARC.h"
#import "IOSSystemDefine.h"
#import "UserDefaults.h"

@implementation WaterMarkViewARC

+ (void)waterMarkView:(UIView *)view
{
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

    // 日期初始化
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (IPHONE_5S_OR_LESS)
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm"];
    }
    else
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm:ss"];
    }
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSString *str = [NSString stringWithFormat:@"祥云\n持有人:%@\n%@", [UserDefaults getUserAccount],time];

    UILabel *waterMarkkLabel = [[UILabel alloc] initWithFrame:CGRectMake(-15, 20, 200, 100)];
    waterMarkkLabel.userInteractionEnabled = NO;
    waterMarkkLabel.numberOfLines = 0;
    waterMarkkLabel.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel.text = str;
    waterMarkkLabel.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];
    
    [view addSubview:waterMarkkLabel];
    
    UILabel *waterMarkkLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, 20, 200, 100)] ;
    waterMarkkLabel1.userInteractionEnabled = NO;
    waterMarkkLabel1.numberOfLines = 0;
    waterMarkkLabel1.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel1.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel1 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel1.text = str;
    waterMarkkLabel1.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];
    
    [view addSubview:waterMarkkLabel1];

    
    UILabel *waterMarkkLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(-15, SCREEN_HEIGHT-200-44, 200, 100)];
    waterMarkkLabel2.userInteractionEnabled = NO;
    waterMarkkLabel2.numberOfLines = 0;
    waterMarkkLabel2.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel2.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel2 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel2.text = str;
    waterMarkkLabel2.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];
    
    [view addSubview:waterMarkkLabel2];

    
    UILabel *waterMarkkLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, SCREEN_HEIGHT-200-44, 200, 100)];
    waterMarkkLabel3.userInteractionEnabled = NO;
    waterMarkkLabel3.numberOfLines = 0;
    waterMarkkLabel3.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel3.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel3 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel3.text = str;
    waterMarkkLabel3.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];
    
    [view addSubview:waterMarkkLabel3];

    UILabel *waterMarkkLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-100, SCREEN_HEIGHT/2-50-64, 200, 100)];
    waterMarkkLabel4.userInteractionEnabled = NO;
    waterMarkkLabel4.numberOfLines = 0;
    waterMarkkLabel4.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel4.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel4 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel4.text = str;
    waterMarkkLabel4.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];
    
    [view addSubview:waterMarkkLabel4];
//    return view;
}

@end
