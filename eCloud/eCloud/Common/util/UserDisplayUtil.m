//用来显示用户头像，什么客户端登录，使用什么颜色显示在线

#import "UserDisplayUtil.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "conn.h"
#import "Conversation.h"
#import "PSUtil.h"
#import "PermissionModel.h"
#import "APPUtil.h"
#import "UserInterfaceUtil.h"
#import "MiLiaoUtilArc.h"

@implementation UserDisplayUtil

/** 根据logoview的高度给出一个UIIMageView */
+ (UIImageView *)getUserLogoViewWithLogoHeight:(float)logoHeight{
    
    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
    float logoWidth = (_size.width * logoHeight) / _size.height;
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,logoWidth,logoHeight)];
    
    float logoH = logoView.frame.size.height;
    float logoW = _size.width * logoH / _size.height;
    
    float logoX =   (logoView.frame.size.width - logoW) / 2;
    float logoY = 0;
    
    
    UIImageView *logo = [[[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, logoW, logoH)]autorelease];
    [UIAdapterUtil setCornerPropertyOfView:logo];
    if ([eCloudConfig getConfig].useOriginUserLogo) {
        logo.contentMode = UIViewContentModeScaleAspectFit;
    }

#ifdef _ZHENGRONG_FLAG_
    logo.contentMode = UIViewContentModeScaleAspectFit;
#endif
    logo.tag = 999;
    [logoView addSubview:logo];
    
    [[self class]addLogoTextLabelToLogoView:logo];
    
    if (![eCloudConfig getConfig].needDisplayUserStatus) {
        return [logoView autorelease];
    }
    
    
    //	logoView.contentMode = UIViewContentModeScaleToFill;
    
    //    UIImage *statusImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]];
    
    CGPoint _center = [self getStatusCenterWithLogoView:logoView];
    
    //		增加一个手机在线的imageview，默认是隐藏，用户手机在线时，显示
    UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]]];
    cellPhoneImageView.tag = 1000;
    cellPhoneImageView.center = _center;
    //	cellPhoneImageView.frame = CGRectMake(statusX,statusY,15,15);
    [logoView addSubview:cellPhoneImageView];
    [cellPhoneImageView release];
    
    
    //		增加一个离开状态的imageview，默认是隐藏，当用户是pc离开状态时显示
    UIImageView *statusLeaveImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"status_leave" andType:@"png"]]];
    statusLeaveImageView.tag = 1001;
    statusLeaveImageView.center = _center;
    //	statusLeaveImageView.frame = CGRectMake(statusX,statusY,15,15);
    [logoView addSubview:statusLeaveImageView];
    [statusLeaveImageView release];
    
    //		增加一个pc登录的imageview，默认是隐藏，当用户是pc在线非离开状态时显示
    UIImageView *pcLoginImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"pc_login" andType:@"png"]]];
    pcLoginImageView.tag = 1002;
    pcLoginImageView.center = _center;
    //	pcLoginImageView.frame = CGRectMake(statusX,statusY,15,15);
    [logoView addSubview:pcLoginImageView];
    [pcLoginImageView release];
    
    
    //		增加一个离线的imageview，默认是隐藏，当用户是离线状态时显示
    UIImageView *offLineImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"offline_icon" andType:@"png"]]];
    offLineImageView.tag = 1003;
    offLineImageView.center = _center;
    //	offLineImageView.frame = CGRectMake(statusX,statusY,15,15);
    [logoView addSubview:offLineImageView];
    [offLineImageView release];
    
    return [logoView autorelease];
}


