//
//  DisplayPicViewController.h
//  eCloud
//  在聊天界面点击查看大图，右下侧有个按钮可以查看当前会话收到的所有图片的缩略图界面
//  Created by yanlei on 15/11/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

@interface DisplayPicViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,FGalleryViewControllerDelegate>{
}

/** 会话id */
@property(nonatomic,retain) NSString *convId;

/** 用户选择的图片index */
@property(nonatomic,assign) int selectedIndex;

/**
 转发提示
 */
- (void)showTransferTips;

@end
