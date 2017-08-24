//
//  LCLShareThumbController.h
//  PhotoSea
//
//  Created by  lyong on 13-5-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCAssetTablePicker.h"
#import "ELCImagePreViewViewController.h"


@interface LCLShareThumbController : ELCAssetTablePicker<UIActionSheetDelegate,ELCImagePreViewViewControllerDelegate>
{
    NSArray *relation;
	NSString *_receiverName;
    NSString *filePath;
    id pre_delegete;
    
    UIButton *sendbutton;
    UIButton *previewbutton;
    NSMutableArray *selectedAssetsImages;
    NSMutableArray *selectedAssetsArray;
    
    BOOL isPreViewAllPhotoes;
    
    NSInteger maxSelectedCount;
    
    BOOL isForKapokFly;
    int kapok_num;
    
    ELCImagePreViewViewController *eLCImagePreCtr;
    ELCImagePreViewViewController *eLCSelectedImagePreCtr;
}
@property(assign) int kapok_num;
@property(assign)BOOL isForKapokFly;
@property(assign)id pre_delegete;
@property(nonatomic,retain)NSArray *relation;
@property(nonatomic,retain)NSString *receiverName;
@end
