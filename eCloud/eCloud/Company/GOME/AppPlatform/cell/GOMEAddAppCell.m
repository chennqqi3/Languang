//
//  GOMEAddAppCell.m
//  eCloud
//
//  Created by Alex L on 17/2/10.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "GOMEAddAppCell.h"
#import "CustomMyCell.h"
#import "UIAdapterUtil.h"
#import "APPPlatformDOA.h"
#import "ImageUtil.h"

@interface GOMEAddAppCell ()

@property (retain, nonatomic) IBOutlet UIImageView *appIcon;

@property (retain, nonatomic) IBOutlet UILabel *appNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *appDetailsLabel;

@property (retain, nonatomic) IBOutlet UIButton *addAppBtn;

@property (retain, nonatomic) IBOutlet UIView *whiteView;

- (IBAction)addApp:(UIButton *)sender;

@end

@implementation GOMEAddAppCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.whiteView.layer.cornerRadius = 4;
    self.whiteView.clipsToBounds = YES;
    
    [self.addAppBtn setBackgroundImage:[ImageUtil imageWithColor:GOME_BLUE_COLOR] forState:UIControlStateNormal];
    [self.addAppBtn setBackgroundImage:[ImageUtil imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    
    self.addAppBtn.layer.cornerRadius = 3;
    self.addAppBtn.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(APPListModel *)model
{
    _model = model;
    
    UIImage *image = [CustomMyCell getAppLogo:_model];
    self.appIcon.image = image;
    self.appNameLabel.text = _model.appname;
    
    self.addAppBtn.selected = !_model.appShowFlag;
}

- (IBAction)addApp:(UIButton *)sender
{
    if (!sender.selected)
    {
        sender.selected = !sender.selected;
        
        [[APPPlatformDOA getDatabase] updateApp:_model withShowFlag:!sender.selected];
        _model.appShowFlag = !sender.selected;
    }
}

@end
