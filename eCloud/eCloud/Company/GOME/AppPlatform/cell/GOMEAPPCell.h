//
//  GOMEAPPCell.h
//  GOME_DEMO
//
//  Created by Alex L on 16/11/29.
//  Copyright © 2016年 Alex L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPListModel.h"

@interface GOMEAPPCell : UICollectionViewCell

@property (nonatomic, strong) APPListModel *model;

@property (nonatomic, assign) BOOL isEditing;

@end
