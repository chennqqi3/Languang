//
//  XIANGYUANWorkCellARC.m
//  eCloud
//
//  Created by Ji on 17/5/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANWorkCellARC.h"
#import "StringUtil.h"

#import "NewMsgNumberUtil.h"
#import "APPListModel.h"
#import "APPUtil.h"

#define IMAGEVIEW_TAG (100)
#define LABEL_TAG (101)
#define NEW_MSG_NUMBER_PARENT_VIEW_TAG (102)

#define IMAGEVIEW_WIDTH (34)
#define IMAGEVIEW_HEIGHT (34)

#define LABEL_FONT (17.0)

#define ITEM_SPACE (17.0)

@implementation XIANGYUANWorkCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    XIANGYUANWorkCellARC *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (cell) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        float x = ITEM_SPACE;
        float y = (ROW_HEIGHT - IMAGEVIEW_HEIGHT) / 2;
        float w = IMAGEVIEW_WIDTH;
        float h = IMAGEVIEW_HEIGHT;
        
        //        图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        imageView.tag = IMAGEVIEW_TAG;
        [cell.contentView addSubview:imageView];
        
        x = imageView.frame.origin.x + imageView.frame.size.width + ITEM_SPACE;
        y = 0;
        w = 0;
        h = ROW_HEIGHT;
        
        //        文本
        self._label = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
        self._label.tag = LABEL_TAG;
        self._label.font = [UIFont systemFontOfSize:LABEL_FONT];
        [cell.contentView addSubview:self._label];
      
        //        未读消息数
        UIView *newMsgNumberParentView = [[UIView alloc]init];
        newMsgNumberParentView.tag = NEW_MSG_NUMBER_PARENT_VIEW_TAG;
        [cell.contentView addSubview:newMsgNumberParentView];

        [NewMsgNumberUtil addNewMsgNumberView:newMsgNumberParentView];
    }
    
    return cell;
}

- (void)configCellWithDataModel:(APPListModel*)appModel
{
    UIImageView *_imageView = (UIImageView *)[self.contentView viewWithTag:IMAGEVIEW_TAG];
    // 轻应用图标要通过判断后，再决定加载
    
    //    优先显示根据服务器配置下载下来的图片
    UIImage *_image = [APPUtil getMyAPPLogo:appModel];
    
    //如果不存在 显示默认的和此应用对应的本地的图片
    if (!_image) {
        if(appModel.appicon){
            // 若后台没有给logopath，加载初始化图片
            _image = [StringUtil getImageByResName:appModel.appicon];
        }
    }
    //否则显示默认的轻应用的图片
    if (!_image) {
        _image = [StringUtil getImageByResName:@"app_default_icon_html5.png"];
    }
    
    _imageView.image = _image;
    
    UILabel *_label = (UILabel *)[self.contentView viewWithTag:LABEL_TAG];
    _label.text = appModel.appname;
    
    CGSize _size = [_label.text sizeWithFont:[UIFont systemFontOfSize:LABEL_FONT]];
    
    CGRect _frame = _label.frame;
    _frame.size.width = _size.width;
    _label.frame = _frame;
    
    UIView *newMsgNumberParentView = [self.contentView viewWithTag:NEW_MSG_NUMBER_PARENT_VIEW_TAG];
    [NewMsgNumberUtil displayNewMsgNumber:newMsgNumberParentView andNewMsgNumber:appModel.unread];
    
    if (appModel.unread != 0) {
        //        宽度已经ok了 现在 设置下 显示的位置
        UIImageView *newMsgBg = (UIImageView *) [newMsgNumberParentView viewWithTag:new_msg_number_bg_tag];
        
        CGRect _frame = newMsgNumberParentView.frame;
        _frame.origin.x = _label.frame.origin.x + _label.frame.size.width + ITEM_SPACE;
        _frame.origin.y = (ROW_HEIGHT - newMsgBg.frame.size.height)/2;
        _frame.size = newMsgBg.frame.size;
        newMsgNumberParentView.frame = _frame;
    }
    
}

@end
