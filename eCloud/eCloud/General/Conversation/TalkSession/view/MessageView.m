//
//  MessageView.m
//  eCloud
//
//  Created by robert on 12-10-31.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "MessageView.h"
#import "TextMessageView.h"
#import "picTextViewController.h"
#import "conn.h"
#import "TestCoreTextView.h"
#import "LinkTextViewController.h"
#import "OHAttributedLabelEx.h"
#import "FontSizeUtil.h"

static MessageView *_messageView;

@implementation MessageView
@synthesize max_width;
@synthesize viewFlag;
@synthesize searchStr = _searchStr;

-(void)dealloc
{
	[super dealloc];
	[_messageView release];
	_messageView = nil;
}
+(MessageView*)getMessageView
{
	if(_messageView == nil)
		_messageView = [[self alloc]init];
	_messageView.viewFlag = 1;
	_messageView.max_width =  180;
	return _messageView;
}

#pragma mark 生成最后一条会话记录相关代码

+(MessageView*)getLastMessageView
{
	if(_messageView == nil)
		_messageView = [[self alloc]init];
	_messageView.viewFlag = 0;
	_messageView.max_width = 200;
	return _messageView;
}

#pragma mark 生成会话最后一条记录时用到
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf
{
	return [self lastRecord:text];
}


#pragma mark 生成会话最后一条消息对应的view，message为最后一条消息，是图文混合
-(UIView *)lastRecord:(NSString *) message
{

//表情size
	int imageSize = 20;
	
    NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
    [self getImageRange:message :data];
	
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	
    UIFont *fon = [UIFont systemFontOfSize:14.0f];
	
    CGFloat upX = 0;
    CGFloat upY = 0;
	
	CGFloat X = 0;
	
	NSString *str=@"";
	NSString *imageName;
	
    if (data) {
        for (int i=0;i < [data count];i++) {
            str=[data objectAtIndex:i];
			
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if ((upX+ imageSize) > self.max_width)
                {
					//					最后一条记录只显示一行，如果超过一行，则停止处理
					break;
                }
				
                NSString *imageName;
                NSString *tempName = [str substringWithRange:NSMakeRange(2, str.length - 3)];
                if([tempName hasPrefix:@"r_"])
                {
                    tempName = [tempName substringFromIndex:2];
                    imageName = [NSString stringWithFormat:@"rtx_face_%@.gif",tempName];
                }
                else
                {
                    imageName = [NSString stringWithFormat:@"%@_%@.png",[eCloudConfig getConfig].facePrefix,tempName];
                }
 
                UIImageView *img= [[UIImageView alloc]initWithImage:[StringUtil getImageByResName:imageName]];
                img.frame = CGRectMake(upX, upY, imageSize, imageSize);
                [returnView addSubview:img];
                [img release];
				
                upX=imageSize+upX;
				
				if (X<self.max_width)  X = upX;
            }
			else
			{
				NSArray *colorArray = [self getColorArray:str];
                for (int j = 0; j < [str length]; j++)
				{
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
					CGSize size=[temp sizeWithFont:fon];
  					
                    if ((upX+size.width) > self.max_width)
                    {
						//					最后一条记录只显示一行，如果超过一行，则停止处理
						break;
					}
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY + (imageSize - size.height)/2,size.width,size.height)];
					if(colorArray && [[colorArray objectAtIndex:j]intValue] == 1)
					{//着重显示
						la.textColor = [UIColor redColor];
					}
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
					
                    upX=upX+size.width;
					
					if(X < self.max_width) X = upX;
                }
            }
        }
    }
	
    returnView.frame = CGRectMake(0,0,X, imageSize); //@ 需要将该view的尺寸记下，方便以后使用
	
    return returnView;
}

