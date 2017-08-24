//
//  PSDetailViewController.h
//  eCloud
//
//  Created by Richard on 13-10-28.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServiceModel;

@interface PSDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign) int serviceId;
@property(nonatomic,retain) ServiceModel *serviceModel;
@end
