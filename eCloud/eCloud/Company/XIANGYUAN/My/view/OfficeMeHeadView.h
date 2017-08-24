//
//  OfficeMeHeadView.h
//  WanDaOA
//
//  Created by hfchenc on 14-6-26.
//  Copyright (c) 2014年 李文龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfficeMeHeadView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *arrowImage;
@property (retain, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinyinLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *loginNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workingDaysLabel;

@property (nonatomic, copy) void(^tapHeadViewBlock)(void);
@property (nonatomic, copy) void(^personInfomationBlock)(void);

+ (OfficeMeHeadView *)loadFromXib;
- (void)loadViewWithHeadImage:(NSString *)imageUrl name:(NSString *)name position:(NSString *)position apartment:(NSString *)apartment loginName:(NSString *)longName;

- (IBAction)tapHeadView:(id)sender;
@end
