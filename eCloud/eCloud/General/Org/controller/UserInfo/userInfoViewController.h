//
//  userInfoViewController.h
//  eCloud
//  当前登录用户资料界面
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>


@class conn;
@class FGalleryViewController;
@class Emp;
@class UserInfo;

@interface userInfoViewController : UIViewController

/** deprecated */
@property(nonatomic,retain) NSString *titleStr;

/** 当前登录用户的数据模型 */
@property(nonatomic,retain) Emp *emp;

/** deprecated */
@property int tagType;

/** 从用户数据库里搜索到的用户数据模型 */
@property (nonatomic,retain) UserInfo *userInfo;
@end


@interface UIImagePickerController (LandScapeImagePicker)
- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
@end
