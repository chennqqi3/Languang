//
//  GroupCell.h
//  eCloud
//
//  Created by shisuping on 14-9-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#define logo_view_tag (101)
#define group_name_tag (102)
#define GroupCellHeight 60
@class Conversation;
@interface GroupCell : UITableViewCell

- (void)configCell:(Conversation *)conv;

+ (void)addCommonObject:(UITableViewCell *)cell;

@end
