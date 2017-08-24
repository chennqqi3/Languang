//
//  broadcastRecordMemberViewController.m
//  eCloud
//
//  Created by  lyong on 14-1-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "broadcastRecordMemberViewController.h"
#import "eCloudUser.h"
#import "eCloudDefine.h"
#import "ImageUtil.h"
#import "StringUtil.h"
#import "broadcastRecoredMoreMemberViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MassDAO.h"
#import "ImageSet.h"
#import "talkSessionViewController.h"
#import "UserDisplayUtil.h"
#import "EmpCell.h"
#import "UIAdapterUtil.h"
#import "ImageUtil.h"
#import "MessageView.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "IOSSystemDefine.h"
#import "Dept.h"
#import "Emp.h"
#import "ConvRecord.h"

@interface broadcastRecordMemberViewController ()
{
    NSArray *emps_Array;
    NSMutableArray *otheremps_Array;
    MassDAO *massDAO;
    //是否刷新
	bool isFresh;
    int other_num;
    int all_unread_num;
    talkSessionViewController *talkSession;
    int show_type;
}
@property(assign)int show_type;
@property(assign)int other_num;
@property(assign)int all_unread_num;
@property(retain)NSArray *emps_Array;
@property(retain)NSMutableArray *otheremps_Array;
@property(nonatomic,retain)MassDAO *massDAO;
@property(nonatomic,retain)talkSessionViewController *talkSession;
@end

@implementation broadcastRecordMemberViewController
@synthesize emps_Array;
@synthesize massDAO;
@synthesize otheremps_Array;
@synthesize other_num;
@synthesize all_unread_num;
@synthesize record_id;
@synthesize conv_id;
@synthesize talkSession;
@synthesize msg_id;
@synthesize show_type;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//返回 按钮
-(void) backButtonPressed:(id) sender{

	[self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    //适配ios7UIViewController的变化
    [UIAdapterUtil processController:self];
    
    isFresh = false;
    _conn = [conn getConn];
    self.massDAO = [MassDAO getDatabase];
    self.emps_Array=[self.massDAO getEmpsEqAndAboveTreeRankByConvID:self.conv_id andMsgId:self.msg_id];
  //  self.otheremps_Array=[self.massDAO getEmpsEqAndBelowTreeRankByConvID:self.conv_id andMsgId:self.msg_id];
   // self.otheremps_Array=[self.massDAO getEmpsEqAndBelowTreeRankByMsgId:self.msg_id];
    [self.massDAO createTempDeptAndEmpByConvID:self.conv_id andMsgId:self.msg_id];
    self.show_type=0;
    if ([self.emps_Array count]==0) {
      
        BOOL isthesame=[self.massDAO isInTheSameDept];
        if (isthesame) {
          self.show_type=2;
          self.emps_Array=[self.massDAO getEmpsEqAndBelowTreeRankByConvID:self.conv_id andMsgId:self.msg_id];
        }else{
        self.show_type=1;
        self.otheremps_Array=[self.massDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false andMsgId:self.msg_id];
        }
       // self.emps_Array=self.otheremps_Array;
    }else
    {
     self.otheremps_Array=[self.massDAO getTempDeptInfoWithLevel:@"0" andLevel:0 andSelected:false andMsgId:self.msg_id];
      self.other_num=[self.massDAO getBelowThreeEmpNum];
      self.all_unread_num=[self.massDAO getUnReadNumByConvID:self.conv_id andMsgId:self.msg_id];
    }
    if(self.talkSession == nil)
		self.talkSession = [[talkSessionViewController alloc]init];
	// Do any additional setup after loading the view.
     self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

    if(self.show_type!=1){
    //	显示群组成员头像的视图
    memberScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    memberScroll.backgroundColor=[UIColor clearColor];
    [self.view addSubview:memberScroll];
    memberScroll.layer.cornerRadius = 10;//设置那个圆角的有多圆
    // memberScroll.layer.borderWidth = 10;//设置边框的宽度，当然可以不要
    memberScroll.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
    memberScroll.layer.masksToBounds = YES;//设为NO去试试
	NSLog(@"--memberScroll--here--showMemberScrollow");
    //	[NSThread detachNewThreadSelector:@selector(showMemberScrollow) toTarget:self withObject:nil];
    [self showMemberScrollow];
	}
	int tableH = self.view.frame.size.height-45;
	   
    if (self.show_type==0) {
       actionTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,tableH) style:UITableViewStyleGrouped];
    }else
    {
       actionTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,tableH) style:UITableViewStylePlain];
    }
    
    [actionTable setDelegate:self];
    [actionTable setDataSource:self];
    actionTable.backgroundView = nil;
    actionTable.backgroundColor=[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
    [self.view addSubview:actionTable];
    actionTable.backgroundColor=[UIColor clearColor];
    
    actionTable.tableHeaderView=memberScroll;
	
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    
    // 隐藏多余分隔线
    [UIAdapterUtil setExtraCellLineHidden:actionTable];
    [actionTable release];

}
-(void)removeSubviewFromScrollowView
{
    
    for (UIView *eachView in [memberScroll subviews])
    {
        [eachView removeFromSuperview];
        //[eachView release];
    }
    
}

