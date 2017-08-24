//
//  GroupCell.m
//  eCloud
//
//  Created by shisuping on 14-9-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NewGroupCell.h"
#import "eCloudDefine.h"
#import "Conversation.h"
#import "UserDisplayUtil.h"
#import "QueryResultCell.h"
#import "UIAdapterUtil.h"
#import "OrgSizeUtil.h"

//只有群聊时显示，单聊时不显示
#define group_logo_parentview_tag (107)
//子view直接的间隔定义
#define group_logo_subview_spacing (1.5)

@implementation NewGroupCell
{
//    是否有右向箭头
    BOOL hasRightArrow;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        hasRightArrow = YES;
        [self addGroupCellViewWithLogoX:[OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent]];// []];
    }
    
    return self;
}

//适合转发选择联系人界面的初始化方法
- (id)initForTransferWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        hasRightArrow = NO;
        [self addGroupCellViewWithLogoX:10.0];
    }
    
    return self;
}

- (void)addGroupCellViewWithLogoX:(float)logoX
{
    //群组头像
    UIImageView *logoView = [UserDisplayUtil getUserLogoView];
    logoView.tag = logo_view_tag;

    CGRect _frame = logoView.frame;
    _frame.origin.x = logoX;
    _frame.origin.y = (GroupCellHeight - logoView.frame.size.height) / 2;
    
    
    logoView.frame = _frame;
    logoView.contentMode = UIViewContentModeScaleAspectFit;
//    目前修改为显示合成头像
    [QueryResultCell initGroupLogoView:logoView];
    [self.contentView addSubview:logoView];
    
    //群组名称
    float x = logoView.frame.origin.x + logoView.frame.size.width + 10;
    float y = 0;
    float w = [UIAdapterUtil getTableCellContentWidth] - x - 10;
    if (hasRightArrow) {
        w = w - RIGHT_ROW_SIZE;
    }
    float h = GroupCellHeight;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
    nameLabel.tag = group_name_tag;
    nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:nameLabel];
    [nameLabel release];
    
//    nameLabel.backgroundColor = [UIColor redColor];
}


- (void)configCell:(Conversation *)conv
{
    //群组头像
    UIImageView *iconview = (UIImageView *)[self.contentView viewWithTag:logo_view_tag];
    [UserDisplayUtil setUserLogoView:iconview andConversation:conv];
//    修改为显示合成头像
    //    如果显示合成头像，就不用下面的操作
    if (!conv.displayMergeLogo)
    {
        [QueryResultCell configGroupLogoView:conv andIconView:iconview];
    }
    
    //群组名称
    UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:group_name_tag];
    nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
//	nameLabel.text = conv.conv_title;
    NSString *nameStr = @"";
    if (conv.conv_type == mutiableType) {
        nameStr = [NSString stringWithFormat:@"%@(%d)",conv.conv_title,conv.totalEmpCount];
    }
    else
    {
        nameStr = conv.conv_title;
    }
    nameLabel.text = nameStr;
//    CGRect _frame = nameLabel.frame;
//    float nameWidth = [UIAdapterUtil getTableCellContentWidth] - nameLabel.frame.size.width - nameLabel.frame.origin.x- RIGHT_ROW_SIZE;// - 20-40.0;
//    _frame.size.width = nameWidth;
//    nameLabel.frame = _frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
