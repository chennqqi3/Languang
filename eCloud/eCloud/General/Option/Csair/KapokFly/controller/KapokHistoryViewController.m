//
//  KapokHistoryViewController.m
//  eCloud
//
//  Created by  lyong on 14-5-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "KapokHistoryViewController.h"
#import "KapokUploadViewController.h"
#import "KapokDAO.h"
#import "KapokPreViewController.h"
#import "ASIFormDataRequest.h"
#import "kapokImageObject.h"
#import "kapokUploadEventObject.h"
#import "eCloudDefine.h"

@interface KapokHistoryViewController ()

@end

@implementation KapokHistoryViewController
@synthesize dataArray;
@synthesize readyArray;

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
    if (kapokUploadTable) {
        
        [self.readyArray removeAllObjects];
        NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
        [self.readyArray addObjectsFromArray:array];
        
        [self.dataArray removeAllObjects];
        [self getKapokUploadNewest];
        
        kapokUploadTable.contentOffset=CGPointMake(0, 0);
        
        [kapokUploadTable reloadData];
        
        // [self getToken];
        
        int count=[self.readyArray count]+[self.dataArray count];
        NoPhotoTipLabel.hidden=YES;
        if (count==0) {
            NoPhotoTipLabel.hidden=NO;
        }
        kapokObjectForUploading=[[KapokDAO getDatabase]getKapokUploadingEvent];
        if (kapokObjectForUploading==nil) {
            webView.hidden=YES;
            return ;
        }
        webView.hidden=NO;
        [self performSelector:@selector(getToken) withObject:nil afterDelay:0.5];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    
    //==加载gif数据
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(75, 130, 80, 10)];
    //==获取gif文件路径
    NSString *filePath=[[StringUtil getBundle] pathForResource:@"kapod_dot" ofType:@"gif"];
    //==获取gif数据
    NSData *gifData=[NSData dataWithContentsOfFile:filePath];
    [webView loadData:gifData
             MIMEType:@"image/gif"
     textEncodingName:nil
              baseURL:nil];
    
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    [UIAdapterUtil setRightButtonItemWithTitle:@"上传" andTarget:self andSelector:@selector(uploadButtonPressed:)];
    
    kapokUploadTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    kapokUploadTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    [kapokUploadTable setDelegate:self];
    [kapokUploadTable setDataSource:self];
    kapokUploadTable.backgroundColor=[UIColor whiteColor];
    kapokUploadTable.showsHorizontalScrollIndicator = NO;
    kapokUploadTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:kapokUploadTable];
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    tipLabel.text=@"加载中...";
    tipLabel.font=[UIFont systemFontOfSize:14];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    
    self.dataArray=[[NSMutableArray alloc]init];
    [self getKapokUploadNewest];
    
    self.readyArray=[[NSMutableArray alloc]init];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
	[self.readyArray addObjectsFromArray:array];
    //kapokUploadTable.tableFooterView=tipLabel;
	// Do any additional setup after loading the view.
    // 0803 适配
    NoPhotoTipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 30)];
    NoPhotoTipLabel.backgroundColor=[UIColor clearColor];
    NoPhotoTipLabel.textAlignment=NSTextAlignmentCenter;
    NoPhotoTipLabel.text=@"无上传纪录";
    [self.view addSubview:NoPhotoTipLabel];
    int count=[self.readyArray count]+[self.dataArray count];
    NoPhotoTipLabel.hidden=YES;
    if (count==0) {
        NoPhotoTipLabel.hidden=NO;
    }
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)uploadButtonPressed:(id)sender
{
    KapokUploadViewController *kapokUpload=[[KapokUploadViewController alloc]init];
    [self.navigationController pushViewController:kapokUpload animated:YES];
    [kapokUpload release];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)see_pic_buttonAction:(id)sender
{
    UIButton *see_pic_button=(UIButton *)sender;
    UILabel *upload_id_label=(UILabel *)[see_pic_button viewWithTag:11];
    
    NSArray *pic_array= [[KapokDAO getDatabase]getKapokUploadImageListPathBy:upload_id_label.text];
    //  NSLog(@"--upload_id_label--- %@  array-- %@",upload_id_label.text,pic_array);
    KapokPreViewController *kapok_pre=[[KapokPreViewController alloc]init];
    kapok_pre.dataArray=pic_array;
    [self.navigationController pushViewController:kapok_pre animated:YES];
    [kapok_pre release];
}
-(void)cancelAction:(id)sender
{
    [networkQueueForImage cancelAllOperations];
    
    [[KapokDAO getDatabase]deleteOneUpload:kapokObjectForUploading.upload_id];
    
    [[KapokDAO getDatabase] startNextUploading];//开启下一个上传
    
    [self.readyArray removeAllObjects];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
    [self.readyArray addObjectsFromArray:array];
    
    [kapokUploadTable reloadData];
    
    [self getToken];
    int count=[self.readyArray count]+[self.dataArray count];
    NoPhotoTipLabel.hidden=YES;
    if (count==0) {
        NoPhotoTipLabel.hidden=NO;
    }
}
-(void)modifyAction:(id)sender
{
    UIButton *modify_button=(UIButton *)sender;
    UILabel *modify_label=(UILabel *)[modify_button viewWithTag:14];
    
    KapokUploadViewController *kapokUpload=[[KapokUploadViewController alloc]init];
    kapokUpload.modify_type_upload_id=modify_label.text;
    [self.navigationController pushViewController:kapokUpload animated:YES];
    [kapokUpload release];
}
#pragma  table
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    if (section==0) {
        return [self.readyArray count];
    }else
    {
        return [self.dataArray count];
    }
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 160;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=nil;
    static NSString *CellIdentifier_0 = @"Cell1";
    static NSString *CellIdentifier_1 = @"Cell2";
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_0];
    }else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_1];
    }
    
    if (cell == nil)
	{
        
        if (indexPath.section==0) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_0]autorelease];
        }else
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_1]autorelease];
        }
        // 圆角矩形框
        UIImageView *fk_image=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5,self.view.frame.size.width -10, 150)];
        fk_image.tag=1;
        //fk_image.image=[StringUtil getImageByResName:@"fly_blue.png"];
        [cell.contentView addSubview:fk_image];
        [fk_image release];
        
        UIImageView *icon_view=[[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 25, 25)];
        icon_view.tag=2;
        // icon_view.image=[StringUtil getImageByResName:@"fly_2.png"];
        [cell.contentView addSubview:icon_view];
        [icon_view release];
        
        UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(45, 10, 280, 30)];
        titlelabel.tag=3;
        titlelabel.backgroundColor=[UIColor clearColor];
        titlelabel.font=[UIFont systemFontOfSize:14];
        [cell.contentView addSubview:titlelabel];
        [titlelabel release];
        
        
        UILabel *linelabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 40, self.view.frame.size.width-20, 1)];
        linelabel.backgroundColor=[UIColor lightGrayColor];
        [cell.contentView addSubview:linelabel];
        [linelabel release];
        
        UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 120, self.view.frame.size.width-40, 30)];
        timelabel.tag=4;
        timelabel.backgroundColor=[UIColor clearColor];
        timelabel.font=[UIFont systemFontOfSize:14];
        timelabel.textAlignment=NSTextAlignmentRight;
        [cell.contentView addSubview:timelabel];
        [timelabel release];
        
        UIImageView *image_1_view=[[UIImageView alloc]initWithFrame:CGRectMake(15, 55, 55, 60)];
        image_1_view.tag=5;
        // image_1_view.image=[StringUtil getImageByResName:@"logo_about.png"];
        [cell.contentView addSubview:image_1_view];
        [image_1_view release];
        
        UIImageView *image_2_view=[[UIImageView alloc]initWithFrame:CGRectMake(75, 55, 55, 60)];
        image_2_view.tag=6;
        // image_2_view.image=[StringUtil getImageByResName:@"logo_about.png"];
        [cell.contentView addSubview:image_2_view];
        [image_2_view release];
        
        UIImageView *image_3_view=[[UIImageView alloc]initWithFrame:CGRectMake(135, 55, 55, 60)];
        image_3_view.tag=7;
        // image_3_view.image=[StringUtil getImageByResName:@"logo_about.png"];
        [cell.contentView addSubview:image_3_view];
        [image_3_view release];
        
        UIImageView *image_4_view=[[UIImageView alloc]initWithFrame:CGRectMake(195, 55, 55, 60)];
        image_4_view.tag=8;
        // image_4_view.image=[StringUtil getImageByResName:@"logo_about.png"];
        [cell.contentView addSubview:image_4_view];
        [image_4_view release];
        
        UIImageView *image_5_view=[[UIImageView alloc]initWithFrame:CGRectMake(255, 55, 55, 60)];
        image_5_view.tag=9;
        //image_5_view.image=[StringUtil getImageByResName:@"logo_about.png"];
        [cell.contentView addSubview:image_5_view];
        [image_5_view release];
        
        UIButton *see_pic_button=[[UIButton alloc]initWithFrame:CGRectMake(15, 55, 290, 60)];
        see_pic_button.tag=10;
        [see_pic_button addTarget:self action:@selector(see_pic_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:see_pic_button];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *upload_id_label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        upload_id_label.tag=11;
        upload_id_label.hidden=YES;
        [see_pic_button addSubview:upload_id_label];
        [upload_id_label release];
        [see_pic_button release];
        
        //        UIButton *cancelButton=[[UIButton alloc]initWithFrame:CGRectMake(265, 10, 45, 29)];
        //        cancelButton.tag=12;
        //        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        //        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        //        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        //        cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
        //        cancelButton.layer.borderColor=[UIColor blueColor].CGColor;
        //        cancelButton.layer.borderWidth=1;
        //        cancelButton.backgroundColor=[UIColor grayColor];
        //        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        //        [cell.contentView addSubview:cancelButton];
        //        [cancelButton release];
        //        cancelButton.hidden=YES;
        
        UIButton *modifyButton=[[UIButton alloc]initWithFrame:CGRectMake(15, 10, 290, 29)];
        modifyButton.tag=13;
        // [modifyButton setTitle:@"修改" forState:UIControlStateNormal];
        //       [modifyButton setImage:[StringUtil getImageByResName:@"sxuan_up.png"] forState:UIControlStateNormal];
        //        [modifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [modifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        //        [modifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        modifyButton.titleLabel.font=[UIFont systemFontOfSize:14];
        //        modifyButton.layer.borderColor=[UIColor blueColor].CGColor;
        //        modifyButton.layer.borderWidth=1;
        //        modifyButton.backgroundColor=[UIColor grayColor];
        [modifyButton addTarget:self action:@selector(modifyAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:modifyButton];
        [modifyButton release];
        modifyButton.hidden=YES;
        
        
        UIImageView*modify_icon=[[UIImageView alloc]initWithFrame:CGRectMake([UIAdapterUtil getTableCellContentWidth] - 50, 7, 15, 15)];
        modify_icon.image=[StringUtil getImageByResName:@"sxuan_up.png"];
        [modifyButton addSubview:modify_icon];
        [modify_icon release];
        
        UILabel *modifyLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        modifyLabel.hidden=YES;
        modifyLabel.tag=14;
        [modifyButton addSubview:modifyLabel];
        [modifyLabel release];
        
        
    }
    
    if (indexPath.section==0) {
        UIImageView *image_backgroud_view=(UIImageView *)[cell viewWithTag:1];
        UIImageView *image_icon_view=(UIImageView *)[cell viewWithTag:2];
        UILabel *titlelabel=(UILabel *)[cell viewWithTag:3];
        UILabel *timelabel=(UILabel *)[cell viewWithTag:4];
        timelabel.textAlignment=NSTextAlignmentLeft;
        UIImageView *image_1_view=(UIImageView *)[cell viewWithTag:5];
        UIImageView *image_2_view=(UIImageView *)[cell viewWithTag:6];
        UIImageView *image_3_view=(UIImageView *)[cell viewWithTag:7];
        UIImageView *image_4_view=(UIImageView *)[cell viewWithTag:8];
        UIImageView *image_5_view=(UIImageView *)[cell viewWithTag:9];
        
        UIButton *see_pic_button=(UIButton *)[cell viewWithTag:10];
        UILabel *upload_id_label=(UILabel *)[see_pic_button viewWithTag:11];
        // UIButton *cancelButton=(UIButton *)[cell viewWithTag:12];
        UIButton *modifyButton=(UIButton *)[cell viewWithTag:13];
        UILabel *modifyLabel=(UILabel *)[modifyButton viewWithTag:14];
        // cancelButton.hidden=YES;
        modifyButton.hidden=YES;
        kapokUploadEventObject *kapokObject=[self.readyArray objectAtIndex:indexPath.row];
        titlelabel.text=kapokObject.show_str;
        timelabel.text=[StringUtil getDisplayTime:kapokObject.create_time];
        upload_id_label.text=kapokObject.upload_id;
        modifyLabel.text=kapokObject.upload_id;
        
        if (kapokObject.upload_state==1||kapokObject.upload_state==2) {
            image_backgroud_view.image=[StringUtil getImageByResName:@"fly_blue.png"];
            image_icon_view.image=[StringUtil getImageByResName:@"fly_ing.png"];
            if (kapokObject.upload_state==1) {
                timelabel.text=@"正在等待上传...";
                timelabel.textColor=[UIColor blackColor];
                
            }else
            {
                timelabel.text=@"正在上传";
                timelabel.textColor=[UIColor blackColor];
                //     cancelButton.hidden=NO;
                
                [cell addSubview:webView];
            }
            
        }else if(kapokObject.upload_state==3)
        {
            image_backgroud_view.image=[StringUtil getImageByResName:@"fly_red.png"];
            image_icon_view.image=[StringUtil getImageByResName:@"fly_error.png"];
            timelabel.text=@"上传失败";
            timelabel.textColor=[UIColor redColor];
            modifyButton.hidden=NO;
            
        }
        
        NSString *picname_1=[NSString stringWithFormat:@"%@_icon_0.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_1 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_1];
        
        NSData *data=[NSData dataWithContentsOfFile:picpath_1];
        image_1_view.image=[UIImage imageWithData:data];
        
        NSString *picname_2=[NSString stringWithFormat:@"%@_icon_1.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_2 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_2];
        
        data=[NSData dataWithContentsOfFile:picpath_2];
        image_2_view.image=[UIImage imageWithData:data];
        
        NSString *picname_3=[NSString stringWithFormat:@"%@_icon_2.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_3 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_3];
        
        data=[NSData dataWithContentsOfFile:picpath_3];
        image_3_view.image=[UIImage imageWithData:data];
        
        NSString *picname_4=[NSString stringWithFormat:@"%@_icon_3.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_4 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_4];
        
        data=[NSData dataWithContentsOfFile:picpath_4];
        image_4_view.image=[UIImage imageWithData:data];
        
        NSString *picname_5=[NSString stringWithFormat:@"%@_icon_4.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_5 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_5];
        
        data=[NSData dataWithContentsOfFile:picpath_5];
        image_5_view.image=[UIImage imageWithData:data];
    }else
    {
        UIImageView *image_backgroud_view=(UIImageView *)[cell viewWithTag:1];
        UIImageView *image_icon_view=(UIImageView *)[cell viewWithTag:2];
        UILabel *titlelabel=(UILabel *)[cell viewWithTag:3];
        UILabel *timelabel=(UILabel *)[cell viewWithTag:4];
        timelabel.textAlignment=NSTextAlignmentRight;
        timelabel.textColor=[UIColor blackColor];
        UIImageView *image_1_view=(UIImageView *)[cell viewWithTag:5];
        UIImageView *image_2_view=(UIImageView *)[cell viewWithTag:6];
        UIImageView *image_3_view=(UIImageView *)[cell viewWithTag:7];
        UIImageView *image_4_view=(UIImageView *)[cell viewWithTag:8];
        UIImageView *image_5_view=(UIImageView *)[cell viewWithTag:9];
        
        UIButton *see_pic_button=(UIButton *)[cell viewWithTag:10];
        UILabel *upload_id_label=(UILabel *)[see_pic_button viewWithTag:11];
        //  UIButton *cancelButton=(UIButton *)[cell viewWithTag:12];
        UIButton *modifyButton=(UIButton *)[cell viewWithTag:13];
        UILabel *modifyLabel=(UILabel *)[modifyButton viewWithTag:14];
        //   cancelButton.hidden=YES;
        modifyButton.hidden=YES;
        
        image_backgroud_view.image=[StringUtil getImageByResName:@"fly_gray.png"];
        image_icon_view.image=[StringUtil getImageByResName:@"fly_2.png"];
        
        kapokUploadEventObject *kapokObject=[self.dataArray objectAtIndex:indexPath.row];
        titlelabel.text=kapokObject.show_str;
        timelabel.text=[StringUtil getDisplayTime:kapokObject.create_time];
        upload_id_label.text=kapokObject.upload_id;
        
        NSString *picname_1=[NSString stringWithFormat:@"%@_icon_0.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_1 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_1];
        
        NSData *data=[NSData dataWithContentsOfFile:picpath_1];
        image_1_view.image=[UIImage imageWithData:data];
        
        NSString *picname_2=[NSString stringWithFormat:@"%@_icon_1.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_2 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_2];
        
        data=[NSData dataWithContentsOfFile:picpath_2];
        image_2_view.image=[UIImage imageWithData:data];
        
        NSString *picname_3=[NSString stringWithFormat:@"%@_icon_2.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_3 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_3];
        
        data=[NSData dataWithContentsOfFile:picpath_3];
        image_3_view.image=[UIImage imageWithData:data];
        
        NSString *picname_4=[NSString stringWithFormat:@"%@_icon_3.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_4 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_4];
        
        data=[NSData dataWithContentsOfFile:picpath_4];
        image_4_view.image=[UIImage imageWithData:data];
        
        NSString *picname_5=[NSString stringWithFormat:@"%@_icon_4.jpg",kapokObject.upload_id];
        //存入本地
        NSString *picpath_5 = [[StringUtil newKapokPath] stringByAppendingPathComponent:picname_5];
        
        data=[NSData dataWithContentsOfFile:picpath_5];
        image_5_view.image=[UIImage imageWithData:data];
        
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	
}
//修改删除按钮的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
        return YES;
    }else
    {
        if (indexPath.row<[self.readyArray count]) {
            kapokUploadEventObject *kapokObject=[self.readyArray objectAtIndex:indexPath.row];
            if (kapokObject.upload_state==2) {
                return NO;
            }
            return YES;
        }
        return NO;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
        if (indexPath.section==0) {
            
            kapokUploadEventObject *kapokObject=[self.readyArray objectAtIndex:indexPath.row];
            [[KapokDAO getDatabase]deleteOneUpload:kapokObject.upload_id];
            [self.readyArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
            
            
        }else
        {
            kapokUploadEventObject *kapokObject=[self.dataArray objectAtIndex:indexPath.row];
            [[KapokDAO getDatabase]deleteOneUpload:kapokObject.upload_id];
            
            [self.dataArray removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
        int count=[self.readyArray count]+[self.dataArray count];
        NoPhotoTipLabel.hidden=YES;
        if (count==0) {
            NoPhotoTipLabel.hidden=NO;
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {//顶部下拉
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{//底部上拖
	//pageControl.currentPage=scrollView.contentOffset.x/320;
    CGPoint contentOffsetPoint = scrollView.contentOffset;
    CGRect frame = kapokUploadTable.frame;
    if (contentOffsetPoint.y == kapokUploadTable.contentSize.height - frame.size.height)
    {
        NSLog(@"scroll to the end");
        [self getHistoryRecord];
        
    }
}
#pragma mark 获取该会话的聊天记录
-(void)getKapokUploadNewest
{
	totalCount =  [[KapokDAO getDatabase] getKapokUploadEventCount];
    
	if(totalCount > num_kapok_uploadevent)
	{
        kapokUploadTable.tableFooterView=tipLabel;
		limit = num_kapok_uploadevent;
		offset = 0;
	}
	else {
		limit = totalCount;
		offset = 0;
	}
    NSArray *array=[[KapokDAO getDatabase] getKapokUploadEventByLimit:limit andOffset:offset];
	[self.dataArray addObjectsFromArray:array];
    
}
- (void)getHistoryRecord
{    //	总数量
	totalCount =  [[KapokDAO getDatabase] getKapokUploadEventCount];
    //已经加载数量
	loadCount = self.dataArray.count;
    
    if (totalCount - loadCount<=0) {
        kapokUploadTable.tableFooterView=nil;
        return;
    }
	if(totalCount > (loadCount + num_kapok_uploadevent))
	{
		limit = num_kapok_uploadevent;
		offset = loadCount;
	}
	else
	{
		limit =totalCount - loadCount;
		offset = loadCount;
	}
    
    NSArray *array=[[KapokDAO getDatabase] getKapokUploadEventByLimit:limit andOffset:offset];
	[self.dataArray addObjectsFromArray:array];
    [kapokUploadTable reloadData];
}

//上传图片
// Token
-(void)getToken
{
    kapokObjectForUploading=[[KapokDAO getDatabase]getKapokUploadingEvent];
    if (kapokObjectForUploading==nil) {
        webView.hidden=YES;
        return ;
    }
    webView.hidden=NO;
    NSArray *pic_array= [[KapokDAO getDatabase]getKapokNoUploadImageInfoBy:kapokObjectForUploading.upload_id];
    if ([pic_array count]==0) {
        [self check_is_sucess];
        return;
    }
    NSString *selected_date=kapokObjectForUploading.selected_date;
    selected_date = [selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    // NSLog(@"---selected_date-- %@",selected_date);
    NSString *flight_num=kapokObjectForUploading.flight_num;
    NSString *airport_num=kapokObjectForUploading.start_airport;
    NSString *boardin_num=kapokObjectForUploading.boarding_num;
    NSString *emp_code=kapokObjectForUploading.emp_code;
    
    if (networkQueueForImage==nil) {
        
        networkQueueForImage = [[ASINetworkQueue alloc] init];
        
        [networkQueueForImage reset];
        
        //下载队列代理方法
        
        [networkQueueForImage setRequestDidFailSelector:@selector(singleuploadFail:)];
        
        [networkQueueForImage setRequestDidFinishSelector:@selector(singleuploadFinished:)];
        
        // [networkQueueForImage setRequestDidReceiveResponseHeadersSelector:@selector(uploadReceiveResponseHeader:)];
        
        // [networkQueueForImage setRequestDidStartSelector:@selector(singleUploadStart:)];
        
        [networkQueueForImage setQueueDidFinishSelector:@selector(uploadFinish:)];
        
        [networkQueueForImage setDelegate:self];
        
        
        [networkQueueForImage setMaxConcurrentOperationCount:1];
    }
    
    if (networkQueueForImage.requestsCount>0)
    {//正在上传，不必重复
        return;
    }
    
    for (int i=0; i<[pic_array count]; i++) {

        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        kapokImageObject *kapok_object=[pic_array objectAtIndex:i];
        int start_upload_index=kapok_object.upload_start_index;
                //存入本地
        NSString *picpath = kapok_object.image_path;
        NSData *data=[NSData dataWithContentsOfFile:picpath];
        NSString*  exestr = [picpath lastPathComponent];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s imageToken is %@",__FUNCTION__,kapok_object.image_token]];
        
        if (kapok_object.image_token.length==0) {//需要获取token
            
            NSString *imageHash=[StringUtil getFileMD5WithPath:picpath];
            NSString * upload_picname=[NSString stringWithFormat:@"%@_%d.jpg",emp_code,i];
            NSString *json_str=[NSString stringWithFormat:@"{\"flightdate\":\"%@\",\"flightno\":\"%@\",\"boardingno\":\"%@\",\"filelength\":%d,\"filemd5\":\"%@\",\"filename\":\"%@\"}",selected_date,flight_num,boardin_num,data.length,imageHash,upload_picname];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s json4: %@",__FUNCTION__,json_str]];
            //
            //    NSString *file_len=[NSString stringWithFormat:@"%d",data.length];
            //使用post方法请求http
            NSString *token_url=[NSString stringWithFormat:@"%@/token",kapod_file_server];
            NSURL *url = [NSURL URLWithString:token_url];
            NSError *error;
            
            NSData *testData = [json_str dataUsingEncoding: NSUTF8StringEncoding];
            // Byte *testByte = (Byte *)[testData bytes];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            //    [request setDelegate:self];
            [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
            [request addRequestHeader:@"Accept" value:@"application/json"];
            [request setRequestMethod:@"POST"];
            [request setPostBody:testData];
            //    [request setDidFinishSelector:@selector(tokenComplete:)];
            //    [request setDidFailSelector:@selector(tokenFail:)];
            //    [request startAsynchronous];
            //    [request setTimeOutSeconds:15];
            [request startSynchronous];
            
            NSError *error1 = [request error];
            NSString *response=nil;
            
            if (!error1) {
                int statuscode=[request responseStatusCode];
                if (statuscode==200) {
                    NSString* temp_response = [request responseString];
                    NSDictionary *dic=[temp_response objectFromJSONString];
                    response=[dic objectForKey:@"result"];
                    kapok_object.image_token=response;
                    NSLog(@"--here---Token：%@",response);
                    [[KapokDAO getDatabase]updateKapodUploadToken:kapokObjectForUploading.upload_id andPicName:exestr andToken:response];//设置图片token
                }
            }
            if (response==nil) {
                NSLog(@"-token----error1：%@",error1);
                webView.hidden=YES;
                [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:3];//设置上传失败
                [self.readyArray removeAllObjects];
                NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
                [self.readyArray addObjectsFromArray:array];
                [kapokUploadTable reloadData];
                return;
            }
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 开始上传位置%d 原始文件长度%d",__FUNCTION__,start_upload_index,data.length]];
        
        if (start_upload_index<=0) {
            start_upload_index=0;
        }else
        {
            data=[data subdataWithRange:NSMakeRange(start_upload_index, data.length-start_upload_index)];
        }
        
        NSString *data_len=[NSString stringWithFormat:@"%d",data.length];
        NSString *start_dot=[NSString stringWithFormat:@"%d",start_upload_index];
        
        NSString *upload_url=[NSString stringWithFormat:@"%@/upload",kapod_file_server];
        NSURL *dataurl = [NSURL URLWithString:upload_url];
        ASIFormDataRequest *datarequest = [[ASIFormDataRequest alloc]initWithURL:dataurl];
        [datarequest setDelegate:self];
        [datarequest addRequestHeader:@"Content-Length" value:data_len];
        [datarequest addRequestHeader:@"Content-Type" value:@"application/octet-stream"];
        [datarequest addRequestHeader:@"Upload-Token" value:kapok_object.image_token];
        [datarequest addRequestHeader:@"Content-Offset" value:start_dot];
        [datarequest setRequestMethod:@"POST"];
        
        NSDictionary *data_dic=[NSDictionary dictionaryWithObjectsAndKeys:kapokObjectForUploading.upload_id,@"upload_id",exestr,@"pic_name", nil];
        [datarequest setUserInfo:data_dic];
        [datarequest setPostBody:data];
        [datarequest setTimeOutSeconds:[StringUtil getRequestTimeout]];
        [datarequest setNumberOfTimesToRetryOnTimeout:3];
        datarequest.shouldContinueWhenAppEntersBackground = YES;
        
        [LogUtil debug:[NSString stringWithFormat:@"%s content-length is %@ , content-offset is %@ ,data len is %d ",__FUNCTION__,data_len,start_dot,data.length]];
        
        [networkQueueForImage addOperation:datarequest];
        
        [datarequest release];
        
    }
    [networkQueueForImage go];
    
}
-(void)tokenComplete:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--tokenComplete- %d  --response-- %@",statuscode,response);
}
-(void)tokenFail:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--tokenFail- %d  --response-- %@",statuscode,response);
}

#pragma mark 队列处理
-(void)singleuploadFail:(ASIHTTPRequest *)request
{
    NSLog(@"%s,%@",__FUNCTION__,request.error.domain);
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    webView.hidden=YES;
    [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:3];//设置上传失败
    [self.readyArray removeAllObjects];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
    [self.readyArray addObjectsFromArray:array];
    [kapokUploadTable reloadData];
}
-(void)singleuploadFinished:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    NSString* temp_response = [request responseString];
    NSDictionary *dic_info=[temp_response objectFromJSONString];
    int response=[[dic_info objectForKey:@"result"]intValue];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,%d,%d",__FUNCTION__,statuscode,response]];
    
    if (statuscode==200) {
        if (response==10000) {//成功
            NSDictionary *dic=[request userInfo];
            NSString *pic_name=[dic objectForKey:@"pic_name"];
            NSString *upload_id=[dic objectForKey:@"upload_id"];
            [LogUtil debug:[NSString stringWithFormat:@"---%@上传成功",pic_name]];
            [[KapokDAO getDatabase]updateKapodUploadState:upload_id andPicName:pic_name andState:0];//设置图片上传成功
            return;
        }else if(response==10001) {//MD5不匹配
            [LogUtil debug:@"---MD5不匹配"];
        }else if(response==10002) {//文件接收长度大于文件长度
            [LogUtil debug:@"---文件接收长度大于文件长度"];
        }
        else if(response==10003) {//文件接收长度小于文件长度
            [LogUtil debug:@"---文件接收长度小于文件长度"];
        }
    }
    //失败
    if (!webView.hidden) {
        
        webView.hidden=YES;
        [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:3];//设置上传失败
        [self.readyArray removeAllObjects];
        NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
        [self.readyArray addObjectsFromArray:array];
        [kapokUploadTable reloadData];
    }
    
    
}
-(void)uploadReceiveResponseHeader:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--uploadReceiveResponseHeader-statuscode- %d  --response-- %@",statuscode,response);
}
-(void)singleUploadStart:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--singleUploadStart-statuscode- %d  --response-- %@",statuscode,response);
}

-(void)uploadFinish:(ASINetworkQueue *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    NSArray *pic_array= [[KapokDAO getDatabase]getKapokNoUploadImageInfoBy:kapokObjectForUploading.upload_id];
    if ([pic_array count]==0) {
        [self check_is_sucess];
    }
}


#pragma mark token成功处理
-(void)getTokenComplete:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--getTokenComplete-statuscode- %d  --response-- %@",statuscode,response);
}
#pragma mark token失败处理
-(void)getTokenFail:(ASIHTTPRequest *)request
{
    int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    NSLog(@"--getTokenFail--statuscode- %d  --response-- %@",statuscode,response);
}
#pragma mark 上传文件成功处理
-(void)uploadFileComplete:(ASIHTTPRequest *)request
{
	int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    
    NSLog(@"--uploadFileComplete-statuscode- %d  --response-- %@",statuscode,response);
}
#pragma mark 上传文件失败处理
-(void)uploadFileFail:(ASIHTTPRequest *)request
{
    int statuscode=[request responseStatusCode];
    
    NSString* response = [request responseString];
    NSLog(@"--uploadFileFail-statuscode- %d  --response-- %@",statuscode,response);
}

-(void)check_is_sucess
{
    NSArray *pic_array= [[KapokDAO getDatabase]getKapokUploadImageListPathBy:kapokObjectForUploading.upload_id];
    NSString *selected_date=kapokObjectForUploading.selected_date;
    selected_date = [selected_date stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    // NSLog(@"---selected_date-- %@",selected_date);
    NSString *flight_num=kapokObjectForUploading.flight_num;
    NSString *airport_num=kapokObjectForUploading.start_airport;
    NSString *boardin_num=kapokObjectForUploading.boarding_num;
    NSString *emp_code=kapokObjectForUploading.emp_code;
    
    
    NSString *images=@"";
    int count=[pic_array count];
    for (int i=0; i<count; i++) {
        
        NSString *image_str=[NSString stringWithFormat:@"%@_%d.jpg",emp_code,i];;
        if (i==0) {
            images=[NSString stringWithFormat:@"\"%@\"",image_str];
        }else
        {
            images=[NSString stringWithFormat:@"%@,\"%@\"",images,image_str];
        }
    }
    
    NSString *json_str=[NSString stringWithFormat:@"{\"flightdate\":\"%@\",\"flightno\":\"%@\",\"boardingno\":\"%@\",\"depairport\":\"%@\",\"opid\":\"%@\",\"images\":[%@]}",selected_date,flight_num,boardin_num,airport_num,emp_code,images];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s -check-json-%@",__FUNCTION__,json_str]];
    //
    //    NSString *file_len=[NSString stringWithFormat:@"%d",data.length];
    //使用post方法请求http
    NSString *verifyimages_url=[NSString stringWithFormat:@"%@/verifyimages",kapod_file_server];
    NSURL *url = [NSURL URLWithString:verifyimages_url];
      
    NSError *error;
    
    NSData *testData = [json_str dataUsingEncoding: NSUTF8StringEncoding];
    // Byte *testByte = (Byte *)[testData bytes];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:[StringUtil getRequestTimeout]];
    [request setPostBody:testData];
    [request setDidFinishSelector:@selector(checkComplete:)];
    [request setDidFailSelector:@selector(checkFail:)];
    [request startAsynchronous];
    //    [request startSynchronous];
    //    NSError *error1 = [request error];
    //    NSString *response=nil;
    //
    //    if (!error1) {
    //        response = [request responseString];
    //
    //        NSLog(@"－－－－response－%@",response);
    //        [self checkComplete:response];
    //    }else
    //    {   NSLog(@"－－－－error1－%@",error1);
    //        [self checkFail:response];
    //    }
    
}
-(void)testSucess
{
    NSLog(@"－－－testSucess－－校验正确");
    [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:0];//设置上传成功
    [[KapokDAO getDatabase] startNextUploading];//开启下一个上传
    
    [self.readyArray removeAllObjects];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
    [self.readyArray addObjectsFromArray:array];
    
    [self.dataArray removeAllObjects];
    [self getKapokUploadNewest];
    
    kapokUploadTable.contentOffset=CGPointMake(0, 0);
    
    [kapokUploadTable reloadData];
    
    [self getToken];
}
#pragma mark 上传文件成功处理
-(void)checkComplete:(ASIHTTPRequest *)request
{
    int statuscode=[request responseStatusCode];
    
    NSString* temp_response = [request responseString];
    NSDictionary *dic=[temp_response objectFromJSONString];
    NSString* response=[dic objectForKey:@"result"];

    [LogUtil debug:[NSString stringWithFormat:@"%s statusCode is %d response is %@",__FUNCTION__,statuscode,response]];

    if (statuscode==200)
    {
        NSString *responseStr = @"";
        if ([response isEqualToString:@"000"]) {//校验正确
            responseStr = @"校验正确";
            [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:0];//设置上传成功
            [[KapokDAO getDatabase] startNextUploading];//开启下一个上传
            
            [self.readyArray removeAllObjects];
            NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
            [self.readyArray addObjectsFromArray:array];
            
            [self.dataArray removeAllObjects];
            [self getKapokUploadNewest];
            
            kapokUploadTable.contentOffset=CGPointMake(0, 0);
            
            [kapokUploadTable reloadData];
            
            [self getToken];
            
            return;
        }else if([response isEqualToString:@"001"]) {//单个服务点只能上传1次
            responseStr = @"单个服务点只能上传1次";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"单个服务点只能上传1次" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"002"]) {//每次上传图片总数超出5张
            responseStr = @"每次上传图片总数超出5张";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"每次上传图片总数超出5张" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"003"]) {//校验失败，图片路径无效
            responseStr = @"校验失败，图片路径无效";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"校验失败，图片路径无效" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"004"]) {//检验失败，图片数量不符
            responseStr = @"检验失败，图片数量不符";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"检验失败，图片数量不符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"005"]) {//图片大小不能超过500kb
            responseStr = @"图片大小不能超过500kb";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"图片大小不能超过500kb" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"006"]) {//图片格式必须为jpg
            responseStr = @"图片格式必须为jpg";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"图片格式必须为jpg" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else if([response isEqualToString:@"007"]) {//校验失败，系统异常
            responseStr = @"校验失败，系统异常";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"校验失败，系统异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        [LogUtil debug:[NSString stringWithFormat:@"%s response is %@",__FUNCTION__,responseStr]];

    }
    webView.hidden=YES;
    //失败处理
    [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:3];//设置上传失败
    [self.readyArray removeAllObjects];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
    [self.readyArray addObjectsFromArray:array];
    [kapokUploadTable reloadData];
    
}
#pragma mark 上传文件失败处理
-(void)checkFail:(ASIHTTPRequest *)request
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    webView.hidden=YES;
    [[KapokDAO getDatabase]updateKapodUploadState:kapokObjectForUploading.upload_id andState:3];//设置上传失败
    [self.readyArray removeAllObjects];
    NSArray *array=[[KapokDAO getDatabase] getReadyForUploadEvent];
    [self.readyArray addObjectsFromArray:array];
    [kapokUploadTable reloadData];
}


@end