#pragma mark 统一用户头像的显示View
+(UIImageView*)getUserLogoView
{
    return [self getUserLogoViewWithLogoHeight:chatview_logo_size];
}
//{
//    float logoHeight = chatview_logo_size;
//
//    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
//    float logoWidth = (_size.width * logoHeight) / _size.height;
//    
//    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,logoWidth,logoHeight)];
//    
//    float logoH = logoView.frame.size.height;
//    float logoW = _size.width * logoH / _size.height;
//    
//    float logoX =   (logoView.frame.size.width - logoW) / 2;
//    float logoY = 0;
//    
//    UIImageView *logo = [[[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, logoW, logoH)]autorelease];
//    [UIAdapterUtil setCornerPropertyOfView:logo];
//#ifdef _ZHENGRONG_FLAG_
//    logo.contentMode = UIViewContentModeScaleAspectFit;
//#endif
//    logo.tag = 999;
//    [logoView addSubview:logo];
//    
//    if (![eCloudConfig getConfig].needDisplayUserStatus) {
//        return [logoView autorelease];
//    }
//
//    
////	logoView.contentMode = UIViewContentModeScaleToFill;
//    
////    UIImage *statusImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]];
//
//    CGPoint _center = [self getStatusCenterWithLogoView:logoView];
//    
//	//		增加一个手机在线的imageview，默认是隐藏，用户手机在线时，显示
//	UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]]];
//	cellPhoneImageView.tag = 1000;
//    cellPhoneImageView.center = _center;
////	cellPhoneImageView.frame = CGRectMake(statusX,statusY,15,15);
//	[logoView addSubview:cellPhoneImageView];
//	[cellPhoneImageView release];
//    
//    
//    //		增加一个离开状态的imageview，默认是隐藏，当用户是pc离开状态时显示
//	UIImageView *statusLeaveImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"status_leave" andType:@"png"]]];
//	statusLeaveImageView.tag = 1001;
//    statusLeaveImageView.center = _center;
////	statusLeaveImageView.frame = CGRectMake(statusX,statusY,15,15);
//	[logoView addSubview:statusLeaveImageView];
//	[statusLeaveImageView release];
//    
//    //		增加一个pc登录的imageview，默认是隐藏，当用户是pc在线非离开状态时显示
//	UIImageView *pcLoginImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"pc_login" andType:@"png"]]];
//	pcLoginImageView.tag = 1002;
//    pcLoginImageView.center = _center;
////	pcLoginImageView.frame = CGRectMake(statusX,statusY,15,15);
//	[logoView addSubview:pcLoginImageView];
//	[pcLoginImageView release];
//    
//    
//    //		增加一个离线的imageview，默认是隐藏，当用户是离线状态时显示
//	UIImageView *offLineImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"offline_icon" andType:@"png"]]];
//	offLineImageView.tag = 1003;
//    offLineImageView.center = _center;
////	offLineImageView.frame = CGRectMake(statusX,statusY,15,15);
//	[logoView addSubview:offLineImageView];
//	[offLineImageView release];
//    
//	return [logoView autorelease];
//}

+(UIImageView*)getUserChatLogoView
{
    return [self getUserLogoViewWithLogoHeight:chat_user_logo_size];
}
//{
////    高度固定，宽度可以计算
//    float logoHeight = chat_user_logo_size;
//    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
//    float logoWidth = (_size.width * logoHeight) / _size.height;
//
//	UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,logoWidth,logoHeight)];
//    
//    float logoH = logoView.frame.size.height;
//    float logoW = _size.width * logoH / _size.height;
//    
//    float logoX =   (logoView.frame.size.width - logoW) / 2;
//    float logoY = 0;
//    
//    UIImageView *logo = [[[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, logoW, logoH)]autorelease];
//#ifdef _ZHENGRONG_FLAG_
////    默认是正方形头像，但是老头像是长方形
//    logo.contentMode = UIViewContentModeScaleAspectFit;
//#endif
//    [UIAdapterUtil setCornerPropertyOfView:logo];
//    logo.tag = 999;
//    [logoView addSubview:logo];
//
//    if (![eCloudConfig getConfig].needDisplayUserStatus) {
//        return [logoView autorelease];
//    }
//
////    logoView.contentMode = UIViewContentModeScaleToFill;
//	
//    CGPoint _center = [self getStatusCenterWithLogoView:logoView];
//
//	//		增加一个手机在线的imageview，默认是隐藏，用户手机在线时，显示
//	UIImageView *cellPhoneImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"cell_phone" andType:@"png"]]];
//	cellPhoneImageView.tag = 1000;
//    cellPhoneImageView.center = _center;
//	[logoView addSubview:cellPhoneImageView];
//	[cellPhoneImageView release];
//    
//    
//    //		增加一个离开状态的imageview，默认是隐藏，当用户是pc离开状态时显示
//	UIImageView *statusLeaveImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"status_leave" andType:@"png"]]];
//	statusLeaveImageView.tag = 1001;
//    statusLeaveImageView.center = _center;
//	[logoView addSubview:statusLeaveImageView];
//	[statusLeaveImageView release];
//    
//    
//    //		增加一个pc登录的imageview，默认是隐藏，当用户是pc在线非离开状态时显示
//	UIImageView *pcLoginImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"pc_login" andType:@"png"]]];
//	pcLoginImageView.tag = 1002;
//    pcLoginImageView.center = _center;
//	[logoView addSubview:pcLoginImageView];
//	[pcLoginImageView release];
//    
//    //		增加一个离线的imageview，默认是隐藏，当用户是离线状态时显示
//	UIImageView *offLineImageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"offline_icon" andType:@"png"]]];
//	offLineImageView.tag = 1003;
//    offLineImageView.center = _center;
//	[logoView addSubview:offLineImageView];
//	[offLineImageView release];
//    
//	return [logoView autorelease];
//}

