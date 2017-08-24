//
//  TextMsgCell.m
//  eCloud
//
//  Created by 风影 on 15/9/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "TextMsgCell.h"
#import "StringUtil.h"
#define KSCREENSIZE ([UIScreen mainScreen].bounds.size)

#define TEXT_MESSAGE_X 12
#define TEXT_MESSAGE_Y 55
#define TEXT_MESSAGE_HEIGHT 42

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 117

#define TEXT_MESSAGE_FONT 15

@implementation TextMsgCell

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        self.textMessage = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(TEXT_MESSAGE_X, TEXT_MESSAGE_Y, KSCREENSIZE.width - TEXT_MESSAGE_X*2, TEXT_MESSAGE_HEIGHT)];
        
        self.textMessage.font = [UIFont systemFontOfSize:TEXT_MESSAGE_FONT];
        self.textMessage.bundle = [StringUtil getBundle];
        
        self.textMessage.tag = 105;
//        self.textMessage.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textMessage.numberOfLines = 2;

        // 不支持话题和@用户、超链接和号码
        self.textMessage.isNeedAtAndPoundSign = NO;
        self.textMessage.disableThreeCommon = YES;
        
        self.textMessage.customEmojiRegex = @"\\[/[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        self.textMessage.customEmojiPlistName = @"expressionImage_custom.plist";

        [self addSubview:self.textMessage];
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
