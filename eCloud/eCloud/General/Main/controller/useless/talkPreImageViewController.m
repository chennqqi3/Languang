//
//  talkPreImageViewController.m
//  eCloud
//
//  Created by  lyong on 12-11-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "talkPreImageViewController.h"
#import "FGalleryViewController.h"

@interface talkPreImageViewController ()<FGalleryViewControllerDelegate>

@end

@implementation talkPreImageViewController
@synthesize  imageData;
@synthesize imageView;
@synthesize  delegete;
@synthesize preImageFullPath;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
  

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //	标题栏
    //self.view.backgroundColor=[UIColor blackColor];
    localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self];
    localGallery.imagePath=self.preImageFullPath;
  //  self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
     self.navigationController.navigationBar.tintColor=[UIColor blackColor];
   [self.navigationController pushViewController:localGallery animated:YES];
    [localGallery release];
  
 
 
}
-(void)backButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
   
}

-(void)saveButtonPressed:(id)sender
{
     UIImageWriteToSavedPhotosAlbum(self.imageData, self,nil, nil);//存入相册
  
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"存入相册成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [alert release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [imageData release];
    [imageView release];
    [delegete release];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
//    int num;
//    if( gallery == localGallery ) {
//        num = 1;
//    }
//    else if( gallery == networkGallery ) {
//        num = 1;
//    }
	return 1;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
//	if( gallery == localGallery ) {
		return FGalleryPhotoSourceTypeLocal;
//	}
//	else return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    if( gallery == localGallery ) {
        caption = @"112 ";
    }
    else if( gallery == networkGallery ) {
        caption =@"343";
    }
	return @" ";
}


- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
  
    return self.preImageFullPath;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
 
    return nil;
}

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}

- (void)handleEditCaptionButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

@end
