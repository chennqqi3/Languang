//
//  XINHUAOrgGroupViewControllerArc.h
//  eCloud
//
//  Created by Alex-L on 2017/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrgGroupViewControllerDelegate <NSObject>

- (void)selectGroupFinish;

@end

@interface XINHUAOrgGroupViewControllerArc : UIViewController

@property (nonatomic, strong) NSString *groupTitle;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) id<OrgGroupViewControllerDelegate>delegate;

@end
