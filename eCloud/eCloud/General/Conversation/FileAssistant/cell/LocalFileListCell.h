//
//  LocalFileListCell.h
//  QuickLookDemo
//
//  Created by Pain on 14-4-9.
//  Copyright (c) 2014年 yangjw . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalFileListCell : UITableViewCell{
    
}
@property (nonatomic,retain) UIButton *isSelectBtn;
@property (nonatomic,retain) UIImageView *isSelectBtnView;
@property (nonatomic,retain) UIImageView *fileIconView;
@property (nonatomic, retain) UILabel     *fileNameLabel;
@property (nonatomic, retain) UILabel     *fileSizeLabel;
@property (nonatomic, retain) UILabel     *fileCreateDateLabel;

@end
