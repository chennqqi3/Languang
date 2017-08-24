//
//  AppItemCell.h
//  eCloud
//
//  Created by shisuping on 16/8/16.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APPListModel;

@interface AppItemCell : UITableViewCell

- (void)configCell:(APPListModel *)model;

@end