-(void)showMemberScrollow
{
    [self removeSubviewFromScrollowView];//清空后再添加
   
    int showiconNum=4;
    if ( IS_IPHONE_6P) {
        showiconNum = 5;
    }
    
	int sumnum=[self.emps_Array count];

  	//int sumnum=4;
	int pagenum=0;
	if (sumnum%showiconNum!=0) {
		pagenum=sumnum/showiconNum+1;
	}else {
		pagenum=sumnum/showiconNum;
	}
	
	//scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(70, 630, showpageSize-70, 75)];//320
	memberScroll.pagingEnabled = NO;
    memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width , memberScroll.frame.size.height* pagenum);
    memberScroll.showsHorizontalScrollIndicator = YES;
    memberScroll.showsVerticalScrollIndicator = YES;
    memberScroll.scrollsToTop = NO;
    //  musicFirstSrollview.delegate = self;
    
    
	UIButton *pageview;
	
	int nowindex=0;
	
	
    UIView *itemview;
	UIButton *iconbutton;
    UIButton *deletebutton;
    
    UILabel* nameLabel;
    
	int x;
	int y;
	int cx;
	int cy;
	//UIImageView *backView;
	//	for (int i=0; i<pagenum; i++) {
	//float origin_x=5;
	
	pageview=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, memberScroll.frame.size.width, memberScroll.frame.size.height)];
	pageview.backgroundColor=[UIColor clearColor];
    //[pageview addTarget:self action:@selector(onClickForDeleteStatus) forControlEvents:UIControlEventTouchUpInside];
    
	/*
	 CGRect frame = scrollView.frame;
	 frame.origin.x = 0;
	 frame.origin.y = frame.size.height * i;
	 pageview.frame=frame;
	 */
	x=15;
	y=0;
	cx=5;
	cy=0;
    
    int padding = 7; // 间距
    if (IS_IPHONE_6P) {
        padding = 15;
        x = 9;
    }else if(IS_IPHONE_6){
        x = 10;
        padding = 22;
    }else{
        x = 5;
        padding = 12;
    }
    
    int row=0;
	for (int j=0; j<sumnum; j++) {

		nowindex=j;
      //  Emp *emp=[self.dataArray objectAtIndex:j];
		if (j/showiconNum==row) {
            
            cx=cx+60 + padding;
			if (j==0) {
                cx=padding;
            }
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+9+5,60,60)];
            
			
		}else if (j/showiconNum!=row) {
        	
            cx=padding;
            cy=cy+80;
            itemview=[[UIView alloc]initWithFrame:CGRectMake(x+cx+5,y+cy+5+9+5,60,60)];
            
		}
        Emp *emp=[self.emps_Array objectAtIndex:nowindex];
        iconbutton=[[UIButton alloc]initWithFrame:CGRectMake(0,0,60,60)];
        //        iconbutton.layer.cornerRadius = 3;//设置那个圆角的有多圆
        // iconbutton.layer.borderWidth = 3;//设置边框的宽度，当然可以不要
        //iconbutton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
        //        iconbutton.layer.masksToBounds = YES;//设为NO去试试
        nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 60, 60, 20)];
        nameLabel.text=emp.emp_name;
        nameLabel.backgroundColor=[UIColor clearColor];
        nameLabel.font=[UIFont systemFontOfSize:12];
        nameLabel.textAlignment=UITextAlignmentCenter;
		
        if (_conn.userStatus == status_online && (emp.emp_status==status_online||emp.emp_status==status_leave))
        {
			//			[LogUtil debug:[NSString stringWithFormat:@"%s,loginName is %@ loginType is %d",__FUNCTION__,emp.emp_name, emp.loginType]];
			if([UserDisplayUtil isLoginWithCellPhone:emp])
			{
				[LogUtil debug:@"移动端登录，需要显示手机小图标"];
				//	如果是移动端登录，则增加显示手机图标
				UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]]];
				cellPhoneImageView.frame = CGRectMake(45,45,15,15);
				[iconbutton addSubview:cellPhoneImageView];
				[cellPhoneImageView release];
			}
            else
            {
                if(emp.emp_status == status_leave)
                {
                    //                    如果是离开状态，则显示一个离开状态的图标
                    UIImageView *statusLeaveImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"status_leave" andType:@"png"]]];
                    statusLeaveImageView.frame = CGRectMake(45,45,15,15);
                    [iconbutton addSubview:statusLeaveImageView];
                    [statusLeaveImageView release];
                }
            }
            nameLabel.textColor=[UIColor blueColor];
        }
        else
        {
            nameLabel.textColor=[UIColor blackColor];
        }
        [itemview addSubview:iconbutton];
        [itemview addSubview:nameLabel];
        [nameLabel release];
        
        if (true) {
            if (emp.unread>0) {
                deletebutton=[[UIButton alloc]initWithFrame:CGRectMake(60-18,-7,25,25)];
                deletebutton.tag=nowindex;
                [deletebutton setBackgroundImage:[StringUtil getImageByResName:@"app_new_push.png"] forState:UIControlStateNormal];
                [deletebutton setTitle:[NSString stringWithFormat:@"%d",emp.unread] forState:UIControlStateNormal];
                deletebutton.titleLabel.font=[UIFont systemFontOfSize:14];
                [itemview addSubview:deletebutton];
                [deletebutton release];
            }
            
        }

        
		row=j/showiconNum;
		
       	UIImage *image;
        NSString *empLogo = emp.emp_logo;
		if(empLogo && empLogo.length > 0)
		{
            image = [ImageUtil getLogo:emp];
			if(image == nil)
			{
				image = [ImageUtil getDefaultLogo:emp];
				dispatch_queue_t queue = dispatch_queue_create("download_userlogo", NULL);
				dispatch_async(queue, ^{
					NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],empLogo]];
					NSData *imageData = [NSData dataWithContentsOfURL:url];
					UIImage *downloadImage = [UIImage imageWithData:imageData];
					if(downloadImage)
					{
                        //						保存头像之前，先删除原来的头像
						[StringUtil deleteUserLogoIfExist:[StringUtil getStringValue:emp.emp_id]];
						
						NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id ] andLogo:empLogo];
						BOOL success= [imageData writeToFile:logoPath atomically:YES];
						if(!success)
						{
							NSLog(@"save user logo fail");
						}
						
						UIImage *offlineimage=[ImageSet setGrayWhiteToImage:downloadImage];
						NSString *offlinepicPath = [StringUtil getOfflineLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
						NSData *dataObj = UIImageJPEGRepresentation(offlineimage, 1.0);
						BOOL offlinesuccess= [dataObj writeToFile:offlinepicPath atomically:YES];
						if(!offlinesuccess)
						{
							NSLog(@"save user offline logo fail");
						}
						
						if(!isFresh)
						{
							isFresh = true;
						}
						dispatch_async(dispatch_get_main_queue(), ^{
                            //							if(_conn.userStatus == status_online)
                            //							{
                            if (emp.emp_status==status_online||emp.emp_status==status_leave)
                            {
                                [iconbutton setBackgroundImage:downloadImage forState:UIControlStateNormal];
                            }
                            else
                            {
                                
                                [iconbutton setBackgroundImage:offlineimage forState:UIControlStateNormal];
                            }
                            //							}
                            //							else
                            //							{
                            //								[iconbutton setBackgroundImage:offlineimage forState:UIControlStateNormal];
                            //
                            //							}
						});
					}
				});
			}			
		}
		else
		{
			image = [ImageUtil getDefaultLogo:emp];
		}
        
		[iconbutton setBackgroundImage:image forState:UIControlStateNormal];
		iconbutton.tag=nowindex;
		
		iconbutton.backgroundColor=[UIColor clearColor];
		[iconbutton addTarget:self action:@selector(iconbuttonAction:)  forControlEvents:UIControlEventTouchUpInside];
		[pageview addSubview:itemview];
		[iconbutton release];
        
	}

	pageview.frame=CGRectMake(0, 0,memberScroll.frame.size.width,y+cy+115);
	//pageview.backgroundColor=[UIColor clearColor];
	[memberScroll addSubview:pageview];
	memberScroll.contentSize = CGSizeMake(memberScroll.frame.size.width, y+cy+115);
	memberScroll.frame=CGRectMake(0, 0, SCREEN_WIDTH, y+cy+115);
    //    if (self.talkType==singleType) {
    //        titleLabel.text=@"聊天信息";
    //    }else
    //    {
    //        titleLabel.text=[NSString stringWithFormat:@"聊天信息(%d)",[self.dataArray count]];
    //    }

	[pageview release];
    
    actionTable.tableHeaderView=memberScroll;
    //    if (sumnum>8) {
    //        CGPoint bottomOffset = CGPointMake(0, memberScroll.contentSize.height - memberScroll.bounds.size.height);
    //        [memberScroll setContentOffset:bottomOffset animated:YES];
    //    }
    
}
-(void)iconbuttonAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    NSLog(@"---index--%d",button.tag);
     Emp *emp=[self.emps_Array objectAtIndex:button.tag];
    MassDAO *massDAO = [MassDAO getDatabase];
	[massDAO transferMassMsgByMsgId:self.msg_id andEmpId:emp.emp_id andReplyCount:emp.unread];
	self.talkSession.talkType = singleType;
    self.talkSession.titleStr = emp.emp_name;
    self.talkSession.convId =[NSString stringWithFormat:@"%d",emp.emp_id];
    self.talkSession.convEmps = [NSArray arrayWithObject:emp];
    //         self.talkSession.delegete=self;
    self.talkSession.needUpdateTag=1;
	self.talkSession.fromType = 1;
    //			self.talkSession.hidesBottomBarWhenPushed = YES;
    for(UIViewController *controller in self.navigationController.viewControllers)
	{
		if([controller isKindOfClass:[talkSessionViewController class]])
		{
			[self.navigationController popToViewController:talkSession animated:YES];
			return;
		}
	}
    // [self hideTabBar];
    [self.navigationController pushViewController:self.talkSession animated:YES];

}
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{

            id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]])
            {
                int indentation=0;
                indentation=((Emp *)temp).emp_level;
                
                return indentation;
            }else if([temp isKindOfClass:[Dept class]])
            {
                int indentation=0;
                indentation=((Dept *)temp).dept_level;
                
                return indentation;
            }
    
        return 0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.show_type==0) {
        if (self.other_num>0) {
         return 1;
        }
        return 0;
    }else if (self.show_type==1)
    {
        return [self.otheremps_Array count];
    }
	return 0;
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
       id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
   
        if ([temp isKindOfClass:[Dept class]]) {
            return 45;
        }// Configure the cell.
        else {
            return 58;
        }
    

}
#pragma mark 获取员工的显示方式
-(EmpCell *)getEmpCell:(NSIndexPath*)indexPath
{
	static NSString *empCellID = @"empCellID";
	
	EmpCell *empCell = [actionTable dequeueReusableCellWithIdentifier:empCellID];
	if(empCell == nil)
	{
		empCell = [[[EmpCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empCellID]autorelease];
		
		UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
        detailButton.hidden=YES;
        
        UIButton *redButton=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 5, 30, 20)];
        
        redButton.backgroundColor=[UIColor clearColor];
        redButton.tag=emp_red_tag;
        redButton.hidden=YES;
        //onlineLabel.textAlignment=UITextAlignmentCenter;
        redButton.font=[UIFont systemFontOfSize:12];
        [empCell.contentView addSubview:redButton];
        [redButton release];
        
	}
	
	Emp *emp = [self.otheremps_Array objectAtIndex:indexPath.row];
	[empCell configureCell:emp];
    
    UIButton *detailButton = (UIButton*)[empCell viewWithTag:emp_detail_tag];
    UIButton *redButton = (UIButton*)[empCell viewWithTag:emp_red_tag];
    redButton.userInteractionEnabled=NO;
    if (emp.unread>0) {
        redButton.frame=CGRectMake(detailButton.frame.origin.x+15, 5, 30, 20);
      	redButton.hidden=NO;
        UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
        MessageView *messageView = [MessageView getMessageView];
        newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
        [redButton setBackgroundImage:newMsgImage forState:UIControlStateNormal];
        [redButton setTitle:[NSString stringWithFormat:@"%d",emp.unread] forState:UIControlStateNormal];
        
        
    }else
    {
        redButton.hidden=YES;
    }
	return empCell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (self.show_type==0) {
        
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}

        cell.accessoryType	=	UITableViewCellAccessoryDisclosureIndicator;

        UILabel *blacklabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 7.5, SCREEN_WIDTH-30, 30)];
        blacklabel.backgroundColor=[UIColor clearColor];
		blacklabel.textColor=[UIColor blackColor];
        blacklabel.font=[UIFont systemFontOfSize:14];
       
        blacklabel.text =[NSString stringWithFormat:@"查看更多回复者(%d条未读%/%d人)",self.all_unread_num,self.other_num]; //@"查看更多回复者(99)";
        
       
        [cell addSubview:blacklabel];
        [blacklabel release];
    }
    else{
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
          
            UIButton *onlineLabel=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-40, 5, 30, 20)];
            
            onlineLabel.backgroundColor=[UIColor clearColor];
            onlineLabel.tag=1;
            onlineLabel.hidden=YES;
            //onlineLabel.textAlignment=UITextAlignmentCenter;
            onlineLabel.font=[UIFont systemFontOfSize:12];
            [cell.contentView addSubview:onlineLabel];
            [onlineLabel release];

        }
            UIButton *selectButton=(UIButton *)cell.accessoryView;
            selectButton.tag=indexPath.row;
            
            cell.textLabel.font=[UIFont systemFontOfSize:17];
            id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Dept class]]) {
                Dept *dept = (Dept *)temp;
                
                if (dept.isExtended) {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic02.png"];
                }else
                {
                    cell.imageView.image=[StringUtil getImageByResName:@"Arrow_pic01.png"];
                }
                cell.textLabel.text=dept.dept_name;//[NSString stringWithFormat:@"%@ [5/9]",dept.dept_name];;
                cell.selectionStyle = UITableViewCellSelectionStyleNone ;
                if (dept.totalNum) {

                UIButton *onlineLabel=(UIButton *)[cell.contentView viewWithTag:1];
                onlineLabel.hidden=NO;
                UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
                MessageView *messageView = [MessageView getMessageView];
                newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
                newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
                [onlineLabel setBackgroundImage:newMsgImage forState:UIControlStateNormal];
                [onlineLabel setTitle:[NSString stringWithFormat:@"%d",dept.totalNum] forState:UIControlStateNormal];
                    
                }
            }
            else if([temp isKindOfClass:[Emp class]])
            {
             return [self getEmpCell:indexPath];
            }
            
        
        
    }
    
       return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.show_type==0) {
        
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    broadcastRecoredMoreMemberViewController *broadcastRecoredMoreMember=[[broadcastRecoredMoreMemberViewController alloc]init];
    broadcastRecoredMoreMember.msg_id=self.msg_id;
    broadcastRecoredMoreMember.otheremps_Array=self.otheremps_Array;
    [self.navigationController pushViewController:broadcastRecoredMoreMember animated:YES];
    [broadcastRecoredMoreMember release];
    
    }else
    {
        
            id temp=[self.otheremps_Array objectAtIndex:indexPath.row];
            if ([temp isKindOfClass:[Emp class]])
            {
                Emp *emp=(Emp *)temp;
                MassDAO *massDAO = [MassDAO getDatabase];
                [massDAO transferMassMsgByMsgId:self.msg_id andEmpId:emp.emp_id andReplyCount:emp.unread];
                self.talkSession.talkType = singleType;
                self.talkSession.titleStr = emp.emp_name;
                self.talkSession.convId =[NSString stringWithFormat:@"%d",emp.emp_id];
                self.talkSession.convEmps = [NSArray arrayWithObject:emp];
                //         self.talkSession.delegete=self;
                self.talkSession.needUpdateTag=1;
				self.talkSession.fromType = 1;
                //			self.talkSession.hidesBottomBarWhenPushed = YES;
                for(UIViewController *controller in self.navigationController.viewControllers)
                {
                    if([controller isKindOfClass:[talkSessionViewController class]])
                    {
                        [self.navigationController popToViewController:talkSession animated:YES];
                        return;
                    }
                }
                // [self hideTabBar];
                [self.navigationController pushViewController:self.talkSession animated:YES];;
            }else if ([temp isKindOfClass:[Dept class]])
            {
                Dept *dept = (Dept *)temp;
                int level=dept.dept_level+1;
                if (dept.isExtended) { //收起展示
                    dept.isExtended=false;
                    int remvoecount=0;
                    for (int i=indexPath.row+1; i<[self.otheremps_Array count]; i++) {
                        
                        
                        id temp1 = [self.otheremps_Array objectAtIndex:i];
                        
                        if([temp1 isKindOfClass:[Emp class]])
                        {
                            if (((Emp *)temp1).emp_level<=dept.dept_level) {
                                break;
                            }
                        }
                        
                        if([temp1 isKindOfClass:[Dept class]])
                        {
                            if (((Dept *)temp1).dept_level<=dept.dept_level) {
                                break;
                            }
                            
                        }
                        remvoecount++;
                    }
                    if (remvoecount!=0) {
                        NSRange range =NSMakeRange(indexPath.row+1,remvoecount);
                        [self.otheremps_Array removeObjectsInRange:range];
                    }
                    
                    
                }else   //显示子部门及人员
                {
                    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                    float noworigin=cell.frame.origin.y;
                    
                    NSMutableArray *allArray=[[NSMutableArray alloc]init];
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                    NSArray *tempDeptArray=[self.massDAO getTempDeptInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id]  andLevel:level andSelected:dept.isChecked andMsgId:self.msg_id];
                   // if ([dept.subDeptsStr isEqualToString:@"0"]) {
                        NSArray *tempEpArray=[self.massDAO  getTempDeptEmpInfoWithLevel:[NSString stringWithFormat:@"%d",dept.dept_id] andLevel:level andSelected:dept.isChecked andMsgId:self.msg_id];
                        [allArray addObjectsFromArray:tempEpArray];
                   // }
                    
                    [allArray addObjectsFromArray:tempDeptArray];
                    [pool release];
                    NSRange range =NSMakeRange(indexPath.row+1, [allArray count]);
                    [self.otheremps_Array insertObjects:allArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                    [allArray release];
                    
                    dept.isExtended=true;
                    
                    /*自动收起---------------------------------------------------------------bigen------------*/
                    float isExtendedPoint=0;
                    float sumnum=0;
                    for (int i=0; i<[self.otheremps_Array count]; i++) {
                        id temp1 = [self.otheremps_Array objectAtIndex:i];
                        if([temp1 isKindOfClass:[Dept class]])
                        {   Dept*extendedDept=((Dept *)temp1);
                            if (extendedDept.dept_id!=dept.dept_id&&extendedDept.dept_level==dept.dept_level&&extendedDept.isExtended) {
                                NSIndexPath *tempindexpath=[NSIndexPath indexPathForRow:i inSection:0];
                                UITableViewCell *tempcell=[tableView cellForRowAtIndexPath:tempindexpath];
                                isExtendedPoint=tempcell.frame.origin.y;
                                
                                extendedDept.isExtended=false;
                                int remvoecount=0;
                                float emplen=0;
                                float deptlen=0;
                                for (int nowindex=i+1; nowindex<[self.otheremps_Array count]; nowindex++) {
                                    
                                    
                                    id temp1 = [self.otheremps_Array objectAtIndex:nowindex];
                                    
                                    if([temp1 isKindOfClass:[Emp class]])
                                    {
                                        if (((Emp *)temp1).emp_level<=extendedDept.dept_level) {
                                            break;
                                        }
                                        emplen+=58;
                                    }
                                    
                                    if([temp1 isKindOfClass:[Dept class]])
                                    {
                                        if (((Dept *)temp1).dept_level<=extendedDept.dept_level) {
                                            break;
                                        }
                                        deptlen+=42;
                                    }
                                    remvoecount++;
                                }
                                if (remvoecount!=0) {
                                    NSRange range =NSMakeRange(i+1,remvoecount);
                                    [self.otheremps_Array removeObjectsInRange:range];
                                }
                                sumnum=deptlen+emplen;
                                break;
                            }
                            
                        }
                    }
                    
                    [tableView reloadData];
                    
                    //			[LogUtil debug:[NSString stringWithFormat:@" noworigin is %.0f isExtendedPoint is %.0f ,sumnum is %.0f",noworigin,isExtendedPoint,sumnum]];
                    
                    if (isExtendedPoint<noworigin) {
                        float offsetvalue=noworigin-sumnum;
                        if (offsetvalue<0) {
                            offsetvalue=noworigin;
                        }
                        tableView.contentOffset=CGPointMake(0,offsetvalue);NSLog(@"---cell.frame.origin.y-- %0.0f ---isExtendedPoint: %0.0f --sum- %0.0f",noworigin,isExtendedPoint,sumnum);
                    }else{
                        tableView.contentOffset=CGPointMake(0,noworigin);NSLog(@"---cell.frame.origin.y-- %0.0f",noworigin);
                    }
                    
                    
                    
                    //			[LogUtil debug:[NSString stringWithFormat:@"tableView.contentOffset %.0f", tableView.contentOffset.y]];
                    
                    
                    /*自动收起*///---------------------------------------------------------------end------------//
                    //            NSLog(@"---cell.offset-- %0.0f",tableView.contentOffset.y);
                }
                
                [tableView reloadData] ;
            }

    }
    
    
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	if(section == 0)
//		return 18;
//	return 9;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//	return 9;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
