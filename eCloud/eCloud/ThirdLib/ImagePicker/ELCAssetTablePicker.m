//
//  AssetTablePicker.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCImagePickerController.h"
#import "PictureManager.h"
#import "IOSSystemDefine.h"
#import "eCloudDefine.h"

#import "LogUtil.h"
#import "StringUtil.h"

@implementation ELCAssetTablePicker

@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize elcAssets;
//调整图片大小
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)viewWillAppear:(BOOL)animated
{
     self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
   // self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
   
//    self.navigationController.navigationBar.tintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_导航条.png"]];
//    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
//    UIImage *backgroundImage = [UIImage imageNamed:@"Default.png"];  //获取图片
//    [self.tableView setSeparatorColor:[UIColor clearColor]];
//    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
//    if(systemVersion>=5.0)
//    {
//        CGSize titleSize = self.navigationController.navigationBar.bounds.size;  //获取Navigation Bar的位置和大小
//        backgroundImage = [self scaleToSize:backgroundImage size:titleSize];//设置图片的大小与Navigation Bar相同
//        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];  //设置背景
//    }
//    else
//    {
//        [self.navigationController.navigationBar insertSubview:[[[UIImageView alloc] initWithImage:backgroundImage] autorelease] atIndex:1];
//    }

    int rownum = [self calculateRow];

    if (rownum>0) {
        
        NSIndexPath *lastRow = [NSIndexPath indexPathForRow:rownum-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastRow
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    }
    
    self.tableView.contentOffset=CGPointMake(0, self.tableView.contentOffset.y);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
	[self.tableView setAllowsSelection:NO];
    /*
    UIBarButtonItem *cancelButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:cancelButtonItem];
    
    UIBarButtonItem *doneButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)] autorelease];
	[self.navigationItem setRightBarButtonItem:doneButtonItem];
     */
}


-(void)viewDidLoad 
{        
	[super viewDidLoad];
}

- (void)cancelAction:(id)sender
{
    [(ELCImagePickerController*)self.parent cancelImagePicker];
}

-(void)preparePhotos:(NSArray *)array 
{
    long long start = [StringUtil currentMillionSecond];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	[elcAssets removeAllObjects];
	[elcAssets release];
    elcAssets = [[NSMutableArray alloc] init];
    // Show partial while full list loads
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
    
    for (WoALAsset *result in array)
    {
        ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
        [elcAsset setParent:self];
        [elcAsset setSelected:result.isSelected];
        [self.elcAssets addObject:elcAsset];
    }
	[self.tableView reloadData];
	[self.navigationItem setTitle:@"选择图片"];
 
    [pool release];
    
    long long end = [StringUtil currentMillionSecond];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 准备显示图片需要时间 %lld",__FUNCTION__,(end - start)]];

}

- (void) doneAction:(id)sender {
	
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
    
	for(ELCAsset *elcAsset in self.elcAssets) 
    {		
		if([elcAsset selected])
        {
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
    
    [(ELCImagePickerController*)self.parent selectedAssets:selectedAssetsImages];
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (int)calculateRow
{
    int _row = [elcAssets count] / [self getPerRowCount];
    if ([elcAssets count] % [self getPerRowCount]) {
        return _row + 1;
    }
    return _row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [self calculateRow];
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
    int perRowCount = [self getPerRowCount];
    int index = (_indexPath.row * perRowCount);
    NSUInteger maxIndex = index + perRowCount;

    
    NSMutableArray *_array = [NSMutableArray array];
    for (int i = index; i < maxIndex && i < self.elcAssets.count; i++) {
        ELCAsset *elcAsset  = [self.elcAssets objectAtIndex:i];
        [elcAsset initSubview];
        [_array addObject:elcAsset];
    }
    
    return _array;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
        
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {		        
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:nil] autorelease];
    }	
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 135;
        
    }else if(IS_IPHONE_6)
    {
        return 92;
        
    }else if(IS_IPHONE_6P)
    {
        CGFloat a = (414- 4*5)*0.25;
        return a + 4;
        
    }else{
        
        return 79;
        
    }
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets) 
    {
		if([asset selected]) 
        {            
            count++;	
		}
	}
    
    return count;
}

- (void)dealloc 
{
    [elcAssets release];
    [selectedAssetsLabel release];
    [super dealloc];    
}

- (int)getPerRowCount
{
    int perRowCount = 4;
    if (IS_IPAD) {
        if ([UIAdapterUtil isLandscap]) {
            perRowCount = 8;
        }else{
            perRowCount = 6;
        }
    }
    return perRowCount;
}
@end