#pragma mark 生成一条格式化的图文混合的会话记录
- (UIView *)bubbleViewRecord:(NSString *)text from:(ConvRecord *)recordObject
{
    BOOL fromSelf=YES;
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    NSLog(@"-version-- %f",version);
    //支持超链接
    
//     return [self getChatView:recordObject andBody:[self assembleLinkWithBackgroudMessage:text from:fromSelf]] ;
//    return [self getChatView:recordObject andBody:[self assembleLinkMessage:text from:fromSelf]] ;
   
//    if (version<6.0) {
//      return [self getChatView:recordObject andBody:[self assembleMessageAtIndex:text from:fromSelf]] ;
//    }else
//     {//支持超链接
//      return [self getChatView:recordObject andBody:[self assembleLinkMessage:text from:fromSelf]] ; 
//     }
	
	NSError *error = NULL;
	NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
	NSUInteger numberOfMatches = [detector numberOfMatchesInString:text
														   options:0
															 range:NSMakeRange(0, [text length])];
	if(numberOfMatches == 0)
	{
		return [self getChatView:recordObject andBody:[self assembleMessageAtIndex:text from:fromSelf]] ;
	}
	else
	{
		return [self getChatView:recordObject andBody:[self assembleLinkWithBackgroudMessage:text from:fromSelf]] ;
	}

 //return [self getChatView:recordObject andBody:[self assembleLinkMessageAtIndex:text from:fromSelf]] ;
}
#pragma mark 仿照微信 超链接,手机号码,图文混合 2013-9-13
-(UIView *)assembleLinkWithBackgroudMessage: (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
	//	把文字和表情分开
    [self getImageRange:message :data];
   
    NSString *fontStr=@"";
    int strlength=0;
    NSMutableArray *imageArray=[[[NSMutableArray alloc] init]autorelease];
    int iconcount=0;
    for(int i = 0;i<[data count];i++)
	{
		NSString *tempStr = [data objectAtIndex:i];
        
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
//			如果是表情
            iconcount++;
//			生成一个Dictionary
//			保存图片的名字，图片显示的位置，图片对应的下标
//			保存到数组中
//			strlength的值加1
//			fontStr的值为什么要加yyy？
            NSMutableDictionary *imagedic=[[NSMutableDictionary alloc]init];
            NSString *imageName=[NSString stringWithFormat:@"%@_%@.png",[eCloudConfig getConfig].facePrefix,[tempStr substringWithRange:NSMakeRange(2, tempStr.length - 3)]];
            [imagedic setObject:imageName forKey:@"imageName"];
            [imagedic setObject:[NSString stringWithFormat:@"%d",strlength] forKey:@"imageLocation"];
            [imagedic setObject:[NSString stringWithFormat:@"imageid%d",i] forKey:@"imageId"];
            [imageArray addObject:imagedic];
            strlength=strlength+1;
            fontStr=[NSString stringWithFormat:@"%@yyy",fontStr];
		}
		else
		{   strlength=strlength+tempStr.length;
           
            fontStr=[NSString stringWithFormat:@"%@%@",fontStr,tempStr];
		}
	}
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    CGSize size = [fontStr sizeWithFont:font
                      constrainedToSize:CGSizeMake(200.f,1000)
                          lineBreakMode:NSLineBreakByCharWrapping];
    LinkTextViewController *textObject=[[LinkTextViewController alloc]init] ;
    textObject.textstr=message;
    textObject.textWidth=size.width;
    
    return textObject.view;
   
}
#pragma mark 超链接,手机号码,图文混合 2013-8-28
-(UIView *)assembleLinkMessage: (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
	//	把文字和表情分开
    [self getImageRange:message :data];

    //CGSize size = [message sizeWithFont:font forWidth:200 lineBreakMode:NSLineBreakByCharWrapping];
//    //首先计算view的大小
//    //	一行的最大长度
//	int rowWidth = MAX_WIDTH;// - LEFT_OFFSET - RIGHT_OFFSET;
//    //	一行的高度
//	float rowHeight = 24;
//	
//    // 信息的x值
//	float _width = 0;
//    //	信息的行数
//	int rowNum = 1;
//	
//	UIFont *_font = [UIFont systemFontOfSize:16];
//	float sumHeight=0;
//    //	先计算view的长度和宽度
//    BOOL is_face=NO;
//    int oldrow=0;
//	for(int i = 0;i<[data count];i++)
//	{
//		NSString *tempStr = [data objectAtIndex:i];
//        
//		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
//		{
//            //				NSString *imageName=[NSString stringWithFormat:@"face_%@.png",[tempStr substringWithRange:NSMakeRange(2, tempStr.length - 3)]];
//            //			UIImage *image = [StringUtil getImageByResName:imageName];
//
//            oldrow=rowNum;
//			_width = _width + KFacialSizeWidth;//image.size.width/2;
//			is_face=YES;
//			if(_width > rowWidth)
//			{    sumHeight=sumHeight+KFacialSizeHeight;
//				_width = KFacialSizeWidth;//image.size.width/2;
//				rowNum++;
//			}
//		}
//		else
//		{
//
//			for(int j=0;j<tempStr.length;j++)
//			{
//				NSString *_str = [tempStr substringWithRange:NSMakeRange(j, 1)];
//				if([_str isEqualToString:@"\n"] || [_str isEqualToString:@"\r"])
//				{
//                    //回车符或换行符
//					rowNum++;
//					_width = 0;
//                    sumHeight=sumHeight+20;
//				}
//				else
//				{
//					_width = _width + [_str sizeWithFont:_font].width;
//					if(_width > rowWidth)
//					{
//                        if (oldrow==rowNum) {
//                         sumHeight=sumHeight+KFacialSizeHeight;
//                        }else
//                        {
//                         sumHeight=sumHeight+[_str sizeWithFont:_font].height;
//                        }
//						//					又一个新的行
//						//					NSLog(@"text i is %d,j is %d,rowNum is %d",i,j,rowNum);
//						_width = [_str sizeWithFont:_font].width;
//						rowNum++;
//					}
//				}
//			}
//		}
//	}
//	NSLog(@"----sumHeight- -  %f",sumHeight);
////	if (oldrow==rowNum) {
////        sumHeight=sumHeight+KFacialSizeHeight+10;
////    }else
////    {
////      sumHeight=sumHeight+20;
////    }
//    
//    //如何计算TextMessageView的size呢？
//	
//	CGRect _frame;
//	if(rowNum == 1)
//	{
//		_frame = CGRectMake(0,0,_width, 20);
//        if (is_face) {
//          _frame = CGRectMake(0,0,_width, 34);
//        }
//	}
//	else
//	{
//		_frame = CGRectMake(0,0,rowWidth, sumHeight);
//      
//	}
	

    
    NSString *newmessage=@"";
    NSString *fontStr=@"";
    int strlength=0;
    NSMutableArray *imageArray=[[[NSMutableArray alloc] init]autorelease];
    int iconcount=0;
    for(int i = 0;i<[data count];i++)
	{
		NSString *tempStr = [data objectAtIndex:i];
        
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
            iconcount++;
         NSMutableDictionary *imagedic=[[NSMutableDictionary alloc]init];
        NSString *imageName=[NSString stringWithFormat:@"%@_%@.png",[eCloudConfig getConfig].facePrefix,[tempStr substringWithRange:NSMakeRange(2, tempStr.length - 3)]];
        [imagedic setObject:imageName forKey:@"imageName"];
        [imagedic setObject:[NSString stringWithFormat:@"%d",strlength] forKey:@"imageLocation"];
        [imagedic setObject:[NSString stringWithFormat:@"imageid%d",i] forKey:@"imageId"];
        [imageArray addObject:imagedic];
        strlength=strlength+1;
        fontStr=[NSString stringWithFormat:@"%@yyy",fontStr];
		}
		else
		{   strlength=strlength+tempStr.length;
            newmessage=[NSString stringWithFormat:@"%@%@",newmessage,tempStr];
            fontStr=[NSString stringWithFormat:@"%@%@",fontStr,tempStr];
		}
	}
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    CGSize size = [fontStr sizeWithFont:font
                      constrainedToSize:CGSizeMake(200.f,1000)
                          lineBreakMode:NSLineBreakByCharWrapping];
    
