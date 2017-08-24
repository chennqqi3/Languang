//
//  BGYNewsCellARC.m
//  eCloud
//
//  Created by Alex-L on 2017/7/13.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYNewsCellARC.h"
#import "StringUtil.h"

@interface BGYNewsCellARC ()

@property (retain, nonatomic) IBOutlet UIImageView *timeIcon;
@property (retain, nonatomic) IBOutlet UIImageView *eyeIcon;
@property (retain, nonatomic) IBOutlet UIImageView *newsImageView;

@property (retain, nonatomic) IBOutlet UILabel *lookNumber;
@property (retain, nonatomic) IBOutlet UILabel *newsLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation BGYNewsCellARC

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timeIcon.image = [StringUtil getImageByResName:@"icon_time"];
    self.eyeIcon.image = [StringUtil getImageByResName:@"view_details"];
    
    self.newsLabel.text = @"碧桂园集团总裁莫斌莅临合肥区域视察指导工作";
    [self.newsLabel sizeToFit];
}

@end
