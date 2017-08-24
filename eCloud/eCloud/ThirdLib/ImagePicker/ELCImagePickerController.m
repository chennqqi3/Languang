//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"

@implementation ELCImagePickerController

@synthesize delegate;

-(void)cancelImagePicker 
{
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) 
    {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)selectedAssets:(NSArray*)_assets 
{
    [self popToRootViewControllerAnimated:NO];
    [[self parentViewController] dismissModalViewControllerAnimated:YES];
    
	if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)])
    {
        [delegate elcImagePickerController:self
             didFinishPickingMediaWithInfo:_assets];
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {    
    //NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)dealloc {
    //NSLog(@"deallocing ELCImagePickerController");
    [super dealloc];
}

@end
