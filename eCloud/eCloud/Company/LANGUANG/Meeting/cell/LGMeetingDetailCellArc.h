//
//  LGMettingDetailCellArc.h
//  mettingDetail
//
//  Created by Alex-L on 2017/5/31.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGMeetingDetailCellArc : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (retain, nonatomic) IBOutlet UIButton *attendConfBtn;

@property(nonatomic,strong)NSDictionary *dict;
@property(nonatomic,strong)NSString *idNum;
@end