//    if (range.location==NSNotFound) {
//         vheight=size.height;
//         vwidth=size.width;
//    }else
//    {
//        if (size.width<199) {
//            vheight= size.height+5;
//             vwidth=size.width;
//        }else{
//        vheight= size.height;
//        vwidth=size.width;
//        }
//    }

    TestCoreTextView *coretextview=[[TestCoreTextView alloc]init];
    coretextview.imageArray=imageArray;
    coretextview.originalStr=newmessage;
    [coretextview buildAttribute];
    int height=[coretextview getAttributedStringHeightWithString:coretextview.content WidthValue:size.width];
    coretextview.frame=CGRectMake(0, 0, size.width, height+5);
    return coretextview;
}
#pragma mark 超链接,手机号码,图文混合
-(UIView *)assembleLinkMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    //	NSLog(@"message is %@",message);
//    NSString *newmessage = [message  stringByReplacingOccurrencesOfString:@" " withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, [message  length])];
    NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
	//	把文字和表情分开
    [self getImageRange:message :data];
	
//    //首先计算view的大小
//    //	一行的最大长度
//	int rowWidth = MAX_WIDTH+32;// - LEFT_OFFSET - RIGHT_OFFSET;
//    //	一行的高度
//	float rowHeight = 27;
//	
//    // 信息的x值
//	float _width = 0;
//    //	信息的行数
//	int rowNum = 1;
//	
//	UIFont *_font = [UIFont systemFontOfSize:16];
//       //	先计算view的长度和宽度
//	for(int i = 0;i<[data count];i++)
//	{
//		NSString *tempStr = [data objectAtIndex:i];
//        
//		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
//		{
//            //				NSString *imageName=[NSString stringWithFormat:@"face_%@.png",[tempStr substringWithRange:NSMakeRange(2, tempStr.length - 3)]];
//            //			UIImage *image = [StringUtil getImageByResName:imageName];
//            
//			_width = _width + KFacialSizeWidth;//image.size.width/2;
//			
//			if(_width > rowWidth)
//			{
//				_width = KFacialSizeWidth;//image.size.width/2;
//				rowNum++;
//			}
//            //    将表情字符串换算成表情，添加到string中
//            NSRange range=[tempStr rangeOfString: BEGIN_FLAG];
//            NSRange range1=[tempStr rangeOfString: END_FLAG];
//            NSString *str;
//            //判断当前字符串是否还有表情的标志。
//            if (range.length>0 && range1.length>0) {
//                str=[tempStr substringWithRange:NSMakeRange(range.location+2, range1.location-2-range.location)];
//                
//            }else
//            {
//                continue;
//            }
//		}
//		else
//		{
//			for(int j=0;j<tempStr.length;j++)
//			{
//				NSString *_str = [tempStr substringWithRange:NSMakeRange(j, 1)];
//				_width = _width + [_str sizeWithFont:_font].width;
//				if(_width > rowWidth)
//				{
//                    //					又一个新的行
//					
//                    //					NSLog(@"text i is %d,j is %d,rowNum is %d",i,j,rowNum);
//					_width = [_str sizeWithFont:_font].width;
//					rowNum++;
//				}
//			}
//		}
//	}
//	
//	
//    
//    //如何计算TextMessageView的size呢？
//	
//	CGRect _frame;
//	if(rowNum == 1)
//	{
//		_frame = CGRectMake(0,0,_width+15, rowHeight+5);
//	}
//	else
//	{
//		_frame = CGRectMake(0,0,rowWidth, rowHeight * rowNum+25);
//	}
//	
    //	NSLog(@"_width is %.0f,rowNum is %d",_frame.size.width,rowNum);
	picTextViewController *picAndText=[[picTextViewController alloc]init];
    
   // picAndText.view.frame=_frame;
    picAndText.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  //  picAndText.view.frame=_frame;
	[picAndText showPicOrText:data];
