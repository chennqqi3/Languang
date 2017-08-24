//
//  HyperlinkCell.h
//  eCloud
//  扩展分享时，可以分享一个网页链接类型的消息，目前没有正式使用
//  Created by Alex L on 16/8/15.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentMsgCell.h"

@interface HyperlinkCell : ParentMsgCell

/** 链接标题 */
@property (nonatomic, copy) NSString *title;

/** 链接url地址 */
@property (nonatomic, copy) NSString *URL;

@end
