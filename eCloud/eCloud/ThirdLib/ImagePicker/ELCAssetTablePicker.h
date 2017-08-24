//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ELCAssetTablePicker : UITableViewController
{
	NSMutableArray *elcAssets;
	int selectedAssets;
	id parent;
	NSOperationQueue *queue;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, readonly) NSMutableArray *elcAssets;
@property (nonatomic, retain) IBOutlet UILabel *selectedAssetsLabel;

-(int)totalSelectedAssets;
-(void)preparePhotos:(NSArray *)array;
-(void)doneAction:(id)sender;
- (void)cancelAction:(id)sender;
@end
