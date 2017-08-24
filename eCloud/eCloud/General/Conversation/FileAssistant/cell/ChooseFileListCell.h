//
//  FileListCell.h
//  eCloud
//
//  Created by 风影 on 15/1/30.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConvRecord;

@interface ChooseFileListCell : UITableViewCell{
    
}
- (void)configureCell:(UITableViewCell *)cell andConvRecord:(ConvRecord*)_convRecord; //配置cell


@end
