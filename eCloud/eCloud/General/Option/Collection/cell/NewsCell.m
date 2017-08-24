//
//  NewsCell.m
//  eCloud
//
//  Created by Dave William on 2017/8/8.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "NewsCell.h"
#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)


#define PICTURECELL_PICTURE_X 12
#define PICTURECELL_PICTURE_Y 55
#define PICTURECELL_PICTURE_HEIGHT 45
#define PICTURECELL_PICTURE_WIDTH 45
#define LOCATIONIMAGEHEIGHT 45

#define TITLELABEL_X 67
#define TITLELABEL_Y 15
#define TITLELABEL_HEIHGT 42

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 144
#define ADDRESSFONT 15
#define VIEWHEIGHT 69
#define LOGOIMAGE_X 12

@implementation NewsCell

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
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(PICTURECELL_PICTURE_X, PICTURECELL_PICTURE_Y, KSCREEN_SIZE.width-PICTURECELL_PICTURE_X*2, VIEWHEIGHT)];
        view.tag = 703;
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1/1.0].CGColor;
        view.backgroundColor =   [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1/1.0];
        view.layer.cornerRadius = 0.5;
        [self addSubview:view];
        
        self.logoImage = [[UIImageView alloc]initWithFrame:CGRectMake(LOGOIMAGE_X, LOGOIMAGE_X, PICTURECELL_PICTURE_WIDTH, LOCATIONIMAGEHEIGHT)];
        self.logoImage.tag = 701;
        self.logoImage.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:self.logoImage];

       self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(TITLELABEL_X, TITLELABEL_Y, KSCREEN_SIZE.width-PICTURECELL_PICTURE_X*2-TITLELABEL_X-PICTURECELL_PICTURE_X, TITLELABEL_HEIHGT)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.tag = 702;
        self.titleLabel.font = [UIFont systemFontOfSize:ADDRESSFONT];
        [view addSubview:self.titleLabel];
        

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
