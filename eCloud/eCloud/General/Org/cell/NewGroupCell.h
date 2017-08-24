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
@interface NewGroupCell : UITableViewCell

/**
 功能描述
 适合转发选择联系人界面的初始化方法

*/
- (id)initForTransferWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


/**
 初始化群组名称

 @param conv 包含会话所有信息的对象
 */
- (void)configCell:(Conversation *)conv;

//+ (void)addCommonObject:(UITableViewCell *)cell;

@end