//    TextMessageView *_view = [[TextMessageView alloc]initWithFrame:_frame];
//	_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//	[_view setMessage:data];
 //   picAndText.view.tag=rowNum;
    
    
	return picAndText.view;
}

#pragma mark 画出图文混合的会话记录
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
//	NSLog(@"message is %@",message);
	
	 NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
	//	把文字和表情分开
	 [self getImageRange:message :data];
	
//首先计算view的大小
//	一行的最大长度
	int rowWidth = MAX_WIDTH;// - LEFT_OFFSET - RIGHT_OFFSET;
//	一行的高度
	float rowHeight = 24;
	
// 信息的x值
	float _width = 0;
//	信息的行数
	int rowNum = 1;
	
	UIFont *_font = [UIFont systemFontOfSize:16];
	
//	先计算view的长度和宽度
	for(int i = 0;i<[data count];i++)
	{
		NSString *tempStr = [data objectAtIndex:i];

		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
//				NSString *imageName=[NSString stringWithFormat:@"face_%@.png",[tempStr substringWithRange:NSMakeRange(2, tempStr.length - 3)]];
//			UIImage *image = [StringUtil getImageByResName:imageName];

			_width = _width + KFacialSizeWidth;//image.size.width/2;
			
			if(_width > rowWidth)
			{
				_width = KFacialSizeWidth;//image.size.width/2;
				rowNum++;
			}
		}
		else
		{
			for(int j=0;j<tempStr.length;j++)
			{
				NSString *_str = [tempStr substringWithRange:NSMakeRange(j, 1)];
				if([_str isEqualToString:@"\n"] || [_str isEqualToString:@"\r"])
				{
//回车符或换行符
					rowNum++;
					_width = 0;
				}
				else
				{
					_width = _width + [_str sizeWithFont:_font].width;
					if(_width > rowWidth)
					{
						//					又一个新的行
						
						//					NSLog(@"text i is %d,j is %d,rowNum is %d",i,j,rowNum);
						_width = [_str sizeWithFont:_font].width;
						rowNum++;
					}
				}
			}
		}
	}
	
	

//如何计算TextMessageView的size呢？
	
	CGRect _frame;
	if(rowNum == 1)
	{
		_frame = CGRectMake(0,0,_width, rowHeight);		
	}
	else
	{
		_frame = CGRectMake(0,0,rowWidth, rowHeight * rowNum);
	}
	
//	NSLog(@"_width is %.0f,rowNum is %d",_frame.size.width,rowNum);
	
	TextMessageView *_view = [[TextMessageView alloc]initWithFrame:_frame];
	_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[_view setMessage:data];
    
   
    
	return _view;
}

-(NSArray *)getColorArray:(NSString *)origin
{
	if(viewFlag == 0 || self.searchStr==nil || self.searchStr.length == 0)
	{//如果是联系人界面的最后一条记录或者查询字符串无效
		return nil;
	}
	
	NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:origin.length];
// 默认为黑色，设为空
	for(int i = 0;i<origin.length;i++)
	{
		[colorArray addObject:@"0"];
	}
	
	NSRange range = [origin rangeOfString:self.searchStr options:NSCaseInsensitiveSearch];
	while(range.length > 0)
	{
		for(int i=0;i<range.length;i++)
		{
			[colorArray replaceObjectAtIndex:(range.location + i) withObject:@"1"];
		}
		range = [origin rangeOfString:self.searchStr options:NSCaseInsensitiveSearch range:NSMakeRange(range.location + range.length, origin.length - (range.location + range.length))];
	}
	return colorArray;
}


//增加一个方法，可以把聊天内容中的表情使用"[表情]"来替换
-(NSString*)replaceFaceStrWithText:(NSString*)message
{
	if(!message || message.length == 0) return @"";
	NSMutableString *mString = [NSMutableString string];
	
    NSMutableArray *data = [[[NSMutableArray alloc] init]autorelease];
    [self getImageRange:message :data];
	
	NSString *str = @"";
	for (int i=0;i < [data count];i++) {
		str=[data objectAtIndex:i];
		if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
		{
			[mString appendString:@"[表情]"];
		}
		else {
			[mString appendString:str];
		}
	}
	return mString;
}

