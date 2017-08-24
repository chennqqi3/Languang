//
//  PSMsgUtil.m
//  eCloud
//
//  Created by Richard on 13-11-1.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSMsgUtil.h"
#import "EncryptFileManege.h"
#import "ServiceMessageDetail.h"
#import "ServiceMessage.h"
#import "StringUtil.h"
#import "MessageView.h"

#import "ConvRecord.h"

#import "MassParentCell.h"

#import "UITableViewCell+getCellContentWidth.h"

@implementation PSMsgUtil

//用于单图文显示
+ (UITableViewCell *)singlePsMsgTableViewCellWithReuseIdentifier:(NSString *)identifier
{
	MassParentCell *cell = [[[MassParentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	cell.opaque = YES;
	cell.selectionStyle = UITableViewCellEditingStyleNone;

//标题
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	titleLabel.font = [UIFont boldSystemFontOfSize:17];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	titleLabel.tag = ps_title_tag;
	[cell.contentView addSubview:titleLabel];
	[titleLabel release];
	
//	日期
	UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.tag = ps_time_tag;
	dateLabel.textColor = [UIColor grayColor];
	dateLabel.font = [UIFont systemFontOfSize:12];
	[cell.contentView addSubview:dateLabel];
	[dateLabel release];
	
//	图片
	
	MessageView *messageView = [MessageView getMessageView];
	
	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
	
	UIImageView *picBackground = [[UIImageView alloc]initWithFrame:CGRectZero];
	picBackground.image = [messageView resizeImageWithCapInsets:capInsets andImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"date_bg" andType:@"png"]]];
	picBackground.tag = ps_image_background_tag;
	[cell.contentView addSubview:picBackground];
	[picBackground release];

	//	一个图片
	UIImageView *imageView = [[UIImageView alloc]init];
//	imageView.contentMode = UIViewContentModeCenter;
	[cell.contentView addSubview:imageView];
	imageView.tag = ps_image_tag;
	[imageView release];
	
//	图片加载用到的spinner
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.tag = ps_spinner_tag;
	[cell.contentView addSubview:spinner];
	[spinner release];
	
//	描述
	UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectZero];
	descLabel.backgroundColor = [UIColor clearColor];
	descLabel.tag = ps_desc_tag;
	descLabel.numberOfLines = 0;
	descLabel.font = [UIFont systemFontOfSize:14];
	descLabel.textColor = [UIColor grayColor];
	[cell.contentView addSubview:descLabel];
	[descLabel release];
		
//	把分割线，阅读全文，箭头放在一个View中
//	分割线在最上面 2 个像素
//	然后是文字和箭头，高度是22个像素，中间有6个像素的间隔
	//	阅读全文 >
	UIView *readView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [PSMsgUtil getMaxContentWidth], 30)];
	readView.tag = ps_read_tag;

	//	分割线
	capInsets = UIEdgeInsetsMake(1,1,1,1);
	UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [PSMsgUtil getMaxContentWidth], 1)];
	lineImageView.image = [messageView resizeImageWithCapInsets:capInsets andImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"single_ps_msg_line" andType:@"png"]]];
	[readView addSubview:lineImageView];
	[lineImageView release];

	
	UILabel *readLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, 200, 22)];
	readLabel.backgroundColor = [UIColor clearColor];
	readLabel.font = [UIFont systemFontOfSize:14];
	readLabel.text = @"阅读全文";
	[readView addSubview:readLabel];
	[readLabel release];
	
	UIImageView *arrowView = [[UIImageView alloc]initWithFrame:CGRectMake([PSMsgUtil getMaxContentWidth] - 11, (22 - 11)/2 + 8, 11, 11)];
	arrowView.image = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"single_ps_msg_arrow" andType:@"png"]];
	[readView addSubview:arrowView];
	[arrowView release];
	
	[cell.contentView addSubview:readView];
	
	[readView release];
	
	return cell;
}


