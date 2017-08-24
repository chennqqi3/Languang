//
//  redpacketViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/5/10.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface redpacketViewControllerARC : UIViewController

+(redpacketViewControllerARC *)getRedpacketViewController;


- (void)addRedPacket:(UIViewController *)curVC andConvType:(int)convType convEmps:(NSArray *)convEmp;

/** 抢红包 */
- (void)redpacketTouched:(UIViewController *)curVC redpacketDic:(NSDictionary *)redpacketDic;
@end
