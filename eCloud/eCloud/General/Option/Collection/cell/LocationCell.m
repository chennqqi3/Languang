//
//  LocationCell.m
//  eCloud
//
//  Created by Dave William on 2017/8/8.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LocationCell.h"
#import "IrregularView.h"
#import "CustomLabel.h"
#import "StringUtil.h"

#define PICTURECELL_PICTURE_X 12
#define PICTURECELL_PICTURE_Y 55
#define PICTURECELL_PICTURE_HEIGHT 37
#define PICTURECELL_PICTURE_WIDTH 215
#define LOCATIONIMAGEHEIGHT 126

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 237.5
#define ADDRESSFONT 15


@implementation LocationCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self addCommonView];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(PICTURECELL_PICTURE_X, PICTURECELL_PICTURE_Y, PICTURECELL_PICTURE_WIDTH, PICTURECELL_PICTURE_HEIGHT+LOCATIONIMAGEHEIGHT)];
        view.tag = 603;
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
        view.backgroundColor =   [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
        view.layer.cornerRadius = 0.5;
        [self addSubview:view];
        
        
        self.address = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PICTURECELL_PICTURE_WIDTH, PICTURECELL_PICTURE_HEIGHT)];
        self.address.textColor = [UIColor blackColor];
        self.address.tag = 602;
        self.address.font = [UIFont systemFontOfSize:ADDRESSFONT];
        self.address.backgroundColor = [UIColor whiteColor];
        [view addSubview:self.address];
        
        self.locationImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, PICTURECELL_PICTURE_HEIGHT, PICTURECELL_PICTURE_WIDTH, LOCATIONIMAGEHEIGHT)];
        self.locationImage.tag = 601;
        self.locationImage.contentMode = UIViewContentModeScaleToFill;
        [view addSubview:self.locationImage];
        
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
