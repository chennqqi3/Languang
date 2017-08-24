//
//  Asset.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PictureManager.h"

@interface ELCAsset : UIView {
	//ALAsset *asset;
	//UIImageView *overlayView;
    UIButton *overlayView;
	//BOOL selected;
	id parent;
    
    WoALAsset   *asset;
    BOOL isSelected;
}

@property (nonatomic, retain) WoALAsset *asset;
@property (nonatomic, assign) id parent;

-(id)initWithAsset:(WoALAsset*)_asset;

- (BOOL)isSubviewInit;

//初始化view
- (void)initSubview;

-(BOOL)selected;
-(void)setSelected:(BOOL)_selected;
-(void)toggleSelection;
@end