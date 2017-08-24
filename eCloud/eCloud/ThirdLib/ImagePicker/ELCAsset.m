//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"

@implementation ELCAsset

@synthesize asset;
@synthesize parent;

#define thumb_image_tag (101)

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]))
    {
        
    }
    return self;
}

- (BOOL)isSubviewInit
{
    UIView *thumbImageView = [self viewWithTag:thumb_image_tag];
    if (thumbImageView) {
//        NSLog(@"%s subview已经存在了",__FUNCTION__);
        return YES;
    }
    return NO;
}

//如果subview已经存在了，那么返回，否则初始化subview
- (void)initSubview
{
    if ([self isSubviewInit]) {
        return;
    }
    
    CGRect viewFrames;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        viewFrames = CGRectMake(0, 0, 123, 123);
    }
    else{
        CGFloat suqareLength = (SCREEN_WIDTH - 20)*0.25;
        viewFrames = CGRectMake(0, 0, suqareLength, suqareLength);
    }
    UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
    [assetImageView setContentMode:UIViewContentModeScaleToFill];
    
    //适合平台相关的缩略图
    if(self.asset._thumb)
    {
        [assetImageView setImage:self.asset._thumb];
    }
    else
    {
        if([self.asset.asset thumbnail])
        {
            [assetImageView setImage:[UIImage imageWithCGImage:[self.asset.asset thumbnail]]];
        }
    }
    
    assetImageView.tag = thumb_image_tag;
    
    [self addSubview:assetImageView];
    [assetImageView release];
    
    //如果当前只支持单个选中预览内容，则不初始化多选样式
    overlayView	=	nil;
    if(NO == self.asset.selectToPreview)
    {
        /*
         overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
         [overlayView setImage:[StringUtil getImageByResName:@"Overlay.png"]];
         [overlayView setHidden:YES];
         [self addSubview:overlayView];
         */
        // 选中与否的按钮
        overlayView = [[UIButton alloc] initWithFrame:CGRectMake(viewFrames.origin.x + viewFrames.size.width - 30, viewFrames.origin.y, 30, 30)];
        isSelected = NO;
        [overlayView setImage:[StringUtil getImageByResName:@"photo_Selection.png"] forState:UIControlStateNormal];
        [overlayView addTarget:self action:@selector(toggleSelection) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:overlayView];
        
        //			add by shisp 如果是录像文件，则特别标示出来
        NSString *_type    	=  [self.asset.asset valueForProperty:ALAssetPropertyType];
        if([_type isEqualToString:ALAssetTypeVideo])
        {
            //		设置带摄像机图标的背景
            UIImage *videoImage = [StringUtil getImageByResName:@"video_flag"];
            //		图标高
            int videoImageHeight = videoImage.size.height;
            
            UIImageView *videoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,viewFrames.size.height-videoImageHeight,videoImage.size.width,videoImageHeight)];
            
            [videoView setImage:videoImage];
            
            [self addSubview:videoView];
            
            [videoView release];
            
            //视频持续时间view
            UILabel *durationView = [[UILabel alloc]initWithFrame:CGRectMake(0,viewFrames.size.height-videoImageHeight,viewFrames.size.width,videoImageHeight)];
            
            //		Helvetica Bold 17.0
            UIFont *font = [UIFont boldSystemFontOfSize:12];
            [durationView setFont:font];
            
            durationView.adjustsFontSizeToFitWidth = YES;
            durationView.textColor = [UIColor whiteColor];
            durationView.backgroundColor=[UIColor clearColor];
            durationView.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
            durationView.textAlignment = UITextAlignmentRight;
            
            //				格式化视频持续时间
            int iDuration = [[self.asset.asset valueForProperty:ALAssetPropertyDuration]intValue];
            NSString *sDuration;
            int sec;
            if(iDuration < 60)
            {
                sec = iDuration;
                if(sec < 10)
                {
                    sDuration = [NSString stringWithFormat:@"0:0%d  ",sec];
                }
                else {
                    sDuration = [NSString stringWithFormat:@"0:%d  ",iDuration];
                }
            }
            else
            {
                sec = iDuration % 60;
                if(sec < 10)
                {
                    sDuration = [NSString stringWithFormat:@"%d:0%d  ",iDuration/60,sec];						
                }
                else {
                    sDuration = [NSString stringWithFormat:@"%d:%d  ",iDuration/60,sec];
                }
            }
            
            durationView.text = sDuration;
            
            
            [self addSubview:durationView];
            
            [durationView release];
        }
        
    }
}

-(id)initWithAsset:(WoALAsset*)_asset {
	
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	if (self) 
    {
		self.asset = _asset;
    }
    
	return self;	
}

-(void)toggleSelection 
{
	if(nil == overlayView)
	{
		[parent performSelector:@selector(didSelectedAsset:) withObject:self.asset];
	}
	else 
	{
		isSelected = !isSelected;
        if (isSelected) {
            [overlayView setImage:[StringUtil getImageByResName:@"photo_Selection_ok.png"] forState:UIControlStateNormal];
        }
        else{
            [overlayView setImage:[StringUtil getImageByResName:@"photo_Selection.png"] forState:UIControlStateNormal];
        }
        
        [parent performSelector:@selector(didSelectedAsset:) withObject:self];
	}
}

-(void)toggleSelectionDetail{
    //进入到详细大图
    [parent performSelector:@selector(didSelectedAssetDetail:) withObject:self];
}

-(BOOL)selected 
{	
    //asset.isSelected    =   (nil == overlayView)?NO:!overlayView.hidden;
    asset.isSelected    = isSelected;
	return asset.isSelected;
}

-(void)setSelected:(BOOL)_selected 
{    
	//[overlayView setHidden:!_selected];
    
    if (overlayView) {
        isSelected = _selected;
        if (_selected) {
            [overlayView setImage:[StringUtil getImageByResName:@"photo_Selection_ok@2x.png"] forState:UIControlStateNormal];
        }
        else{
            [overlayView setImage:[StringUtil getImageByResName:@"photo_Selection@2x.png"] forState:UIControlStateNormal];
        }
    }
}

- (void)dealloc 
{    
    self.asset = nil;
	if(overlayView)
		[overlayView release];
    [super dealloc];
}

@end

