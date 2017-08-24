//
//  receiveMapViewController.h
//  eCloud
//  展示收到的位置信息
//  Created by Alex L on 16/4/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConvRecord;

@interface receiveMapViewController : UIViewController

/** 纬度 */
@property (nonatomic, assign) CGFloat latitude;
/** 经度 */
@property (nonatomic, assign) CGFloat longitude;
/** 建筑物名字 */
@property (nonatomic, strong) NSString *buildingName;
/** 地址信息 */
@property (nonatomic, strong) NSString *address;
/** 位置信息对应的模型，用来转发给其它联系人 */
@property (nonatomic, strong) ConvRecord *forwardRecord;
@end
