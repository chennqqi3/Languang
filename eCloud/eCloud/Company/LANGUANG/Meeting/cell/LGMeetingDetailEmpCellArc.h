//
//  LGMeetingDetailEmpCell.h
//  mettingDetail
//
//  Created by Alex-L on 2017/1/2.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LGMeetingDetailEmpCellArcDelegate <NSObject>

- (void)showMoreEmp:(BOOL)isShow;

@end

@interface LGMeetingDetailEmpCellArc : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray *empArray;

@property (nonatomic, weak) id<LGMeetingDetailEmpCellArcDelegate>showDelegate;

@end
