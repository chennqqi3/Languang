//
//  CollectionParentCell.h
//  eCloud
//
//  Created by Alex L on 15/10/10.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCollectionModel.h"

@interface CollectionParentCell : UITableViewCell

@property (nonatomic, strong) UIImageView* icon;
@property (nonatomic, strong) UILabel* userName;
@property (nonatomic, strong) UILabel* timeLabel;

@property (nonatomic, strong) UIImageView *editingBtn;

@property (nonatomic, strong) MyCollectionModel *collectionModel;

- (void)addCommonView;

@end