+ (UITableViewCell *)multiPsMsgTableViewCellWithReuseIdentifier:(NSString *)identifier
{
	
	MassParentCell *cell = [[[MassParentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	cell.opaque = YES;
	cell.selectionStyle = UITableViewCellEditingStyleNone;

	MessageView *messageView = [MessageView getMessageView];
	
	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);

	UIImageView *picBackground = [[UIImageView alloc]initWithFrame:CGRectZero];
	picBackground.image = [messageView resizeImageWithCapInsets:capInsets andImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"date_bg" andType:@"png"]]];
	picBackground.tag = ps_image_background_tag;
	[cell.contentView addSubview:picBackground];
	[picBackground release];
	
//	一个图片
	UIImageView *imageView = [[UIImageView alloc]init];
//	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[cell.contentView addSubview:imageView];
	imageView.tag = ps_image_tag;
	[imageView release];
	
	
//	一个文本
	UILabel *titleLable = [[UILabel alloc]init];
	titleLable.tag = ps_title_tag;
	[cell.contentView addSubview:titleLable];
	[titleLable release];
	
//	一个spinner
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.tag = ps_spinner_tag;
	[cell.contentView addSubview:spinner];
	[spinner release];

	return cell;
}

//单图文消息的显示高度不是固定的，这里计算单图文消息的高度
+(float)getSinglePsMsgHeight:(ServiceMessage*)serviceMessage
{
	ServiceMessageDetail *detailMsg = [serviceMessage.detail objectAtIndex:0];
	float height = 10;
	
	NSString *psTitle = detailMsg.msgBody;
	CGSize _size = [psTitle sizeWithFont:[UIFont boldSystemFontOfSize:17] forWidth:[PSMsgUtil getMaxContentWidth] lineBreakMode:NSLineBreakByTruncatingTail];
	
	height = height + _size.height + 10;
	
	
	NSString *psTime = serviceMessage.singlePsMsgDate;
	_size = [psTime sizeWithFont:[UIFont systemFontOfSize:12]];
	
	height = height + _size.height + 10;
	
	height = height + [PSMsgUtil getPSBigPicHeight] + 10;

	NSString *psDesc = serviceMessage.msgBody;
	_size = [psDesc sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([PSMsgUtil getMaxContentWidth],1000) lineBreakMode:UILineBreakModeWordWrap];
	height = height + _size.height + 10;
	
//	read view
	height = height + 30 + 10;
	return height;
}
//配置单图文信息显示
+ (void)configureSinglePsMsgCell:(UITableViewCell *)cell andPSMsg:(ServiceMessage*)serviceMessage
{
//	标题
	UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:ps_title_tag];
//	时间
	UILabel *dateLabel = (UILabel*)[cell.contentView viewWithTag:ps_time_tag];
//	图片
	UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:ps_image_tag];
	UIImageView *picBackground = (UIImageView*)[cell.contentView viewWithTag:ps_image_background_tag];
//	spinner
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ps_spinner_tag];
//	desc
	UILabel *descLabel = (UILabel*)[cell.contentView viewWithTag:ps_desc_tag];
//	阅读View
	UIView *readView = (UIView*)[cell.contentView viewWithTag:ps_read_tag];
	
	ServiceMessageDetail *detailMsg = [serviceMessage.detail objectAtIndex:0];
	
	float x,y,w,h;
	
//	titleFrame
	x = 10;
	y = 10;
	NSString *psTitle = detailMsg.msgBody;
	CGSize _size = [psTitle sizeWithFont:[UIFont boldSystemFontOfSize:17] forWidth:[PSMsgUtil getMaxContentWidth] lineBreakMode:NSLineBreakByTruncatingTail];
	titleLabel.text = psTitle;
	titleLabel.frame = CGRectMake(x, y, _size.width, _size.height);
	
//	date
	x = 10;
	y = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10;
	NSString *psTime = serviceMessage.singlePsMsgDate;
	_size = [psTime sizeWithFont:[UIFont systemFontOfSize:12]];
	dateLabel.text = psTime;
	dateLabel.frame = CGRectMake(x, y, _size.width + 50, _size.height);
	
//	image
	x = 10;
	y = dateLabel.frame.origin.y + dateLabel.frame.size.height + 10;
	w = [PSMsgUtil getMaxContentWidth];
	h = [PSMsgUtil getPSBigPicHeight];
	imageView.frame = CGRectMake(x,y,w,h);
	
	NSString *dtlImgPath = [self getDtlImgPath:detailMsg];
    UIImage *img = [UIImage imageWithData:[EncryptFileManege getDataWithPath:dtlImgPath]];