- (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)capInsets andImage:(UIImage *)image{
   CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 5.0) {
        image = [image resizableImageWithCapInsets:capInsets];
        return image;
    } 
    image = [image stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
    return image;
}
-(UIImage *)getEmpLogo:(ConvRecord*)recordObject
{
	UIImage *image = nil;
	NSString *empLogo = recordObject.emp_logo;
	if(empLogo && [empLogo length] > 0)
	{
		NSString *picPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:recordObject.emp_id] andLogo:empLogo];
		image = [UIImage imageWithContentsOfFile:picPath];
	}
	if(image == nil)
	{
		if (recordObject.emp_sex==0)
		{//女
			image =[StringUtil getImageByResName:@"female.png"];
        }else
        {
			image =[StringUtil getImageByResName:@"male.png"];
        }
	}
//	else
//	{
//		image = [UIImage createRoundedRectImage:image size:CGSizeZero];
//	}
	
	return image;
}

-(UIView *)getDateView:(NSString*)dateStr
{
	CGSize size = [dateStr sizeWithFont:[UIFont systemFontOfSize:12]];
	
//	时间的宽度和高度
	float labelWidth = size.width;
	float labelHeight = 14;
	
//	时间相对背景的起始位置
	float labelX = 7;
	float labelY = 3;
	
//	背景的宽度和高度
	float bgWidth = labelWidth + 10;
	float bgHeight = labelHeight + 6;
	
//	背景的起始位置
	float bgX = (320 - bgWidth) / 2;
	
	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
	
	UIImageView *dateBg = [[[UIImageView alloc] initWithImage:[self resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]]autorelease];
    
	dateBg.frame = CGRectMake(bgX, 0.0f, bgWidth, bgHeight );

	
	//		增加消息时间
	UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(labelX, labelY,labelWidth, labelHeight)];
	
	timelabel.backgroundColor=[UIColor clearColor];
	timelabel.font=[UIFont systemFontOfSize:12];
	timelabel.textColor = [UIColor whiteColor];
	timelabel.text = dateStr;

	[dateBg addSubview:timelabel];
	[timelabel release];
	
	return dateBg;
}

#pragma mark 群组变化通知View
-(UIView *)getGroupInfoView:(NSString*)msgBody
{
	//	时间相对背景的起始位置
	float labelX = 7;
	float labelY = 3;

//	如果信息较多，则需要显示多行，一行的最大宽度是320 - 20*2 - labeX * 2
	int maxWidth = 320 - 20*2 - labelX*2;
	
//	字体大小
	int fontSize = 14;
	
	CGSize size = [msgBody sizeWithFont:[UIFont systemFontOfSize:fontSize]];
	
//	NSLog(@"size width is %.0f,sizeHeight is %.0f",size.width,size.height);
	
	int row = (size.width/maxWidth + 1);
	//	时间的宽度和高度
	float labelWidth = size.width;
	if(row > 1)
		labelWidth = maxWidth;
	float labelHeight = size.height * row;
	
	//	背景的宽度和高度
	float bgWidth = labelWidth + labelX*2;
	float bgHeight = labelHeight + labelY * 2;
	
	//	背景的起始位置
	float bgX = (320 - bgWidth) / 2;
	
	UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
	
	UIImageView *dateBg = [[[UIImageView alloc] initWithImage:[self resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]]autorelease];
    
	dateBg.frame = CGRectMake(bgX, 0.0f, bgWidth, bgHeight );
	
	
	//		增加消息时间
	UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(labelX, labelY,labelWidth, labelHeight)];
	timelabel.numberOfLines =  0;
	timelabel.backgroundColor=[UIColor clearColor];
	timelabel.font=[UIFont systemFontOfSize:fontSize];
	timelabel.textColor = [UIColor whiteColor];
	timelabel.text = msgBody;
	timelabel.lineBreakMode = NSLineBreakByCharWrapping;
	
	[dateBg addSubview:timelabel];
	[timelabel release];
	
	return dateBg;
}


