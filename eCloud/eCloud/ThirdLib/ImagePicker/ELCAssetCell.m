//
//  AssetCell.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "IOSSystemDefine.h"

@implementation ELCAssetCell

@synthesize rowAssets;

-(id)initWithAssets:(NSArray*)_assets reuseIdentifier:(NSString*)_identifier {
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
	if(self)
    {
		self.rowAssets = _assets;
	}
	
	return self;
}

-(void)setAssets:(NSArray*)_assets {
	
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
       self.rowAssets = _assets;
       return;
    }
    
	for(UIView *view in [self subviews]) 
    {		
		[view removeFromSuperview];
	}
	
	self.rowAssets = _assets;
}

-(void)layoutSubviews {

    CGRect frame;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
	frame = CGRectMake(4, 2, 123, 123);
	}else
    {
        if (IS_IPHONE_6) {
            
            frame = CGRectMake(4, 2, 88.75, 88.75);
            
        }else if(IS_IPHONE_6P){
            
            frame = CGRectMake(4, 2, 98.5, 98.5);
            
        }else{
            
            frame = CGRectMake(4, 2, 75, 75);
        }
    
    }
	for(ELCAsset *elcAsset in self.rowAssets) {
        elcAsset.backgroundColor = [UIColor blackColor];
		[elcAsset setFrame:frame];
		[elcAsset addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:elcAsset action:@selector(toggleSelectionDetail)] autorelease]];
		[self addSubview:elcAsset];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}

-(void)dealloc 
{
	[rowAssets release];
    
	[super dealloc];
}

@end