//    [UIImage imageWithContentsOfFile:dtlImgPath];
	if(img)
	{
		picBackground.frame = CGRectZero;

		imageView.contentMode = UIViewContentModeScaleAspectFit;

		imageView.image = img;
		detailMsg.isPicExists = YES;
		//		[LogUtil debug:[NSString stringWithFormat:@"%s,pic is exist",__FUNCTION__]];
		
	}
	else
	{
		picBackground.frame = imageView.frame;

		//		[LogUtil debug:[NSString stringWithFormat:@"%s,pic is not exist",__FUNCTION__]];
		detailMsg.isPicExists = NO;
		imageView.image = nil;
	}
	
	//		spinner frame
	x = imageView.frame.size.width / 2;
	y = imageView.frame.origin.y + imageView.frame.size.height / 2 - 10;
	spinner.frame =CGRectMake(x, y, 20, 20);

//desc
	x = 10;
	y = imageView.frame.origin.y + imageView.frame.size.height + 10;
	NSString *psDesc = serviceMessage.msgBody;
	_size = [psDesc sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([PSMsgUtil getMaxContentWidth],1000) lineBreakMode:UILineBreakModeWordWrap];
	descLabel.text = psDesc;
	descLabel.frame = CGRectMake(x, y, _size.width, _size.height);
	
//	read
	x = 10;
	y = descLabel.frame.origin.y + descLabel.frame.size.height + 10;
	CGRect _frame = readView.frame;
	_frame.origin.x = x;
	_frame.origin.y = y;
	readView.frame = _frame;
	 
}


+ (void)configureMultiPsMsgCell:(UITableViewCell *)cell andPSMsgDtl:(ServiceMessageDetail*)detailMsg
{
	UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:ps_image_tag];
	UIImageView *picBackground = (UIImageView*)[cell.contentView viewWithTag:ps_image_background_tag];
	
	UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:ps_title_tag];
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:ps_spinner_tag];

	float x,y,w,h;
	
	if(detailMsg.row == 0)
	{
//		图片frame
		x = 10;
		y = 10;
		w = [PSMsgUtil getMaxContentWidth];
        // 0814  y * 2 -> y 
		h = ([PSMsgUtil getPSMsgRow0Height] - y);
		imageView.frame = CGRectMake(x,y,w,h);
		
//文本frame
		h = 30;
		w = imageView.frame.size.width;
		x = imageView.frame.origin.x;
		y = [PSMsgUtil getPSMsgRow0Height] - h;
		titleLabel.frame =CGRectMake(x, y, w, h);
		titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.numberOfLines = 1;
		
//		spinner frame
		x = imageView.frame.size.width / 2;
		y = imageView.frame.size.height / 2;
		
		spinner.frame =CGRectMake(x, y, 20, 20);
	}
	else
	{
//		其它行图片frame
		w = ps_msg_row1_height - 10;//图片为正方形图片，就是图片宽度和高度
		x = ([cell getCellContentWidth] - 20) - 10 - w;//表格用来显示的内容为300,去掉边距10，去掉
		y = 5;
		imageView.frame = CGRectMake(x,y,w,w);

//		其它行标题
		x = 10;
		y = 10;
		w = ([cell getCellContentWidth] - 20) - 20 - 10 - imageView.frame.size.width;//
		h = ps_msg_row1_height - 20;
		titleLabel.frame = CGRectMake(x, y, w, h);
		titleLabel.font = [UIFont systemFontOfSize:17];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.numberOfLines = 2;
//	spinner frame	
		x = imageView.frame.origin.x + imageView.frame.size.width / 2 - 10;
		y = imageView.frame.origin.y + imageView.frame.size.height / 2 - 10;
		spinner.frame = CGRectMake(x, y, 20, 20);

	}
    // 0814 标题向右挪动一点
	titleLabel.text = [NSString stringWithFormat:@" %@",detailMsg.msgBody];
	
	NSString *dtlImgPath = [self getDtlImgPath:detailMsg];
    UIImage *img = [UIImage imageWithData:[EncryptFileManege getDataWithPath:dtlImgPath]];
//    [UIImage imageWithContentsOfFile:dtlImgPath];
	if(img)
	{
		picBackground.frame = CGRectZero;

		imageView.image = img;
		detailMsg.isPicExists = YES;
//		[LogUtil debug:[NSString stringWithFormat:@"%s,pic is exist",__FUNCTION__]];

	}
	else
	{
		picBackground.frame = imageView.frame;
//		[LogUtil debug:[NSString stringWithFormat:@"%s,pic is not exist",__FUNCTION__]];
		detailMsg.isPicExists = NO;
		imageView.image = nil;
	}
	
}
//获取某个明细消息对应的图片
+(NSString *)getDtlImgName:(ServiceMessageDetail*)detail
{
	int serviceMsgId = detail.serviceMsgId;
	int dtlMsgId = detail.msgId;
	NSString *fileName = [NSString stringWithFormat:@"%d_%d.png",serviceMsgId,dtlMsgId];
//	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,fileName]];
	return fileName;
}

