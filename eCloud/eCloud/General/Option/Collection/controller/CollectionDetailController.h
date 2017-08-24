//
//  CollectionDetailController.h
//  eCloud
//
//  Created by Alex L on 15/10/9.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCollectionModel.h"

@class ConvRecord;

@protocol deleteDelegate <NSObject>

- (void)deleteCollection:(MyCollectionModel *)collectionModel;

@end

@interface CollectionDetailController : UIViewController

@property (nonatomic, strong)MyCollectionModel *collectionModel;
@property (nonatomic, copy)NSString *time;

@property (nonatomic, assign) id<deleteDelegate> delegate;

+ (ConvRecord *)getConvRecordByCollectModel:(MyCollectionModel *)collectionModel;

@end
