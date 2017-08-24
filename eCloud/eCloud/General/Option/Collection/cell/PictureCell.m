//
//  PictureCell.m
//  eCloud
//
//  Created by Alex L on 15/10/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "PictureCell.h"

#define PICTURECELL_PICTURE_X 12
#define PICTURECELL_PICTURE_Y 55
#define PICTURECELL_PICTURE_HEIGHT 120
#define PICTURECELL_PICTURE_WIDTH 190

#define EDITING_BUTTON_HEIGHT 20
#define CELL_HEIGHT 180

@implementation PictureCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self addCommonView];
        
        self.picture = [[UIImageView alloc] init];
        self.picture.tag = 105;
        
        self.picture.frame = CGRectMake(PICTURECELL_PICTURE_X, PICTURECELL_PICTURE_Y, PICTURECELL_PICTURE_WIDTH, PICTURECELL_PICTURE_HEIGHT);
//        self.picture.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.picture];
        
        // 调整edtingBtn的位置
        CGRect rect = self.editingBtn.frame;
        rect.origin.y = CELL_HEIGHT/2 - EDITING_BUTTON_HEIGHT/2;
        self.editingBtn.frame = rect;
    }
    
    return self;
}

@end