+(NSString *)getDtlImgPath:(ServiceMessageDetail*)detail
{
	NSString *imageName = [self getDtlImgName:detail];
	NSString *rootPath = [StringUtil getFileDir];
	NSString *dirName = [NSString stringWithFormat:@"ps_%d",detail.serviceId];
	NSString *path = [[rootPath stringByAppendingPathComponent:dirName]stringByAppendingPathComponent:imageName];
//	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,path]];
	return path;
}

//获取收到的公众号图片消息的名字
+ (NSString *)getPSPicMsgName:(ConvRecord *)convRecord
{
    NSString *picName = [NSString stringWithFormat:@"%@%d.png",ps_picmsg_pic_prefix,convRecord.msgId];
    return picName;
}

//增加一个方法 看收到的图片类型的公众号消息 是否存在 by shisp
+ (NSString *)getPSPicMsgImagePath:(ConvRecord *)convRecord
{
    NSString *serviceId = convRecord.conv_id;
    NSString *rootPath = [StringUtil getFileDir];
    NSString *dirName = [NSString stringWithFormat:@"ps_%@",serviceId];
    
    NSString *picName = [self getPSPicMsgName:convRecord];
    
    NSString *picPath = [[rootPath stringByAppendingPathComponent:dirName]stringByAppendingPathComponent:picName];
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s,picpath is %@",__FUNCTION__,picPath]];
    return picPath;
}

//判断明细消息对应的图片是否存在


//
//+(void)setPropertyOfConvRecord:(ConvRecord*)_convRecord;

+ (UITableViewCell *)headerViewWithReuseIdentifier:(NSString *)identifier
{
	UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.opaque = YES;
	
	MessageView *messageView = [MessageView getMessageView];

	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
	UIImageView *dateBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
	dateBg.tag = ps_msg_time_tag;
	
	UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectZero];
	timelabel.backgroundColor= [UIColor colorWithRed:204 green:204 blue:204 alpha:0];
	timelabel.font=[UIFont systemFontOfSize:time_font_size];
	timelabel.textColor = [UIColor whiteColor];
	timelabel.tag = ps_msg_time_text_tag;
	[dateBg addSubview:timelabel];
	[timelabel release];

	[cell.contentView addSubview:dateBg];
	[dateBg release];
	return cell;
}

+ (void)configureHeaderView:(UITableViewCell *)cell andPSMsg:(ServiceMessage*)message
{
	NSString *displayMsgTime = message.msgTimeDisplay;
	CGSize size = [displayMsgTime sizeWithFont:[UIFont systemFontOfSize:time_font_size]];
	
	//	时间的宽度和高度
	float labelWidth = size.width;
	float labelHeight = size.height;
	
	//	时间相对背景的起始位置
	float labelX = 7;
	float labelY = 3;
	
	//	背景的宽度和高度
	float bgWidth = labelWidth + 2*labelX;
	float bgHeight = labelHeight + 2*labelY;
	
	//	背景的起始位置
	float bgX = ([cell getCellContentWidth] - bgWidth) / 2;
	
	UIImageView *dateBg = (UIImageView*)[cell.contentView viewWithTag:ps_msg_time_tag];
	dateBg.frame = CGRectMake(bgX, 0.0f, bgWidth, bgHeight );
	
	//		增加消息时间
	UILabel *timelabel= (UILabel*)[cell.contentView viewWithTag:ps_msg_time_text_tag];
	timelabel.text = displayMsgTime;
	timelabel.frame = CGRectMake(labelX, labelY,labelWidth, labelHeight);
}

+(void)hideView:(UIView *)uiView
{
	for(UIView *view in uiView.subviews)
	{
		if([view isKindOfClass:[UIActivityIndicatorView class]])
		{
			continue;
		}
		view.hidden = YES;
		[self hideView:view];
	}
}

+ (float)getMaxContentWidth
{
    return [UIAdapterUtil getTableCellContentWidth] - 40;
}

+ (float)getPSBigPicHeight
{
    return ([PSMsgUtil getMaxContentWidth] * ps_big_pic_height) / max_content_width;
}

+ (float)getPSMsgRow0Height
{
    return ([PSMsgUtil getMaxContentWidth] * ps_msg_row0_height) / max_content_width;
}
@end