#pragma mark 如果用户设置了自己的头像，那么显示自己的头像，否则根据性别显示默认头像，然后再根据在线或离线显示在线或离线头像，还要根据登录客户端类型，确定是否显示手机登录图标
+(void)setUserLogoView:(UIImageView*)logoView andEmp:(Emp*)emp
{
    UIImageView *logo = [logoView viewWithTag:999];
    
    logo.image = [ImageUtil getEmpLogo:emp];
    if ([logo.image isEqual:default_logo_image]) {
        NSDictionary *mDic = [[self class]getUserDefinedLogoDicOfEmp:emp];
        [[self class]setUserDefinedLogo:logo andLogoDic:mDic];
    }else{
        
        [[self class]hideLogoText:logoView];


    }
	[self displayLittleView:logoView andEmp:emp];
}

//增加一个标识，登录用户自己是否需要显示头像
+(void)setUserLogoView:(UIImageView*)logoView andEmp:(Emp*)emp andDisplayCurUserStatus:(BOOL)displayCurUserStatus
{
    UIImageView *logo = [logoView viewWithTag:999];
    logo.image = [ImageUtil getEmpLogo:emp];
    if ([logo.image isEqual:default_logo_image]) {
        NSDictionary *mDic = [[self class]getUserDefinedLogoDicOfEmp:emp];
        [[self class]setUserDefinedLogo:logo andLogoDic:mDic];
    }else{
       
        [[self class]hideLogoText:logoView];

    }
	[self displayLittleView:logoView andEmp:emp andDisplayCurUserStatus:displayCurUserStatus];
}
+ (void)setOnlineUserLogoView:(UIImageView *)logoView andEmp:(Emp *)emp
{
    UIImageView *logo = (UIImageView *)[logoView viewWithTag:999];
    logo.image = [ImageUtil getOnlineEmpLogo:emp];
    
    if ([logo.image isEqual:default_logo_image]) {
        NSDictionary *mDic = [[self class]getUserDefinedLogoDicOfEmp:emp];
        [[self class]setUserDefinedLogo:logo andLogoDic:mDic];
    }else{
        [[self class]hideLogoText:logoView];

    }

    UIImageView *cellPhoneImageView = (UIImageView*)[logoView viewWithTag:1000];
    cellPhoneImageView.hidden = YES;
    
    UIImageView *statusLeaveImageView = (UIImageView*)[logoView viewWithTag:1001];
    statusLeaveImageView.hidden = YES;
    
    UIImageView *pcLoginImageView = (UIImageView*)[logoView viewWithTag:1002];
    pcLoginImageView.hidden = YES;
    
    UIImageView *offLineImageView = (UIImageView*)[logoView viewWithTag:1003];
    offLineImageView.hidden = YES;
}

+(void)displayLittleView:(UIImageView*)logoView andEmp:(Emp*)emp
{
    [self displayLittleView:logoView andEmp:emp andDisplayCurUserStatus:NO];
}

+(void)displayLittleView:(UIImageView*)logoView andEmp:(Emp*)emp andDisplayCurUserStatus:(BOOL)displayCurUserStatus
{
    conn *_conn = [conn getConn];
    
//    如果显示登录用户状态 或者 不显示登录用户状态并且不是当前登录用户则显示状态
    if (displayCurUserStatus || (!displayCurUserStatus && _conn.userId.intValue != emp.emp_id))
    {
        
        UIImageView *cellPhoneImageView = (UIImageView*)[logoView viewWithTag:1000];
        
        UIImageView *statusLeaveImageView = (UIImageView*)[logoView viewWithTag:1001];
        
        UIImageView *pcLoginImageView = (UIImageView*)[logoView viewWithTag:1002];
        
        UIImageView *offLineImageView = (UIImageView*)[logoView viewWithTag:1003];
        
        cellPhoneImageView.hidden = YES;
        statusLeaveImageView.hidden = YES;
        pcLoginImageView.hidden = YES;
        offLineImageView.hidden = YES;
        
        if (emp.permission.hideState) {
            return;
        }
        if (emp.isRobot) {
            return;
        }
        if (emp.emp_status == status_online) {
            if (emp.loginType == TERMINAL_PC) {
                pcLoginImageView.hidden = NO;
            }
            else
            {
                cellPhoneImageView.hidden = NO;
            }
        }
        else if (emp.emp_status == status_leave)
        {
            statusLeaveImageView.hidden = NO;
        }
        else
        {
            offLineImageView.hidden = NO;
        }
    }
}

