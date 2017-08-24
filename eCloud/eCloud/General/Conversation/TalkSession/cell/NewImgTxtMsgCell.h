//
//  NewImgTxtMsgCell.h
//  eCloud
// 新的 图文类型 的消息 cell 包括 一个父View 一个标题 一个图片(没有图片时显示默认图片，有则显示下载好的图片) 一段描述文字。而且可以点击打开某个链接
//  Created by shisuping on 16/12/27.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "ParentMsgCell.h"
@class ConvRecord;

@interface NewImgTxtMsgCell : ParentMsgCell

- (void)configureCell:(ConvRecord *)_convRecord;

@end
