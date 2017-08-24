//
//  ReceiptMsgDetailHeaderView.h
//  OpenCtx2017
//  华夏要求显示 回执已读情况时，未读和已读分离显示，所以已读header上增加一个uiview 
//  Created by shisuping on 17/6/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 分离view的高度 */
#define SEPERATE_VIEW_HEIGHT (20.0)

@interface ReceiptMsgDetailHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *headerLabel;

@end
