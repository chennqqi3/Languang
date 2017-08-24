//
//  AttentionViewController.h
//  eCloud
//
//  Created by shisuping on 16/8/25.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APPListModel;

@interface AttentionViewController : UIViewController

+ (void)createTestData;

@property (nonatomic,retain) APPListModel *appModel;

@end
