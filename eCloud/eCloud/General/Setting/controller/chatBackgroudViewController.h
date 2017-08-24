//
//  chatBackgroudViewController.h
//  eCloud
//  设置聊天背景界面 在查看聊天资料界面(设置当前会话) 或者 设置界面 可以设置聊天背景(设置会话默认背景)
//  Created by  lyong on 14-6-25.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

@class chooseChatBackGroudViewController;

@interface chatBackgroudViewController : UIViewController<UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,FGalleryViewControllerDelegate>

/** 对应某个会话的背景图片路径 */
@property(nonatomic,retain)NSString *one_chat_imagename;

/**
 返回到聊天界面 设置某会话聊天背景设置完成后，返回到聊天界面，马上显示新的背景
 */
-(void)backToTalkSession;
@end
