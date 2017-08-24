//
//  chatRecordCell.h
//  eCloud
//
//  Created by shinehey on 15/1/5.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#define icon_tag 10001
#define name_tag 10002
#define text_tag 10003
#define time_tag 10004

#define text_Width 200.0
#define text_height 34.0
#define row_height 64.0


#import <UIKit/UIKit.h>
@class ConvRecord;

@interface chatRecordCell : UITableViewCell


-(void)configCellWithConvRecord:(ConvRecord *)convRecord;
@end