#pragma mark 给图文混合view，图片view，录音view加上气泡
-(UIView*)getChatView:(ConvRecord*)recordObject andBody:(UIView *)returnView
{
	BOOL fromSelf=YES;
    if (recordObject.msg_flag==1) {//别人发送的信息
        fromSelf=NO;
    }

	//	如果是自己，那么界面为 发送失败按钮和发送中提示按钮，气泡+内容，头像
	//	如果是对方，那么界面为头像 气泡+内容 接收失败按钮和接收中提示
	//	两者的主要区别是元素的x值不同
	
	//	信息体的宽度和高度，
   
	float bodyWidth = returnView.frame.size.width;
	float bodyHeight = returnView.frame.size.height;
//    if (recordObject.msg_type==type_text) {
//       bodyWidth+=10;
//    }
	
//	NSLog(@"bodyWidth = %.0f , bodyHeight=%.0f",bodyWidth,bodyHeight);

	//	信息体在气泡中的起始位置
	float bodyX = 10;// 15;
	if(!fromSelf)
		bodyX = 15;//25;
	float bodyY = 10;
	
//	如果是图片类型，那么bodyY是8
	if(recordObject.msg_type == type_pic)
	{
		bodyY = 8;
	}



	//气泡的宽度和高度
	float bubbleWidth = bodyWidth + 25;
	float bubbleHeight = bodyHeight + 20;
//    if (recordObject.msg_type == type_text) {//add by ly 2013-08-13
//        bubbleWidth = bodyWidth + 10;
//       
//        if (returnView.tag==1) {
//             bubbleHeight = bodyHeight + 20;
//        }else
//        {
//         bubbleHeight = bodyHeight + 10;
//        }
//    }
   
//	如果是录音类型，那么bubbleHeight 和bodyHeight相同
	if(recordObject.msg_type == type_record)
	{
		bubbleHeight = bodyHeight;
	}
	
//	如果气泡的高度比头像的高度小
	if(bubbleHeight < chat_user_logo_size)
	{
//		NSLog(@"气泡高度比头像尺寸小，需要调整y值");
		bodyY = bodyY + (chat_user_logo_size - bubbleHeight)/2;
		bubbleHeight = chat_user_logo_size;
	}

//	设定一个最小的宽度
	if(bubbleWidth < MIN_WIDTH)
	{
//		NSLog(@"气泡宽度小于最小宽度，需要调整x值");
		bodyX = bodyX + (MIN_WIDTH - bubbleWidth)/2;
		bubbleWidth = MIN_WIDTH;
	}
	
//	状态，时间，发送标识这些已经不再使用了
	
	//	状态，时间，发送标识View的宽度和高度
//	发送文本，图片或录音时需要提示，提示按钮的位置需要垂直居中，接收图片时提示按钮在图片正中间，录音在边上
	float statusWidth = 30;//40;
	float statusHeight = bubbleHeight;//30;
//	if(!fromSelf)
//		statusHeight = bubbleHeight;
	
	//	对应的x值和y值
	float statusX = 0;
	if(!fromSelf)
		statusX = chat_user_logo_size + bubbleWidth; 
	
	float statusY = 0;
//	if(!fromSelf)
//		statusY = 0;
	
	//	气泡的起始位置
	float bubbleX = statusWidth;
	if(!fromSelf)
		bubbleX = chat_user_logo_size;
	
	//	总的view的高度和宽度
	float cellWidth = statusWidth + bubbleWidth + chat_user_logo_size;
	float cellheight = bubbleHeight ;//+ 10;
	
	if(!fromSelf && cellheight < chat_user_logo_size + 20)
	{
//		如果聊天内容高度小于头像+名字的高度，那么，总高度需要重新计算
		cellheight = chat_user_logo_size + 20;
	}
	
	
	//	总view的x值
	float cellX = 315 - cellWidth;
	if(!fromSelf)
		cellX = 5;
	
	//	头像的x值
	float headX = statusWidth + bubbleWidth;
	if(!fromSelf)
		headX = 0;
	
	
	//	气泡展示的总view
    UIButton *cellView = [[[UIButton alloc] initWithFrame:CGRectZero]autorelease];
//    cellView.backgroundColor = [UIColor clearColor];
	cellView.frame = CGRectMake(cellX, 0.0f,cellWidth, cellheight);
	
	cellView.userInteractionEnabled = YES;
	
	//	用户头像
	UIImageView *headImageView = [[UIImageView alloc] init];

	//	update by shisp 为了提高打开会话的速度，不再生成圆角头像
    headImageView.image=[self getEmpLogo:recordObject];
	headImageView.tag = headImageTag;
	headImageView.userInteractionEnabled = YES;
	headImageView.frame = CGRectMake(headX, 0, chat_user_logo_size, chat_user_logo_size);
	
//点击头像可以查看用户资料，需要把empId，保存起来
	UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,0,0,0)];
	empIdLabel.text = [StringUtil getStringValue:recordObject.emp_id];
	empIdLabel.tag = empIdTag;
	[headImageView addSubview:empIdLabel];
	[empIdLabel release];
	
	if(!fromSelf)
	{
		UILabel *namelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, chat_user_logo_size, chat_user_logo_size, 20)];
        namelabel.text=recordObject.emp_name;
//		如果名字为空，则显示工号
		if(recordObject.emp_name == nil || recordObject.emp_name.length == 0)
			namelabel.text = recordObject.emp_code;
		
        namelabel.backgroundColor=[UIColor clearColor];
        namelabel.font=[UIFont boldSystemFontOfSize:12];
        namelabel.textAlignment=UITextAlignmentCenter;
        [headImageView addSubview:namelabel];
        [namelabel release];
	}
	
	//	自己和联系人采用不同的气泡图片
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
//	点击时的效果
	UIImage *bubbleHighlighted = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelfDown":@"bubbleDown" ofType:@"png"]];
	UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[self resizeImageWithCapInsets:capInsets andImage:bubble] highlightedImage:[self resizeImageWithCapInsets:capInsets andImage:bubbleHighlighted]];
	
     bubbleImageView.frame = CGRectMake(bubbleX, 0.0f, bubbleWidth, bubbleHeight );
     bubbleImageView.tag=bubbleTag;
	
	//	如果是录音或图片，则可以交互
	if(!recordObject.msg_type || recordObject.msg_type != type_text)
		bubbleImageView.userInteractionEnabled = YES;
    
    if (recordObject.msg_type == type_text) {
        bubbleImageView.userInteractionEnabled = YES;
    }
	
	//	如果是自己发的消息需要增加上传中提示和上传失败按钮
	//	如果是对方发的消息，则需要下载中提示和下载失败按钮
	
	UIView *statusView = [[UIView alloc]initWithFrame:CGRectMake(statusX, statusY, statusWidth, statusHeight)];
