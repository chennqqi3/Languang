
#import "LastRecordView.h"
#import "MessageView.h"
#import "FaceUtil.h"
#import "CloudFileModel.h"
#import "TextMsgExtDefine.h"

@implementation LastRecordView

@synthesize msgBody;
@synthesize specialColor;
@synthesize specialStr;
@synthesize textFont;
@synthesize textColor;

- (void)dealloc
{
    self.textColor = nil;
    self.textFont = nil;
    self.msgBody = nil;
    self.specialStr = nil;
    self.specialColor = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//特殊字符要显示不同的颜色，首先如果有特殊字符，那么得到一个颜色数组
-(NSArray *)getColorArray:(NSString *)curStr
{
	if(!self.specialStr || self.specialStr.length == 0)
	{
		return nil;
	}
    else
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:curStr.length];
        for(int i = 0;i<curStr.length;i++)
        {
            [colorArray addObject:@"0"];
        }
        
        NSRange range = [curStr rangeOfString:self.specialStr options:NSCaseInsensitiveSearch];
        while(range.length > 0)
        {
            for(int i=0;i<range.length;i++)
            {
                [colorArray replaceObjectAtIndex:(range.location + i) withObject:@"1"];
            }
            range = [curStr rangeOfString:self.specialStr options:NSCaseInsensitiveSearch range:NSMakeRange(range.location + range.length, curStr.length - (range.location + range.length))];
        }
        return colorArray;
    }
}

- (void)display
{
    CGRect _frame = self.frame;
    _frame.size.width = self.maxWidth;
    self.frame = _frame;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
#ifdef _LANGUANG_FLAG_
    
    NSData *bodyData = [self.msgBody dataUsingEncoding:NSUTF8StringEncoding];
    if (bodyData) {
        NSDictionary *appMsgDic = [NSJSONSerialization JSONObjectWithData:bodyData options:kNilOptions error:nil];
        if (appMsgDic != nil && [appMsgDic isKindOfClass:[NSDictionary class]])
        {
            if ([appMsgDic[KEY_MSG_TYPE] isEqual:KEY_LANGUANG_MEETING_TYPE] || [appMsgDic[KEY_MSG_TYPE] isEqual:KEY_LANGUANG_NEWS_TYPE]) {
                
                self.msgBody = appMsgDic[@"title"];
            }else if ([appMsgDic[KEY_MSG_TYPE] isEqualToString:LOCATION_TYPE]){
                
                self.msgBody = @"[位置]";
            }else if ([appMsgDic[@"type"] isEqualToString:@"redPacket"]){

                self.msgBody = [NSString stringWithFormat:@"[蓝信红包]%@",appMsgDic[@"greeting"]];
            }
            else if ([appMsgDic[@"type"] isEqualToString:@"redPacketAction"]){
                
                return;
            }
            else if([appMsgDic[KEY_MSG_TYPE] isEqual:KEY_REPLY_MSG_TYPE])  // 如果是定向回复信息
            {
                self.msgBody = appMsgDic[@"content"];
                
            }
        }
    }

#endif

//    如果一行不能完全显示，则显示...,表示还有未显示的内容
    static NSString *moreStr = @"...";
    float moreStrWidth = [moreStr sizeWithFont:self.textFont].width;
    
//    如果特殊字符很长，或者特殊字符比较靠后，不能够首先显示，则要先处理后
    if (self.specialStr && self.specialStr.length > 0) {
        NSRange _range = [self.msgBody rangeOfString:self.specialStr options:NSCaseInsensitiveSearch];
        
        if (_range.length > 0) {
            int loc = _range.location;
            if (loc > 0) {
                NSString *tailStr = [self.msgBody substringFromIndex:(_range.location + _range.length)];
                NSString *headerStr = [self.msgBody substringToIndex:(_range.location + _range.length)];
                
//                特殊字符的尺寸
                float specialStrWidth = [self.specialStr sizeWithFont:self.textFont].width;
                
                CGSize _size = [headerStr sizeWithFont:self.textFont];
                if (_size.width + specialStrWidth >= self.maxWidth - 2 * moreStrWidth) {
                    int subIndex = 0;
                    while (_size.width + specialStrWidth >= self.maxWidth - 2 * moreStrWidth ) {
                        if (subIndex == loc) {
                            break;
                        }
                        headerStr = [headerStr substringFromIndex:1];
                        subIndex ++ ;
                        _size = [headerStr sizeWithFont:self.textFont];
                    }
                    self.msgBody = [NSString stringWithFormat:@"%@%@%@",moreStr,headerStr,tailStr];
//                    NSLog(@"缩减后的msgbody:%@",self.msgBody);
                }
            }            
        }
    }
    
    
    NSMutableArray *msgArray = [NSMutableArray array];
    MessageView *messageView = [MessageView getMessageView];
    [messageView getImageRange:self.msgBody :msgArray];

//    默认为16号字
    UIFont *font = self.textFont;
	//	字体颜色
	UIColor *curTextColor;
	
	//	输出字符或图片的位置
	CGPoint point;
    
	//
	float pointX = 0;
	float pointY = 0;
	
	//	字符或这表情的大小
	CGSize tempSize;
	
	NSString *tempStr;
    
    NSString *oneChar;
	
	float _width;

    for (int i =0; i < [msgArray count]; i++)
    {
        tempStr = [msgArray objectAtIndex:i];
        //			如果是表情
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
            
            NSString *imageName = [FaceUtil getFaceIconNameWithFaceMsg:tempStr];
            UIImage *image = [StringUtil getImageByResName:imageName];
            
			
			_width = pointX + KFacialSizeWidth;//image.size.width/2;
			
			if(_width > (self.maxWidth - moreStrWidth))
			{
//                如果已经超过了一行，那么后面的数据也不用处理了显示...
                [self.textColor set];
                [moreStr drawAtPoint:CGPointMake(pointX, pointY) withFont:font];
                break;
			}
			
			[image drawInRect:CGRectMake(pointX, pointY, KFacialSizeWidth-7,KFacialSizeWidth-7)];
            pointX = pointX +KFacialSizeWidth-6;
		}
        else
        {
            
            NSArray *colorArray = [self getColorArray:tempStr];
            for (int j = 0; j < tempStr.length; j++)
            {
                _width = pointX;
                oneChar = [tempStr substringWithRange:NSMakeRange(j, 1)];
                tempSize = [oneChar sizeWithFont:font];
                
                if ((_width + tempSize.width) > (self.maxWidth - moreStrWidth))
                {
                    //	如果超过了最大行则停止处理
                    [self.textColor set];
                    [moreStr drawAtPoint:CGPointMake(pointX, pointY) withFont:font];
                    break;
                }
                if(colorArray && [[colorArray objectAtIndex:j]intValue] == 1)
                {//着重显示
                    curTextColor = self.specialColor;
                }
                else
                {
                    curTextColor = self.textColor;
                }
                [curTextColor set];
                
                point = CGPointMake(pointX, pointY);
                [oneChar drawAtPoint:point withFont:font];
                
                pointX = pointX + tempSize.width;
            }
        }
    }
}

@end
