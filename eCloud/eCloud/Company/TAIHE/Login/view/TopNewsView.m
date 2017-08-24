//
//  TopNewsView.m
//  WanDaOAP3_IM
//
//  Created by SF on 16/4/12.
//  Copyright © 2016年 Wanda. All rights reserved.
//

#import "TopNewsView.h"
#import "UIImageView+WebCache.h"

@interface TopNewsView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end

@implementation TopNewsView

+ (TopNewsView *)loadFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil] objectAtIndex:0];
}

- (void)awakeFromNib
{
    self.layer.cornerRadius = 25.f;
}

- (void)displayWithModel:(OANewsEntity *)entity
{
    [_imageview sd_setImageWithURL:[NSURL URLWithString:entity.thumb] placeholderImage:[UIImage imageNamed:@"top_news_bg"]];
//    [_imageview setImage:[UIImage imageNamed:@"top_news_bg"]];
    _titleLabel.text = entity.title;
    _inputTimeLabel.text = entity.inputtime;
    _descriptionLabel.text = entity.newsdescription;
}

@end