#pragma mark 判断是否手机登录
+(BOOL)isLoginWithCellPhone:(Emp *)emp
{
    if (emp.permission.hideState || emp.isRobot) {
        return NO;
    }
	if((emp.emp_status == status_online || emp.emp_status == status_leave) && emp.loginType != TERMINAL_PC)
	{
		return YES;
	}
	return NO;
}

#pragma mark 判断是否PC登录
+(BOOL)isLoginWithPC:(Emp *)emp
{
    if (emp.permission.hideState || emp.isRobot) {
        return NO;
    }
	if(emp.emp_status == status_online && emp.loginType == TERMINAL_PC)
	{
		return YES;
	}
	return NO;
}

#pragma mark 如果用户在线，那么名字标签显示蓝色，否则黑色
+(void)setNameColor:(UILabel*)nameLabel andEmpStatus:(int)empStatus
{
    [nameLabel setTextColor:TALKSESSION_SENDER_NAME_COLOR];
    
//	if(empStatus == status_online || empStatus == status_leave)
//	{
//		[nameLabel setTextColor:[UIColor blueColor]];
//	}
//	else
//	{
//		[nameLabel setTextColor:[UIColor blackColor]];
//	}
}


#pragma mark 如果用户在线，那么名字标签显示蓝色，否则黑色
+(void)setNameColor:(UILabel*)nameLabel andEmp:(Emp *)emp
{
    if (emp.permission.hideState || emp.isRobot) {
        return;
    }
    int empStatus = emp.emp_status;
	if(empStatus == status_online || empStatus == status_leave)
	{
		[nameLabel setTextColor:[UIColor blueColor]];
	}
	else
	{
		[nameLabel setTextColor:[UIColor blackColor]];
	}
}

