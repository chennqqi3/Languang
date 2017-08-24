//
//  APPIntroViewController.m
//  eCloud
//
//  Created by Pain on 14-7-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPIntroViewController.h"
#import "APPListDetailViewController.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "APPUtil.h"
#import "UIAdapterUtil.h"
#import <CommonCrypto/CommonHMAC.h>
#import "eCloudDefine.h"

@interface APPIntroViewController (){
    APPListModel *appModel;
    UIScrollView *memberScroll;
}

@end

@implementation APPIntroViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAppID:(NSString *)_appid{
    self = [super init];
    if (self) {
        appid = [[NSString alloc] initWithFormat:@"%@",_appid];
        appModel = [[[APPPlatformDOA getDatabase] getAPPModelByAppid:appid] retain];
    }
    return self;
}

- (void)dealloc{
    [appid release];
    appid = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:235.0/255.0 blue:245.0/255.0 alpha:1];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    self.title = @"详情";
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setExtraCellLineHidden:self.tableView];
}

#pragma mark - 返回按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [view release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row] == 0) {
        return 75.0;
    }
    else{
        
        return 350 + [self getSummaryHeigh];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([indexPath row] == 0) {
            //应用图标
            UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(16.0, 16.0, 40.0, 40.0)];
            logoView.backgroundColor = [UIColor clearColor];
            logoView.tag = 40;
            [cell.contentView  addSubview:logoView];
            [logoView release];
            
            //应用名称
            UILabel *appName = [[UILabel alloc]initWithFrame:CGRectMake(70.0,17.0,160.0,40.0)];
            appName .font = [UIFont systemFontOfSize:16.0];
            appName.tag = 41;
            appName.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:appName];
            [appName release];
            
            //详细资料按钮
            UIButton *detailButton=[[UIButton alloc]initWithFrame:CGRectMake(228.0, 22.0, 77.0, 31.0)];
            detailButton.backgroundColor = [UIColor clearColor];
            detailButton.tag = 42;
            [detailButton setBackgroundImage:[StringUtil getImageByResName:@"app_download_btn.png"] forState:UIControlStateNormal];
            if (1 == appModel.apptype) {
                //html应用
                [detailButton setTitle:@"进入应用" forState:UIControlStateNormal];
            }
            else if (2 == appModel.apptype){
                //原生应用
                [detailButton setTitle:@"下载应用" forState:UIControlStateNormal];
            }
            
            detailButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.contentView addSubview:detailButton];
            [detailButton release];
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else{
            UILabel *lineBreak = [[UILabel alloc]initWithFrame:CGRectMake(0.0,0.0,320.0,1.0)];
            lineBreak.backgroundColor = [UIColor colorWithRed:203.0/255 green:203.0/255 blue:205.0/255 alpha:1.0];
            [cell.contentView addSubview:lineBreak];
            [lineBreak release];
            
            memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 14.0, 320, 284.0)];
            memberScroll.backgroundColor=[UIColor colorWithRed:235/255.0 green:235.0/255.0 blue:245.0/255.0 alpha:1];
            memberScroll.showsHorizontalScrollIndicator = NO;
            memberScroll.showsVerticalScrollIndicator = NO;
            memberScroll.scrollsToTop = NO;
            memberScroll.tag = 50;
            [cell.contentView addSubview:memberScroll];
            [memberScroll release];
            
            //摘要
            UILabel *summary = [[UILabel alloc]initWithFrame:CGRectMake(16.0,312.0,160.0,40.0)];
            summary .font = [UIFont boldSystemFontOfSize:16.0];
            summary.tag = 51;
            summary.text = @"内容摘要";
            summary.textColor = [UIColor colorWithRed:79.0/255 green:79.0/255 blue:79.0/255 alpha:1];
            summary.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:summary];
            [summary release];
            
            UILabel *summaryDetail = [[UILabel alloc]initWithFrame:CGRectMake(16.0,348.0,288.0,40.0)];
            summaryDetail .font = [UIFont systemFontOfSize:14.0];
            summaryDetail.tag = 52;
            summaryDetail.numberOfLines = 0;
            summaryDetail.lineBreakMode = UILineBreakModeTailTruncation;
            summaryDetail.textColor = [UIColor colorWithRed:79.0/255 green:79.0/255 blue:79.0/255 alpha:1];
            summaryDetail.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:summaryDetail];
            [summaryDetail release];
            
            cell.contentView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235.0/255.0 blue:245.0/255.0 alpha:1];
        }
	}
    
    switch ([indexPath row]) {
        case 0:
        {
            [(UIImageView *)[cell.contentView viewWithTag:40] setImage:[APPUtil getAPPLogo:appModel]];
            [(UILabel *)[cell.contentView viewWithTag:41] setText:[NSString stringWithFormat:@"%@",appModel.appname]];
            [(UIButton *)[cell.contentView viewWithTag:42] addTarget:self action:@selector(enterAppAction) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 1:
        {
            UILabel *summLab = (UILabel *)[cell.contentView viewWithTag:52];
            [summLab setText:[NSString stringWithFormat:@"%@",appModel.appdesc]];
            
            CGRect frame = summLab.frame;
            frame.size.height = [self getSummaryHeigh];
            [summLab setFrame:frame];
            
            UIScrollView *scrollVew = (UIScrollView *)[cell.contentView viewWithTag:50];
            [self showUIScrollView:scrollVew];
        }
            break;
        default:
            break;
    }

	return cell;
}

#pragma mark - 按钮方法实现
- (void)enterAppAction{
    //标识应用为已下载
    [[APPPlatformDOA getDatabase] setAPPModelDownLoadFlag:appModel.appid];
    
    if (1 == appModel.apptype) {
        //html应用
        NSString *url_str=[NSString stringWithFormat:@"%@",appModel.serverurl];
        NSLog(@"url_str------%@",url_str);
        APPListDetailViewController *ctr = [[APPListDetailViewController alloc] initWithAppID:appModel.appid];
        ctr.customTitle = appModel.appname;
        ctr.urlstr=url_str;
        [self.navigationController pushViewController:ctr animated:YES];
        [ctr release];
    }
    else if (2 == appModel.apptype){
        //原生应用
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appModel.serverurl]];
    }
}

