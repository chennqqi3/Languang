//
//  LongTextMsgCell.m
//  eCloud
//
//  Created by Alex L on 15/10/21.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "LongTextMsgCell.h"
#import "StringUtil.h"
#define KSCREENSIZE ([UIScreen mainScreen].bounds.size)

#define TEXT_MESSAGE_X 12
#define TEXT_MESSAGE_Y 55
#define TEXT_MESSAGE_HEIGHT 42

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 117

#define TEXT_MESSAGE_FONT 15

@implementation LongTextMsgCell

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
        self.textMessage.tag = 105;
        self.textMessage.font = [UIFont systemFontOfSize:TEXT_MESSAGE_FONT];
//        self.textMessage.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textMessage.numberOfLines = 2;
        [self addSubview:self.textMessage];
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