#pragma mark 会话列表界面显示会话logo
+(void)setUserLogoView:(UIImageView*)logoView andConversation:(Conversation*)conv
{
	UIImageView *cellPhoneImageView = (UIImageView*)[logoView viewWithTag:1000];
	
	if(cellPhoneImageView)
	{
		cellPhoneImageView.hidden = YES;
	}
    
    UIImageView *statusLeaveImageView = (UIImageView*)[logoView viewWithTag:1001];
    if(statusLeaveImageView)
    {
        statusLeaveImageView.hidden = YES;
    }
    
    UIImageView *pcLoginImageView = (UIImageView*)[logoView viewWithTag:1002];
    if(pcLoginImageView)
    {
        pcLoginImageView.hidden = YES;
    }
    
    UIImageView *offLineImageView = (UIImageView*)[logoView viewWithTag:1003];
    if(offLineImageView)
    {
        offLineImageView.hidden = YES;
    }
    
	UIImage *image;
	
	switch (conv.recordType)
	{
		case normal_conv_type:
		{
			if (conv.conv_type == singleType || conv.conv_type == rcvMassType)
			{ //单聊
                if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:conv.conv_id])
                {
//                    不再使用生成的马赛克图片
//                    NSString *empId = [[MiLiaoUtilArc getUtil] getEmpIdWithMiLiaoConvId:conv.conv_id];
//                    NSString *imagePath = [StringUtil getProcessLogoFilePathBy:empId andLogo:@"0"];
//                    image = [UIImage imageWithContentsOfFile:imagePath];
//                    if (!image) {
                        image = [ImageUtil getDefaultMiLiaoLogo:conv.emp];
//                    }
                }
                else
                {
                    image = [ImageUtil getEmpLogo:conv.emp];
//         wwwwwwwwwwwww
                    if ([image isEqual:default_logo_image]) {
                        NSDictionary *mDic = [[self class]getUserDefinedLogoDicOfEmp:conv.emp];
                        [[self class]setUserDefinedLogo:logoView andLogoDic:mDic];
                    }else{
                       
                        [[self class]hideLogoText:logoView];
                        
                    }
                    
                }
                if (conv.emp.permission.hideState || conv.emp.isRobot)
                {
                    NSLog(@"设置了状态隐藏");
                }
                else
                {
                    /*
                    if([self isLoginWithCellPhone:conv.emp])
                    {
                        cellPhoneImageView.hidden = NO;
                    }
                    else
                    {
                        if(conv.emp.emp_status == status_leave)
                        {
                            statusLeaveImageView.hidden = NO;
                        }
                    }
                     */
                    
                    if (conv.emp.emp_status == status_online) {
                        if (conv.emp.loginType == TERMINAL_PC) {
                            pcLoginImageView.hidden = NO;
                        }
                        else
                        {
                            cellPhoneImageView.hidden = NO;
                        }
                    }
                    else if (conv.emp.emp_status == status_leave)
                    {
                        statusLeaveImageView.hidden = NO;
                    }
                    else
                    {
                        offLineImageView.hidden = NO;
                    }
                }
			}
			else if(conv.conv_type == mutiableType)//群聊
			{
//                如果是群组那么看是否有合成的群组头像，如果有则使用合成的头像
                if (conv.displayMergeLogo) {
                    image = [UIImage imageWithContentsOfFile:[StringUtil getMergedGroupLogoPathWithName:[StringUtil getDetailMergedGroupLogoName:conv]]];
                }
                else
                {
                    image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"Group_ios" ofType:@"png"]];
                }
			}
            else if(conv.conv_type == fltGroupConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle]pathForResource:@"flt_group_logo" ofType:@"png"]];
            }
			else if (conv.conv_type == serviceConvType)
			{
				image = [PSUtil getServiceLogo:conv.serviceModel];
			}
			else if(conv.conv_type == serviceNotInConvType)
			{
				image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"ps_logo" ofType:@"png"]];
			}
            else if (conv.conv_type == appInConvType)
			{
				image = [APPUtil getAPPLogo:conv.appModel];
			}
            else if (conv.conv_type == broadcastConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"broadcast" ofType:@"png"]];
            }else if (conv.conv_type == imNoticeBroadcastConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"imNotice" ofType:@"png"]];
            }else if (conv.conv_type == appNoticeBroadcastConvType)
            {
                NSString *imageName = @"app_remind";
                
                if ([UIAdapterUtil isGOMEApp]) {
                    imageName = @"gome_app_msg";
                }
                
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:imageName ofType:@"png"]];

            }
			else
			{
				image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"Group_ios" ofType:@"png"]];
			}
		}
			break;
		case flt_group_type:
		{
			image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle]pathForResource:@"flt_group_logo" ofType:@"png"]];
			
		}
			break;
	}
    
	if(image)
	{
        UIImageView *logo = [logoView viewWithTag:999];
        logo.image = image;
	}
}

+(void)setUserLogoView:(UIImageView*)logoView andEmpPermission:(int)permission
{
    
    Conversation *conv = [[Conversation alloc] init];
    conv.emp.permission.isHidden = permission;
    conv.conv_type = singleType;
    [self setUserLogoView:logoView andConversation:conv];
    [conv release];
     
}

//获取 默认 的头像的尺寸 其它地方的尺寸 可以根据 标准的尺寸计算出来
+ (CGSize)getDefaultUserLogoSize
{
    UIImage *image = [StringUtil getImageByResName:@"male.png"];
    if (image) {
        return image.size;
    }
    return CGSizeMake(36.0, 48.0);
//    return image.size;
}


+ (UIImageView *)getSubLogoFromLogoView:(UIImageView *)logoView
{
    UIImageView *logo = (UIImageView *)[logoView viewWithTag:999];
//    NSLog(@"************%@",NSStringFromCGRect(logoView.frame));
    if (logoView.frame.size.height == KEY_THREEUSER_HEIGHT_VALUE) {
        return logoView;
    }
    return logo;
}

