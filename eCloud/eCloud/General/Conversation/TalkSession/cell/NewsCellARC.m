//
//  NewsCellARC.m
//  eCloud
//
//  Created by Alex-L on 2017/6/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "NewsCellARC.h"
#import "RobotUtil.h"
#import "SystemMsgModelArc.h"
#import "RobotFileUtil.h"
#import "talkSessionUtil.h"

@implementation NewsCellARC

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        UIView *parentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAX_WIDTH, new_imgtxt_title_height + new_imgtxt_img_size)];
        parentView.tag = new_imgtxt_parent_view_tag;
        [contentView addSubview:parentView];
        
        //        增加title
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(17, 3, MAX_WIDTH-7, new_imgtxt_title_height)];
        titleLabel.tag = new_imgtxt_title_label_tag;
        titleLabel.numberOfLines = 0;
        [titleLabel setFont:[UIFont systemFontOfSize:imgtxt_title_font_size]];
        [parentView addSubview:titleLabel];
        
        //        增加UIImageView
        UIImageView *picView = [[UIImageView alloc]initWithFrame:CGRectMake(MAX_WIDTH-new_imgtxt_img_size+15, new_imgtxt_title_height+5, new_imgtxt_img_size, new_imgtxt_img_size)];
        picView.tag = new_imgtxt_img_view_tag;
        [parentView addSubview:picView];
        
        //        增加描述lablel
        UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, new_imgtxt_title_height+5, titleLabel.frame.size.width - new_imgtxt_img_size+3, new_imgtxt_img_size)];
        
        desLabel.tag = new_imgtxt_description_lable_tag;
        desLabel.numberOfLines = 3;
        [desLabel setFont:[UIFont systemFontOfSize:imgtxt_description_font_size]];
        [desLabel setTextColor:imgtxt_description_font_color];
        [parentView addSubview:desLabel];
        
        
//        picView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
//        titleLabel.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
//        desLabel.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
    }
    return self;
}

- (void)configureCell:(ConvRecord *)_convRecord
{
    if (_convRecord.systemMsgModel)
    {
        UIView *parentView = [self.contentView viewWithTag:new_imgtxt_parent_view_tag];
        parentView.hidden = NO;
        
        
        NSString *filePath = [StringUtil getRobotFilePath];
        NSString *fileName = [RobotUtil getDownloadFileNameByFileUrl:_convRecord.systemMsgModel.msgBody];
        NSString *picPath = [filePath stringByAppendingPathComponent:fileName];
        
        UIImage *_image = nil;
        if (picPath.length) {
            _image = [UIImage imageWithContentsOfFile:picPath];
        }
        if (!_image) {
            _image = [StringUtil getImageByResName:@"default_pic.png"];
            
            [[RobotFileUtil getUtil]setDownloadPropertyOfRecord:_convRecord];
            
            if (!_convRecord.isDownLoading) {
                [[RobotFileUtil getUtil]downloadRobotFile1:_convRecord];
            }
        }
        
        
        UIImageView *picView = [self.contentView viewWithTag:new_imgtxt_img_view_tag];
        picView.hidden = NO;
        picView.image = _image;
        
        
        UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:new_imgtxt_title_label_tag];
        titleLabel.text = _convRecord.systemMsgModel.title;
        titleLabel.hidden = NO;
        
        
        CGSize size = [talkSessionUtil getSizeOfTextMsg:_convRecord.systemMsgModel.title withFont:[UIFont systemFontOfSize:imgtxt_title_font_size] withMaxWidth:MAX_WIDTH];
        
        if (size.height > 21)
        {
            CGFloat adjustValue = 18;
            
            UIImageView *picView = [parentView viewWithTag:new_imgtxt_img_view_tag];
            picView.frame = CGRectMake(MAX_WIDTH-new_imgtxt_img_size+15, new_imgtxt_title_height+5+adjustValue, new_imgtxt_img_size, new_imgtxt_img_size);
            
            UIView *parentView = [self.contentView viewWithTag:new_imgtxt_parent_view_tag];
            UILabel *titleLabel = [parentView viewWithTag:new_imgtxt_title_label_tag];
            titleLabel.frame = CGRectMake(17, 3, MAX_WIDTH-7, new_imgtxt_title_height+adjustValue);
            
            UILabel *desLabel = [parentView viewWithTag:new_imgtxt_description_lable_tag];
            desLabel.frame = CGRectMake(15, new_imgtxt_title_height+5+adjustValue, titleLabel.frame.size.width - new_imgtxt_img_size+3, new_imgtxt_img_size);
        }
        else
        {
            UIView *parentView = [self.contentView viewWithTag:new_imgtxt_parent_view_tag];
            UILabel *titleLabel = [parentView viewWithTag:new_imgtxt_title_label_tag];
            titleLabel.frame = CGRectMake(17, 3, MAX_WIDTH-7, new_imgtxt_title_height);
            
            UIImageView *picView = [parentView viewWithTag:new_imgtxt_img_view_tag];
            picView.frame = CGRectMake(MAX_WIDTH-new_imgtxt_img_size+15, new_imgtxt_title_height+5, new_imgtxt_img_size, new_imgtxt_img_size);
            
            UILabel *desLabel = [parentView viewWithTag:new_imgtxt_description_lable_tag];
            desLabel.frame = CGRectMake(15, new_imgtxt_title_height+5, titleLabel.frame.size.width - new_imgtxt_img_size+3, new_imgtxt_img_size);
        }
        
        
        UILabel *desLabel = (UILabel *)[self.contentView viewWithTag:new_imgtxt_description_lable_tag];
        desLabel.text = _convRecord.systemMsgModel.descriptionStr;
        desLabel.hidden = NO;
        
    }
}

@end
