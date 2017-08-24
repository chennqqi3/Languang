//
//  GSAPriceMianViewController.h
//  GMFindPrice
//
//  Created by song on 2017/3/13.
//  Copyright © 2017年 song. All rights reserved.
//



//ID为453，账号为CDW020819，密码123456，试试

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,CharactorType)
{
    SubmitType,
    CheckType,
};


@interface GSAPriceMianViewController : UIViewController

@property (assign, nonatomic) CharactorType type;
@property (assign, nonatomic) BOOL hideCarema;

@property (copy, nonatomic) NSString *userID;
@end
