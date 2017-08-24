//
//  TAIHEWXWorkView.h
//  eCloud
//
//  Created by yanlei on 2017/1/17.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APPListModel;

@interface TAIHEWXWorkView : UIView
/** 第三方应用模型 */
@property (nonatomic, strong) APPListModel *appModel;

+ (instancetype)workView;
@end
