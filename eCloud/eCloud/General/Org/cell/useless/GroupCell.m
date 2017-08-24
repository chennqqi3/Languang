//
//  GroupCell.m
//  eCloud
//
//  Created by shisuping on 14-9-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "GroupCell.h"
#import "eCloudDefine.h"
#import "Conversation.h"
#import "StringUtil.h"

@implementation GroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [GroupCell addCommonObject:self];
    }
    return self;
}

- (void)configCell:(Conversation *)conv
{
//    float indentPoints = itemObject.type_level * self.indentationWidth;
    
    UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:group_name_tag];
	nameLabel.text = conv.conv_title;
    
    CGRect _frame = nameLabel.frame;
    float nameWidth = self.frame.size.width - chatview_logo_size - 20;
    
    _frame.size.width = nameWidth;
    nameLabel.frame = _frame;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (void)addCommonObject:(UITableViewCell *)cell
{
    //        群组头像
    UIImageView *logoView = [[UIImageView alloc]initWithImage:[StringUtil getImageByResName:@"Group_ios.png"]];
    logoView.tag = logo_view_tag;
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    float x = 10;
    float y = (GroupCellHeight - chatview_logo_size) / 2;
//    float w = chatview_logo_size;
    float w = chatview_logo_size;//*0.75;
//    float h = w;
    float h = chatview_logo_size;
    
    logoView.frame = CGRectMake(x, y, w, h);
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:logoView];
    [logoView release];
    
    //        群组名称
    x = logoView.frame.origin.x + logoView.frame.size.width + 10;
    y = 0;
    w = 0;
    h = GroupCellHeight;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
    nameLabel.tag = group_name_tag;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [cell.contentView addSubview:nameLabel];
    [nameLabel release];
}
@end
