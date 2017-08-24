//
//  BGYMyTimelineCellARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYMyTimelineCellARC.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface BGYMyTimelineCellARC ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *imagesView;

@end

@implementation BGYMyTimelineCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 120, 40)];
        [self.timeLabel setFont:[UIFont systemFontOfSize:18]];
        [self.timeLabel setTextColor:[UIColor colorWithWhite:0.12 alpha:1]];
        [self.contentView addSubview:self.timeLabel];
        
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, SCREEN_WIDTH-90-10, 30)];
        self.contentLabel.numberOfLines = 3;
        [self.contentView addSubview:self.contentLabel];
    }
    
    return self;
}

- (void)setModel:(BGYTimelineModelARC *)model
{
    _model = model;
    
    self.timeLabel.attributedText = [self getAttributedString:_model.time];
    
    if (_model && _model.images.count > 0)
    {
        
    }
    else
    {
        self.contentLabel.text = _model.contentStr;
        [self.contentLabel sizeToFit];
    }
}

- (NSAttributedString *)getAttributedString:(NSString *)str
{
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:str];
    
    //设置字体大小
    [richText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:32.0] range:NSMakeRange(0, 2)];
    
    return richText;
}

@end
