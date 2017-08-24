//
//  ImgtxtMsgSubCell.h
//  eCloud
//
//  Created by yanlei on 15/11/8.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgtxtMsgSubCell : UITableViewCell

// 图文标题
@property (nonatomic,retain) UILabel *titleLabel;
// 图文图片
@property (nonatomic,retain) UIImageView *picUrlImageView;
// 图文描述
@property (nonatomic,retain) UILabel *descriptionLabel;
// 图文分割线
@property (nonatomic,retain) UIImageView *separatorLine;
@end
