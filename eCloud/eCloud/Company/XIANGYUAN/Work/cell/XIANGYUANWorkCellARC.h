//
//  XIANGYUANWorkCellARC.h
//  eCloud
//
//  Created by Ji on 17/5/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROW_HEIGHT (55.0)

@class APPListModel;

@interface XIANGYUANWorkCellARC : UITableViewCell

@property(nonatomic,strong)UILabel *_label;

- (void)configCellWithDataModel:(APPListModel*)model;

@end
