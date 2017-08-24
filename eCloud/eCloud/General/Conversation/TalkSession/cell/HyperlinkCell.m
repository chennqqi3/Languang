//
//  HyperlinkCell.m
//  eCloud
//
//  Created by Alex L on 16/8/15.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "HyperlinkCell.h"

@interface HyperlinkCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *urlLabel;

@end

@implementation HyperlinkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 52, 60, 60)];
        iconView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self addSubview:iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 50, self.frame.size.width-70, 30)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [self addSubview:self.titleLabel];
        
        self.urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 50 + 30, self.frame.size.width-70, 40)];
        self.urlLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        [self.urlLabel setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:self.urlLabel];
    }
    return self;
}

#pragma mark - 重写set方法
- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = _title;
}

- (void)setURL:(NSString *)URL
{
    _URL = URL;
    
    self.urlLabel.text = _URL;
}

@end
