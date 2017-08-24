//
//  personInfoViewController.h
//  eCloud
//  通讯录联系人资料界面
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@class Emp;
@class FGalleryViewController;
@class talkSessionViewController;
@class talkSessionViewController;
@class ASIHTTPRequest;

@interface personInfoViewController : UIViewController

/** deprecated */
@property (nonatomic,retain) UIButton *sendMsgButton;

/** 用户大头像的路径 */
@property(nonatomic,retain)  NSString *preImageFullPath;

/** 用户性别 */
@property(assign) int sexType;

/** deprecated */
@property(nonatomic,retain) NSString *titleStr;

/** 联系人数据模型 */
@property(nonatomic,retain) Emp *emp;

/** deprecated */
@property(nonatomic,retain) id delegate;

/** 是否是从通讯录界面打开联系人资料 */
@property(nonatomic,assign) BOOL isComeFromContactView;

/** 是否从选择联系人界面打开联系人资料 */
@property(nonatomic,assign) BOOL isComeFromChooseView;


/**
 拨打电话的静态方法

 @param number 要拨打的电话号码
 */
+ (void)callNumber:(NSString *)number;
@end
