//
//  AdvSearchFileCell.m
//  eCloud
//
//  Created by shisuping on 17/6/29.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "AdvSearchFileCell.h"
#import "FontUtil.h"
#import "ConvRecord.h"
#import "StringUtil.h"
#import "UserInterfaceUtil.h"
#import "IOSSystemDefine.h"
#import "talkSessionUtil.h"
#import "LogUtil.h"

@interface AdvSearchFileCell ()

/** 父view */
@property (nonatomic,retain) UIView *parentView;

/** 文件类型图标 */
@property (nonatomic,retain) UIImageView *fileTypeView;
/** 文件名称 */
@property (nonatomic,retain) UILabel *fileNameView;

/** 来自哪里 */
@property (nonatomic,retain) UILabel *senderView;
@end

#define file_type_image_size (46.0)

@implementation AdvSearchFileCell

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
    self.fileNameView = nil;
    self.fileTypeView = nil;
    self.senderView = nil;
    self.progressView = nil;
    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    if (self) {
        
        float x = 10;
        float y = 0;
        float width = SCREEN_WIDTH - 2 * x;
        float height = conv_row_height;
        
        /** 父view */
        self.parentView = [[[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)]autorelease];
        [self.contentView addSubview:_parentView];
        
        /** 文件类型image */
        x = 0;
        y = (_parentView.frame.size.height - file_type_image_size) * 0.5;
        self.fileTypeView = [[[UIImageView alloc]initWithFrame:CGRectMake(x, y, file_type_image_size, file_type_image_size)]autorelease];
        [_parentView addSubview:self.fileTypeView];
        
        /** 文件名称 */
        x = self.fileTypeView.frame.origin.x + file_type_image_size + 10;
        y = self.fileTypeView.frame.origin.y;
        width = _parentView.frame.size.width - x - 10;
        height = file_type_image_size * 0.5;
        
        self.fileNameView = [[[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)]autorelease];
        self.fileNameView.font = [FontUtil getTitleFontOfConvList];
        self.fileNameView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        self.fileNameView.backgroundColor=[UIColor clearColor];
        [_parentView addSubview:self.fileNameView];
        
        /** 发送人 */
        x = self.fileNameView.frame.origin.x;
        y = self.fileNameView.frame.origin.y + self.fileNameView.frame.size.height + 5;
        width = self.fileNameView.frame.size.width;
        height = self.fileNameView.frame.size.height - 5;
        
        self.senderView = [[[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)]autorelease];
        self.senderView.backgroundColor = [UIColor clearColor];
        self.senderView.font = [FontUtil getLastMsgFontOfConvList];
        self.senderView.textColor = [UIColor darkGrayColor];

        [_parentView addSubview:self.senderView];
        
        /** 进度条 */
        
        x = self.senderView.frame.origin.x;
        y = self.senderView.frame.origin.y + self.senderView.frame.size.height;
        width = self.senderView.frame.size.width;
        height = 30;
        
        self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(x,y,width,height)]autorelease];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progress = 0.0;
        _progressView.progressTintColor = [UIColor colorWithRed:26.0/255 green:199.0/255 blue:6.0/255 alpha:1.0];
        _progressView.trackTintColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
        [_parentView addSubview:self.progressView];
        [talkSessionUtil hideProgressView:self.progressView];
        
    }
    return self;
}

/** 显示 查询结果 文件  */
- (void)configCellWithConvRecord:(ConvRecord *)_convRecord{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    self.fileTypeView.image = [StringUtil getFileDefaultImage:_convRecord.file_name];
    self.fileNameView.text = _convRecord.file_name;
    self.senderView.text = [NSString stringWithFormat:@"%@:%@",[StringUtil getLocalizableString:@"key_adv_search_from"],_convRecord.emp_name];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 0810-0813
-(void)layoutSubviews{
    [super layoutSubviews];
}

@end
