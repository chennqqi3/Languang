//
//  LGMettingDetailViewControllerArc.h
//  mettingDetail
//
//  Created by Alex-L on 2017/5/26.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGMettingDetailViewControllerArc : UIViewController

@property (nonatomic , strong) NSString *urlStr;
@property (nonatomic , strong) NSString *idNum;
@property (nonatomic , strong) NSString *type;

+(LGMettingDetailViewControllerArc *)getLGMettingDetailViewControllerArc;
- (NSDate *)getCurrentTime;
- (BOOL )compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
@end