+ (UIImage *)getImageWithConv:(Conversation *)conv
{
    UIImage *image;
    
    switch (conv.recordType)
    {
        case normal_conv_type:
        {
            if (conv.conv_type == singleType || conv.conv_type == rcvMassType)
            { //单聊
                if ([[MiLiaoUtilArc getUtil]isMiLiaoConv:conv.conv_id])
                {
//                    NSString *empId = [[MiLiaoUtilArc getUtil] getEmpIdWithMiLiaoConvId:conv.conv_id];
//                    NSString *imagePath = [StringUtil getProcessLogoFilePathBy:empId andLogo:@"0"];
//                    image = [UIImage imageWithContentsOfFile:imagePath];
                    
                    image = [ImageUtil getDefaultMiLiaoLogo:conv.emp];
                }
                else
                {
                    image = [ImageUtil getEmpLogo:conv.emp];
                }
                if (conv.emp.permission.hideState || conv.emp.isRobot)
                {
                    NSLog(@"设置了状态隐藏");
                }
                else
                {
                    
                }
            }
            else if(conv.conv_type == mutiableType)//群聊
            {
                //                如果是群组那么看是否有合成的群组头像，如果有则使用合成的头像
                if (conv.displayMergeLogo) {
                    image = [UIImage imageWithContentsOfFile:[StringUtil getMergedGroupLogoPathWithName:[StringUtil getDetailMergedGroupLogoName:conv]]];
                }
                else
                {
                    image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"Group_ios" ofType:@"png"]];
                }
            }
            else if(conv.conv_type == fltGroupConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle]pathForResource:@"flt_group_logo" ofType:@"png"]];
            }
            else if (conv.conv_type == serviceConvType)
            {
                image = [PSUtil getServiceLogo:conv.serviceModel];
            }
            else if(conv.conv_type == serviceNotInConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"ps_logo" ofType:@"png"]];
            }
            else if (conv.conv_type == appInConvType)
            {
                image = [APPUtil getAPPLogo:conv.appModel];
            }
            else if (conv.conv_type == broadcastConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"broadcast" ofType:@"png"]];
            }else if (conv.conv_type == imNoticeBroadcastConvType)
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"imNotice" ofType:@"png"]];
            }else if (conv.conv_type == appNoticeBroadcastConvType)
            {
                NSString *imageName = @"app_remind";
                
                if ([UIAdapterUtil isGOMEApp]) {
                    imageName = @"gome_app_msg";
                }
                
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:imageName ofType:@"png"]];
                
            }
            else
            {
                image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle] pathForResource:@"Group_ios" ofType:@"png"]];
            }
        }
            break;
        case flt_group_type:
        {
            image = [UIImage imageWithContentsOfFile:[[StringUtil getBundle]pathForResource:@"flt_group_logo" ofType:@"png"]];
            
        }
            break;
    }
    
    return image;
}

/** 根据头像图片的大小，计算状态图片的中心位置 */
+ (CGPoint)getStatusCenterWithLogoView:(UIView *)logoView{
    float logoW = logoView.frame.size.width;
    float logoH = logoView.frame.size.height;
    
    if ([eCloudConfig getConfig].isUserLogoCircle) {
/** 求出对角线长度 */
        float bigC = hypot(logoW,logoW);
        /** 小的对角线长度 */
        float smallC = (bigC - logoW) / 2;
        /** center 的位置 */
        float smallA = sqrt(smallC * smallC * 0.5);

        CGPoint _center = CGPointMake(logoW - smallA, logoW - smallA);
        
        return _center;

    }
    CGPoint _center = CGPointMake(logoW - 3, logoH - 3);
    return _center;
}


//隐藏状态UIView
+ (void)hideStatusView:(UIImageView *)logoView{
    UIImageView *cellPhoneImageView = (UIImageView*)[logoView viewWithTag:1000];
    cellPhoneImageView.hidden = YES;
    
    UIImageView *statusLeaveImageView = (UIImageView*)[logoView viewWithTag:1001];
    statusLeaveImageView.hidden = YES;
    
    UIImageView *pcLoginImageView = (UIImageView*)[logoView viewWithTag:1002];
    pcLoginImageView.hidden = YES;
    
    UIImageView *offLineImageView = (UIImageView*)[logoView viewWithTag:1003];
    offLineImageView.hidden = YES;
}

//获取头像上的文本label
+ (UILabel *)getLogoTextLabelFromLogoView:(UIImageView *)logoView{
    UILabel *_label = (UILabel *)[logoView viewWithTag:logo_text_tag];
    if (logoView.frame.size.height == KEY_THREEUSER_HEIGHT_VALUE) {
//        和原始的logview的尺寸不一样，需要重写
        _label.frame = CGRectMake(0, 0, logoView.frame.size.width, logoView.frame.size.height);
        return _label;
    }
    return _label;
}

/** 隐藏logo文本 */
+ (void)hideLogoText:(UIImageView *)logoView{
    UILabel *logoLabel = [[self class]getLogoTextLabelFromLogoView:logoView];
    logoLabel.hidden = YES;
}