#pragma mark - 获取摘要高度
- (float)getSummaryHeigh{
    float height = 0;
    NSString *summaryStr = [NSString stringWithFormat:@"%@",appModel.appdesc];
    UIFont *font = [UIFont systemFontOfSize:14.0];
    CGSize size = CGSizeMake(288.0,2000);
    CGSize labelsize = [summaryStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeTailTruncation];
    height = labelsize.height;
    return height;
}

#pragma mark - 简介图片
- (void)showUIScrollView:(UIScrollView *)memberScroll{
    for (UIView *subView in memberScroll.subviews) {
        [subView removeFromSuperview];
    }
    NSArray *apppics = [NSArray arrayWithArray:appModel.apppics];
//    NSLog(@"apppics-------%@",apppics);
    int count = [apppics count];
    memberScroll.contentSize = CGSizeMake(10.0+170.0*count, 284.0);
    for (int i = 0; i < count; i ++) {
        UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(10.0+170.0*i, 0.0, 160.0, 284.0)];
        logoView.backgroundColor = [UIColor clearColor];
        logoView.contentMode = UIViewContentModeScaleToFill;
//        NSString *urlStr = @"http://images-cdn.digu.com/sp/width/480/723ce545bef0467799fc5bc38878427a0001.jpg";
        NSString *urlStr = [NSString stringWithFormat:@"%@",[apppics objectAtIndex:i]];
        if ([urlStr length]>4) {
            [logoView setImage:[self getImageWithURLStr:urlStr withAppid:appModel.appid]];
        }
        [memberScroll  addSubview:logoView];
        [logoView release];
    }
}

#pragma mark - 下载图片
-(UIImage *)getImageWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid{
    NSString *logoPath = [self getAppSummaryPicWithURLStr:urlStr withAppid:appid];
	UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
	if(image == nil){
		[self downloadPicWithURLStr:urlStr withAppid:appid];
	}
	else{
		image = [UIImage createRoundedRectImage:image size:CGSizeZero];
	}
	return image;
}

- (void)downloadPicWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid{
    NSString *logoPath =  [self getAppSummaryPicWithURLStr:urlStr withAppid:appid];
    UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
    if(img == nil)
    {
        dispatch_queue_t _queue = dispatch_queue_create("download_app_logo", NULL);
        dispatch_async(_queue, ^{
            NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if(imageData != nil && imageData.length > 0)
            {
                if([imageData writeToFile:logoPath atomically:YES]){
                    NSLog(@"应用图标下载成功保存成功，%@",urlStr);
                    [self performSelectorOnMainThread:@selector(showUIScrollView:) withObject:memberScroll waitUntilDone:NO];
                }
                else{
                    NSLog(@"应用图标下载成功保存失败，%@",urlStr);
                }
            }
            else{
                NSLog(@"应用图标下载失败%@",urlStr);
            }
        } );
        dispatch_release(_queue);
    }
}

- (NSString *)getAppSummaryPicWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid
{
	NSString *path = [StringUtil newAppIconPathWithAppid:appid];
	NSString *extension = [urlStr pathExtension];
	if (![extension length]) {
		extension = @"png";
	}
	path =  [path stringByAppendingPathComponent:[[[self class] keyForURL:[NSURL URLWithString:urlStr]] stringByAppendingPathExtension:extension]];
	return path;
}

+(NSString *)keyForURL:(NSURL *)url
{
	NSString *urlString = [url absoluteString];
	if ([[urlString substringFromIndex:[urlString length]-1] isEqualToString:@"/"]) {
		urlString = [urlString substringToIndex:[urlString length]-1];
	}
	const char *cStr = [urlString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}


@end