//	statusView.backgroundColor = [UIColor clearColor];
	
	if(fromSelf)
	{
//	失败按钮的位置和提示的位置，都要根据内容的高度不同，y值不同
//		如果是发送长消息，那么发送提示和重发提示按钮都放在最下面，就是y值不同
		int failBtnY = (bubbleHeight - 26)/2;
		if(recordObject.msg_type == type_long_msg)
		{
			failBtnY = bubbleHeight - single_line_height * 2;
		}
		
		// 消息发送失败的按钮
		UIButton *failView=[[UIButton alloc]initWithFrame:CGRectMake(0,failBtnY, 26, 26)];
		//            failView.backgroundColor=[UIColor clearColor];
		[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.gif"] forState:UIControlStateNormal];
		[failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateSelected];
		[failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateHighlighted];
		failView.tag = failTag;
		failView.hidden = YES;

		[statusView addSubview:failView];
		[failView release];
		
		// 发送录音时需要一个view，提示用户正在上传录音
//		现在是发送图片，录音和文字都需要上传提示
		
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		int spinnerY = (bubbleHeight - spinner.frame.size.height)/2;
		if(recordObject.msg_type == type_long_msg)
		{
			spinnerY = (bubbleHeight - single_line_height * 2);
		}
		spinner.frame = CGRectMake(0 ,spinnerY,spinner.frame.size.width,spinner.frame.size.height);
		spinner.tag = spinnerTag;
		[statusView addSubview:spinner];
		[spinner release];
 	}
	else
	{
		// 文件下载失败按钮
		UIButton *failView=[[UIButton alloc]initWithFrame:CGRectMake(0, 5, 30, 30)];
//		failView.backgroundColor=[UIColor clearColor];
		[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.gif"] forState:UIControlStateNormal];
        [failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateSelected];
        [failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateHighlighted];
		failView.tag = failTag;
		failView.hidden = true;
		[statusView addSubview:failView];
		[failView release];
		
		// 下载录音时需要一个view，提示用户正在下载录音
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.frame = CGRectMake(5 ,10,spinner.frame.size.width,spinner.frame.size.height);
		spinner.tag = spinnerTag;
		[statusView addSubview:spinner];
		[spinner release];
    
//		在这里需要判断，如果是收到的录音消息，那么需要判断，是否显示未读标志
        UIImageView *redimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 8, 8)];
        redimage.hidden=YES;
        redimage.tag=isReadedTag;
        redimage.image=[StringUtil getImageByResName:@"new_msg_icon.png"];
        [statusView addSubview:redimage];
        [redimage release];
	}
	statusView.tag=statusViewTag;
//	把状态View增加到返回view中
	[cellView addSubview:statusView];
	[statusView release];
	
	//	把内容增加到气泡里
	returnView.frame= CGRectMake(bodyX,bodyY, bodyWidth,bodyHeight);
   
	[bubbleImageView addSubview:returnView];
   
	returnView.userInteractionEnabled=NO;
	//    if (recordObject.msg_type == type_text) {
	//     returnView.userInteractionEnabled=YES;
	//    }
    if(recordObject.msg_type == type_pic || recordObject.msg_type == type_record)
    	returnView.userInteractionEnabled=YES;
	
	if (recordObject.msg_type==type_text) {
        returnView.userInteractionEnabled=YES;
    }
	//	把气泡增加到返回view里
    [cellView addSubview:bubbleImageView];
    [bubbleImageView release];
    
	//把头像增加到返回view里
    [cellView addSubview:headImageView];
    [headImageView release];
	return cellView;
}

#pragma mark 取得图片在聊天界面中显示的尺寸
+(CGSize)getImageDisplaySize:(UIImage *)img
{
	//	最高或最宽为
    int max_size = [UIAdapterUtil getTableCellContentWidth] - 200;
    if (IS_IPAD) {
        max_size = 300;
    }
	
	//	宽和高的比例
	float rate=img.size.width/img.size.height;
	
	float frameWidth = img.size.width;
	float frameHeight = img.size.height;
	
	if(rate >= 1)
	{
		//		横向图片
		if(frameWidth >= max_size)
		{
			frameWidth = max_size;
			frameHeight = max_size / rate;
		}
	}
	else
	{
		//	纵向图片
		if(frameHeight >= max_size)
		{
			frameHeight = max_size;
			frameWidth = max_size * rate;
		}
	}
	
	if(frameHeight < MIN_PIC_HEIGHT)
	{
		frameHeight = MIN_PIC_HEIGHT;
	}
	if(frameWidth < MIN_PIC_WIDTH)
	{
		frameWidth = MIN_PIC_WIDTH;
	}
	return CGSizeMake(frameWidth, frameHeight);
}