/** 根据自定义logo的属性 显示logo */
+ (void)setUserDefinedLogo:(UIImageView *)logoView andLogoDic:(NSDictionary *)logoDic{
    
    NSNumber *tempNumber;
    UIColor *tempColor;

    //    logo 背景颜色
    UIColor *logoBGColor = [UIColor blueColor];
    tempColor = logoDic[KEY_USER_DEFINE_LOGO_BG_COLOR];
    if (tempColor) {
        logoBGColor = tempColor;
    }

    UIImageView *realImageView = [[self class]getSubLogoFromLogoView:logoView];
    
    if (realImageView == nil) {
        realImageView = logoView;
    }
//    UIImageView *realImageView = logoView;
    realImageView.layer.backgroundColor = tempColor.CGColor;
    
    //    logo 文本
    NSString *logoText = logoDic[KEY_USER_DEFINE_LOGO_TEXT];
    
    //    logo 文本字体大小
    UIFont *textFont = [UIFont boldSystemFontOfSize:13.0];
    tempNumber = logoDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE];
    if (tempNumber) {
        textFont = [UIFont boldSystemFontOfSize:tempNumber.floatValue];
    }
    //    logo文本颜色
    UIColor *logoTextColor = [UIColor whiteColor];
    tempColor = logoDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR];
    if (tempColor) {
        logoTextColor = tempColor;
    }

    UILabel *logoTextLabel = [[self class]getLogoTextLabelFromLogoView:logoView];
    logoTextLabel.text = logoText;
    [logoTextLabel setFont:textFont];
    [logoTextLabel setTextColor:logoTextColor];
    logoTextLabel.backgroundColor = [UIColor clearColor];
    logoTextLabel.layer.backgroundColor = [logoBGColor CGColor];
    logoTextLabel.hidden = NO;
    
//    NSLog(@"%s 显示名字头像",__FUNCTION__);
}


/** 生成一个用户自定义头像的属性字典 */
+ (NSDictionary *)getUserDefinedLogoDicOfEmp:(Emp *)emp
{
    NSString *logoText = [emp getEmpName];
    //获取颜色值
    UIColor *userColor =  [[self class] getUserBgColor:logoText];
    //获取名字内的数字
    NSString *nameNums = [[self class]stringContainNum:logoText];
    if (logoText.length >= 2) {
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:0 error:nil];
        NSString *chineseLogoText = [regularExpression stringByReplacingMatchesInString:logoText options:0 range:NSMakeRange(0, logoText.length) withTemplate:@""];
        if (chineseLogoText == nil || [chineseLogoText isEqualToString:@""]) {
            logoText = [logoText substringFromIndex:(logoText.length - 2)];
        }
        else
        {
            if (chineseLogoText.length >= 2) {
                logoText = [chineseLogoText substringFromIndex:(chineseLogoText.length - 2)];
                if (![nameNums isEqualToString:@""]) {
                    logoText = [NSString stringWithFormat:@"%@%@",logoText,nameNums];
                }

            }else{
                if (chineseLogoText.length == 0) {
                    
                }else{
                    logoText = [chineseLogoText substringFromIndex:(chineseLogoText.length - 1)];
                    if (![nameNums isEqualToString:@""]) {
                        logoText = [NSString stringWithFormat:@"%@%@",logoText,nameNums];
                    }
                }
            }
        }
    }
    if (logoText.length == 0) {
        logoText = @"未知";
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    mDic[KEY_USER_DEFINE_LOGO_TEXT] = logoText;
    mDic[KEY_USER_DEFINE_LOGO_BG_COLOR] = userColor;
    mDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE] = @(13.0);
    mDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR] = [UIColor whiteColor];
    
    mDic[KEY_USER_DEFINE_LOGO_SIZE] = @(40);

    
    return mDic;
}

/** 群组头像 根据用户名字生成 的 头像属性 */
+ (NSDictionary *)getUserDefinedGroupLogoDicOfEmp:(Emp *)emp
{
    NSString *logoText = [emp getEmpName];
    UIColor *userColor =  [[self class] getUserBgColor:logoText];
    if (logoText.length) {
        logoText = [[self class] getDisplayNameWithEmp:emp andCount:1];
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    mDic[KEY_USER_DEFINE_LOGO_TEXT] = logoText;
    mDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE] = @(11.0);
    mDic[KEY_USER_DEFINE_LOGO_BG_COLOR] = userColor;
    mDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR] = [UIColor whiteColor];
    mDic[KEY_USER_DEFINE_LOGO_SIZE] = @(20);

    return mDic;
}

