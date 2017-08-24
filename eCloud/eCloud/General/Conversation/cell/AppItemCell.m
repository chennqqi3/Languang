//
//  AppItemCell.m
//  eCloud
//
//  Created by shisuping on 16/8/16.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "AppItemCell.h"
#import "NewMsgNumberUtil.h"

#import "QueryResultCell.h"
#import "FontUtil.h"
#import "CustomMyCell.h"

#import "APPListModel.h"

#import "eCloudDefine.h"
#import "UserDisplayUtil.h"

#define app_logo_tag (101)
#define app_name_tag (102)

//一个 subview,新消息条数就是放在这个子view当中的
#define new_msg_number_parent_view_tag (108)

@implementation AppItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.accessoryType = UITableViewCellAccessoryNone;
        
//        增加一个头像
        float logoHeight = chatview_logo_size;
        CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
        float logoWidth = (_size.width * logoHeight) / _size.height;
        
        float logoX = 10;
        float logoY = (conv_row_height - logoHeight) * 0.5;
        
        UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(logoX,logoY,logoWidth,logoHeight)];
        
        logoView.tag = app_logo_tag;
        
        [self.contentView addSubview:logoView];
        
        
//        增加一个lable
        float nameX = logoX + logoWidth + 10;
        float nameY = 0;
        float nameWidth = [UIAdapterUtil getTableCellContentWidth] - 20 - logoWidth - 10 - 30;
        float nameHeight = conv_row_height;
        
        
        UILabel *namelable=[[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, nameWidth, nameHeight)]autorelease];
        namelable.tag=app_name_tag;
        
        namelable.font= [FontUtil getTitleFontOfConvList];
        namelable.backgroundColor=[UIColor clearColor];
        //        [self.contentView addSubview:namelable];
        [self.contentView addSubview:namelable];
        
//        增加一个未读数view
        
        //        未读消息数量
        // 新消息 的 高度 和 详细信息的高度一致
        UIView *newMsgNumberParentView = [[UIView alloc]initWithFrame:CGRectZero];
        newMsgNumberParentView.tag = new_msg_number_parent_view_tag;
        [self.contentView addSubview:newMsgNumberParentView];
        [newMsgNumberParentView release];
        
        [NewMsgNumberUtil addNewMsgNumberView:newMsgNumberParentView];
    }
    return self;
}

- (void)configCell:(APPListModel *)model
{
    UIImageView *logoView = [self.contentView viewWithTag:app_logo_tag];
    logoView.image = [CustomMyCell getAppLogo:model];
    
    UILabel *nameLabel = [self.contentView viewWithTag:app_name_tag];
    nameLabel.text = model.appname;
    
    //    新消息数量
    UIView *newMsgNumberParentView = [self.contentView viewWithTag:new_msg_number_parent_view_tag];
    
    [NewMsgNumberUtil displayNewMsgNumber:newMsgNumberParentView andNewMsgNumber:model.unread];
    
    if (model.unread) {
        //        宽度已经ok了 现在 设置下 显示的位置
        UIImageView *newMsgBg = (UIImageView *) [newMsgNumberParentView viewWithTag:new_msg_number_bg_tag];
        
        //        NSLog(@"%s,new msg bg frame is %@",__FUNCTION__,NSStringFromCGRect(newMsgBg.frame));
        
        float newMsgX = [UIAdapterUtil getTableCellContentWidth] - 10 - newMsgBg.frame.size.width;
        
        CGRect _frame = newMsgNumberParentView.frame;
        _frame.origin.x = newMsgX;
        _frame.origin.y = (conv_row_height - newMsgBg.frame.size.height) * 0.5;
        _frame.size.height = newMsgBg.frame.size.height;
        _frame.size.width = newMsgBg.frame.size.width;
        newMsgNumberParentView.frame = _frame;
        
        //        NSLog(@"%s new msg number frame is %@",__FUNCTION__,NSStringFromCGRect(_frame));
    }
}
@end
