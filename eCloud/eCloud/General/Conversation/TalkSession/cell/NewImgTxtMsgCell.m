//
//  NewImgTxtMsgCell.m
//  eCloud
//
//  Created by shisuping on 16/12/27.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "NewImgTxtMsgCell.h"
#import "talkSessionUtil.h"
#import "ConvRecord.h"
#import "VerticallyAlignedLabel.h"
#import "RobotResponseModel.h"
#import "RobotUtil.h"
#import "RobotFileUtil.h"


@implementation NewImgTxtMsgCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
//        父view
        UIView *parentView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, MAX_WIDTH, new_imgtxt_title_height + new_imgtxt_img_size)]autorelease];
        
        parentView.tag = new_imgtxt_parent_view_tag;
        [contentView addSubview:parentView];
        
//        增加title
        UILabel *titleLabel = [[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(0, 0, MAX_WIDTH, new_imgtxt_title_height)]autorelease];
        ((VerticallyAlignedLabel *)titleLabel).verticalAlignment = VerticalAlignmentTop;
        titleLabel.tag = new_imgtxt_title_label_tag;
        [titleLabel setFont:[UIFont systemFontOfSize:imgtxt_title_font_size]];
        [parentView addSubview:titleLabel];
        
//        增加UIImageView
        UIImageView *picView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, new_imgtxt_title_height, new_imgtxt_img_size, new_imgtxt_img_size)]autorelease];
        picView.tag = new_imgtxt_img_view_tag;
        [parentView addSubview:picView];
        
//        增加描述lablel
        UILabel *desLabel = [[[VerticallyAlignedLabel alloc]initWithFrame:CGRectMake(new_imgtxt_img_size + 5, new_imgtxt_title_height, titleLabel.frame.size.width - new_imgtxt_img_size - 5, new_imgtxt_img_size)]autorelease];
        ((VerticallyAlignedLabel *)desLabel).verticalAlignment = VerticalAlignmentTop;

        desLabel.tag = new_imgtxt_description_lable_tag;
        desLabel.numberOfLines = 3;
        [desLabel setFont:[UIFont systemFontOfSize:imgtxt_description_font_size]];
        [desLabel setTextColor:imgtxt_description_font_color];
        [parentView addSubview:desLabel];
        
    }
    return self;
}

- (void)configureCell:(ConvRecord *)_convRecord{
    if (_convRecord.isRobotImgTxtMsg){
        NSDictionary *dic = _convRecord.robotModel.imgtxtArray[0];

        UIImageView *picView = [self.contentView viewWithTag:new_imgtxt_img_view_tag];
//        如果没下载就使用默认，否则使用下载好的
        picView.hidden = NO;
        
        
        NSString *picUrl = dic[@"PicUrl"];
        
        NSString *picPath = [RobotUtil getDownloadFilePathWithConvRecord:_convRecord];
        
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
        
        picView.image = _image;
        
        UIView *parentView = [self.contentView viewWithTag:new_imgtxt_parent_view_tag];
        parentView.hidden = NO;
        
        UILabel *titleLabel = (UILabel *)[self.contentView viewWithTag:new_imgtxt_title_label_tag];
        titleLabel.text = dic[@"Title"];
        titleLabel.hidden = NO;
        
        UILabel *desLabel = (UILabel *)[self.contentView viewWithTag:new_imgtxt_description_lable_tag];
        desLabel.text = dic[@"Description"];
        desLabel.hidden = NO;

    }
}

@end
