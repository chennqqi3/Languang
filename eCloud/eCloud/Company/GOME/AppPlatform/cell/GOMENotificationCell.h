//
//  GOMENotificationCell.h
//  eCloud
//
//  Created by Alex L on 16/12/7.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOMENotificationCell;
@class AppMsgModel;

@protocol GOMENotificationCellDelegate <NSObject>

- (void)deleteWithIndex:(NSInteger)index;

- (void)viewDetail:(GOMENotificationCell *)cell;

@end

@interface GOMENotificationCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic,strong) AppMsgModel *appMsgModel;

@property (nonatomic, assign) id<GOMENotificationCellDelegate>deleteDelegate;

@end
