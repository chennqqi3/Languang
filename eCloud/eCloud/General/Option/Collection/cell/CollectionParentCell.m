//
//  CollectionParentCell.m
//  eCloud
//
//  Created by Alex L on 15/10/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "CollectionParentCell.h"
#import "AppDelegate.h"
#import "UserDisplayUtil.h"
#import "UserInterfaceUtil.h"
#import "NSDate+Different.h"

#define KSCREEN_SIZE ([UIScreen mainScreen].bounds.size)

#define ICON_X 12
#define ICON_Y 20
#define ICON_WIDTH 20
#define ICON_HEIGHT 20

#define USERNAME_X 44
#define USERNAME_Y 21.5
#define USERNAME_WIRTH 190
#define USERNAME_HEIGHT 17

#define TIME_LABEL_Y 21.5
#define TIME_LABEL_WIRTH 105
#define TIME_LABEL_HEIGHT 16.5

#define EDITING_BUTTEN_X (10)
#define EDITING_BUTTEN_Y 0
#define EDITING_BUTTEN_WIRTH 20
#define EDITING_BUTTEN_HEIGHT 20

#define TIME_LABEL_FONT 12

#define USERNAME_FONT 12

@implementation CollectionParentCell

- (void)addCommonView
{
    self.icon = [UserDisplayUtil getUserLogoViewWithLogoHeight:ICON_HEIGHT];// 
    self.icon.tag = 103;
    CGRect _frame = self.icon.frame;
    _frame.origin = CGPointMake(ICON_X, ICON_Y);
    self.icon.frame = _frame;
    
//    self.icon.layer.cornerRadius = 2;
//    self.icon.clipsToBounds = YES;
    
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(USERNAME_X, USERNAME_Y, USERNAME_WIRTH, USERNAME_HEIGHT)];
    self.userName.tag = 104;
    [self.userName setTextColor:[UIColor grayColor]];
    [self.userName setFont:[UIFont systemFontOfSize:USERNAME_FONT]];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(KSCREEN_SIZE.width - TIME_LABEL_WIRTH - 12, TIME_LABEL_Y, TIME_LABEL_WIRTH, TIME_LABEL_HEIGHT)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeLabel setFont:[UIFont systemFontOfSize:TIME_LABEL_FONT]];
    [self.timeLabel setTextColor:[UIColor lightGrayColor]];
    
    self.editingBtn = [[UIImageView alloc] initWithFrame:CGRectMake(EDITING_BUTTEN_X, EDITING_BUTTEN_Y, EDITING_BUTTEN_WIRTH, EDITING_BUTTEN_HEIGHT)];
    self.editingBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.editingBtn.tag = 102;
    self.editingBtn.userInteractionEnabled = YES;
    
    [self addSubview:self.icon];
    [self addSubview:self.userName];
    [self addSubview:self.timeLabel];
    [self addSubview:self.editingBtn];
}

- (void)setCollectionModel:(MyCollectionModel *)collectionModel
{
    _collectionModel = collectionModel;
    
    self.userName.text = _collectionModel.userName;
    NSString *collectTime = [self  getDateFromCollect:_collectionModel];
    
    self.timeLabel.text = collectTime;
    self.icon.image = _collectionModel.icon;

    // 根据图片的宽高比例调整icon的宽高比例
    CGRect rect = self.icon.frame;
    CGFloat height = ICON_WIDTH * (_collectionModel.icon.size.height / _collectionModel.icon.size.width);
    rect.size.height = height;
    self.icon.frame = rect;
    
#ifdef _LANGUANG_FLAG_
    
    rect.size.height = 20;
    rect.size.width = 20;
    self.icon.frame = rect;
#endif
    
    
#ifdef _XIANGYUAN_FLAG_
    
    rect.size.height = 30;
    rect.size.width = 30;
    self.icon.frame = rect;
    
#endif
    
    self.icon.image = nil;
    UIImageView *realLogoView = [UserDisplayUtil getSubLogoFromLogoView:self.icon];
    realLogoView.image = collectionModel.icon;
    if ([collectionModel.icon isEqual:default_logo_image] ) {
        Emp *_emp = [[Emp alloc]init];
        _emp.emp_name = collectionModel.userName;
        NSDictionary *mDic = [UserDisplayUtil getUserDefinedLogoDicOfEmp:_emp];
        [UserDisplayUtil setUserDefinedLogo:self.icon andLogoDic:mDic];

    }else{
        [UserDisplayUtil hideLogoText:self.icon];
    }
    [UserDisplayUtil hideStatusView:self.icon];
    
}

//返回收藏的时间
-(NSString *)getDateFromCollect:(MyCollectionModel*)model
{
    
    NSString *time = [model.msgTime stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    
    formater.dateFormat = @"yyyy-MM-dd HH:mm";
    
    NSDate *sendDate  = [formater dateFromString:time];
    
    NSString *returnTime;
    BOOL today =  sendDate.isToday;  //判断是否为今日
    if (today) {
        returnTime = model.timeText;
    }else{
        BOOL notToday =  sendDate.isThisYear; //判断是否为今年
        if (notToday) {
            returnTime = [time substringFromIndex:5];

        }else{
            
            returnTime = time;
        }

    }
    return returnTime;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