/** 群组头像 根据用户名字生成 的 头像属性 */
+ (NSDictionary *)getUserDefinedChatMessageLogoDicOfEmp:(Emp *)emp
{
    NSString *logoText = [emp getEmpName];
    UIColor *userColor =  [[self class] getUserBgColor:logoText];

    if (logoText.length >= 2) {
        logoText = [[self class] getDisplayNameWithEmp:emp andCount:2];
    }
    if (logoText.length == 0) {
        logoText = @"未知";
    }
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    mDic[KEY_USER_DEFINE_LOGO_TEXT] = logoText;
    mDic[KEY_USER_DEFINE_LOGO_BG_COLOR] = userColor;
    mDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE] = @(15.0);
    mDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR] = [UIColor whiteColor];
    mDic[KEY_USER_DEFINE_LOGO_SIZE] = @(45);

    return mDic;
    
}



/** 在logoView上增加一个UILabel */
+ (void)addLogoTextLabelToLogoView:(UIImageView *)logoView{
//    if ([eCloudConfig getConfig].useNameAsLogo) {
    UIView *subview = [logoView viewWithTag:logo_text_tag];
    if (!subview) {
//        NSLog(@"%s 增加一个label子view",__FUNCTION__);
        UILabel *logoTextLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, logoView.frame.size.width, logoView.frame.size.height)]autorelease];
        logoTextLabel.textAlignment = NSTextAlignmentCenter;
        logoTextLabel.hidden = YES;
        logoTextLabel.tag = logo_text_tag;
        logoTextLabel.adjustsFontSizeToFitWidth = YES;
        logoTextLabel.minimumScaleFactor = 0.8;
        [logoView addSubview:logoTextLabel];
    }
//    }
}

//根据名字获取头像哈希值，获取头像背景颜色
+(UIColor *)getUserBgColor:(NSString *)logoname
{
    UIColor *userColor = nil;
    NSUInteger userHaxi = [logoname hash];
    NSInteger  userRemainder = userHaxi % 10;
    switch (userRemainder) {
        case 0:
            userColor = [[self class]stringTOColor:@"#8D6E63"];
            break;
        case 1:
            userColor = [[self class]stringTOColor:@"#F2725E"];
            break;
        case 2:
            userColor = [[self class]stringTOColor:@"#F06292"];

            break;
        case 3:
            userColor = [[self class]stringTOColor:@"#7E57C2"];

            break;
        case 4:
            userColor = [[self class]stringTOColor:@"#5C6BC0"];

            break;
        case 5:
            userColor = [[self class]stringTOColor:@"#589FFD"];

            break;
            
        case 6:
            userColor = [[self class]stringTOColor:@"#26C6DA"];

            break;
        case 7:
            userColor = [[self class]stringTOColor:@"#66BB6A"];

            break;
        case 8:
            userColor = [[self class]stringTOColor:@"#F5A623"];

            break;
        case 9:
            userColor = [[self class]stringTOColor:@"#FF9600"];

            break;
            
        default:
            break;
    }
    return userColor;
}

//取出颜色值
+ (UIColor *) stringTOColor:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}


+(NSString *)stringContainNum:(NSString *)name
{
//    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
//    
//    //符合数字条件的有几个字节
//    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:name options:NSMatchingReportProgress range:NSMakeRange(0,name.length)];
//    return tNumMatchCount;
    
    NSCharacterSet *setToRemove =
    [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
     invertedSet ];
    NSString *str = @"";
    
    str  = [[name componentsSeparatedByCharactersInSet:setToRemove] componentsJoinedByString:@""];
    return str;
}

/** 获取头像里显示的人的名字 */

+ (NSString *)getDisplayNameWithEmp:(Emp *)_emp andCount:(NSInteger)_count{
    NSString *logoText = _emp.emp_name;
    
    NSMutableString *mStr = [NSMutableString string];
    int nameCount = 0;
    
    for (NSInteger i = logoText.length - 1 ; i >= 0;i--) {
        
        NSString *tempStr = [logoText substringWithRange:NSMakeRange(i, 1)];
        
        int curChar = [logoText characterAtIndex:i];
        
        [mStr insertString:tempStr atIndex:0];
        
        if ([StringUtil isNumber:curChar]) {
            continue;
        }else{
            nameCount++;
            if (nameCount >= _count) {
                break;
            }
        }
    }
    return mStr;
}

@end