#pragma mark 把图文混合的消息分成文本和图片的数组
-(void)getImageRange:(NSString*)message : (NSMutableArray*)array
{
    if ([StringUtil isXiaoWanMsg:message]) {
        [array addObject:message];
    }else{
        NSRange range=[message rangeOfString: BEGIN_FLAG];
        NSRange range1=[message rangeOfString: END_FLAG];
        if (range.length > 0 && range1.length > 0 && range.location>range1.location) {
            NSString *temp_mes=[message substringFromIndex:range1.location+1];
            NSRange range1_temp=[temp_mes rangeOfString: END_FLAG];
            if (range1_temp.length > 0) {
                range1=NSMakeRange(range1.location+range1_temp.location+1, 1);
            }
        }
        //判断当前字符串是否还有表情的标志。
        if (range.length>0 && range1.length>0 && range.location < range1.location) {
            if (range.location > 0) {
                [array addObject:[message substringToIndex:range.location]];
                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                NSString *str=[message substringFromIndex:range1.location+1];
                if (str.length > 0) {
                    [self getImageRange:str :array];
                }
            }else {
                NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
                //排除文字是“”的
                if (![nextstr isEqualToString:@""]) {
                    [array addObject:nextstr];
                    NSString *str=[message substringFromIndex:range1.location+1];
                    [self getImageRange:str :array];
                }else {
                    return;
                }
            }
            
        } else if (message != nil) {
            [array addObject:message];
        }
    }
}
//{
//    if ([StringUtil isXiaoWanMsg:message]) {
//        [array addObject:message];
//    }else{
//        NSRange range=[message rangeOfString: BEGIN_FLAG];
//        NSRange range1=[message rangeOfString: END_FLAG];
//        if (range.location>range1.location) {
//            NSString *temp_mes=[message substringFromIndex:range1.location+1];
//            NSRange range1_temp=[temp_mes rangeOfString: END_FLAG];
//            range1=NSMakeRange(range1.location+range1_temp.location+1, 1);
//        }
//        //判断当前字符串是否还有表情的标志。
//        if (range.length>0 && range1.length>0) {
//            if (range.location > 0) {
//                [array addObject:[message substringToIndex:range.location]];
//                [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
//                NSString *str=[message substringFromIndex:range1.location+1];
//                if (str.length > 0) {
//                    [self getImageRange:str :array];
//                }
//            }else {
//                NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
//                //排除文字是“”的
//                if (![nextstr isEqualToString:@""]) {
//                    [array addObject:nextstr];
//                    NSString *str=[message substringFromIndex:range1.location+1];
//                    [self getImageRange:str :array];
//                }else {
//                    return;
//                }
//            }
//            
//        } else if (message != nil) {
//            [array addObject:message];
//        }
//    }
//}

-(CGSize)getTextMessageViewSize:(NSArray*)data andMaxWidth:(float)maxWidth
{
//    不知为什么之前已经定于了maxWidth参数，但没有使用 add by shisp
	//首先计算view的大小
	//	一行的最大长度
	int rowWidth = maxWidth;// - LEFT_OFFSET - RIGHT_OFFSET;
    
	UIFont *_font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
    CGSize _size = [@"我" sizeWithFont:_font];
    
	//	行高
	float rowHeight = _size.height;
	
	// 信息的x值
	float _width = 0;
	//	信息的行数
	int rowNum = 1;
    
//    表情的尺寸要随着字号进行变化
    float faceSize = rowHeight;
    
	//	先计算view的长度和宽度
	for(int i = 0;i<[data count];i++)
	{
		NSString *tempStr = [data objectAtIndex:i];
		
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
			_width = _width + faceSize;
			
			if(_width > rowWidth)
			{
				_width = faceSize;
				rowNum++;
			}
		}
		else
		{
			for(int j=0;j<tempStr.length;j++)
			{
				NSString *_str = [tempStr substringWithRange:NSMakeRange(j, 1)];
				if([_str isEqualToString:@"\n"] || [_str isEqualToString:@"\r"])
				{
					//回车符或换行符
					rowNum++;
					_width = 0;
				}
				else
				{
					_width = _width + [_str sizeWithFont:_font].width;
					if(_width > rowWidth)
					{
						//					又一个新的行
						_width = [_str sizeWithFont:_font].width;
						rowNum++;
					}
				}
			}
		}
	}
	CGSize retSize;
	if(rowNum == 1)
	{
		retSize = CGSizeMake(_width, rowHeight);
	}
	else
	{
		retSize = CGSizeMake(rowWidth, rowHeight * rowNum);
	}
	return retSize;
}

@end
