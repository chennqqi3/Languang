

#import "TextMessageView.h"
//	需要把文本和图片展示在一个view中
#import "FontSizeUtil.h"
#import "faceDefine.h"
#import "FaceUtil.h"

@implementation TextMessageView
@synthesize maxWidth;
@synthesize textColor;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
	self.opaque = YES;
	self.backgroundColor = [UIColor clearColor];
    return self;
}

-(void)dealloc
{
    self.textColor = nil;
	[message release];
	[super dealloc];
}
-(void)setMessage:(NSArray *)_message
{
	message = [_message retain];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // NSMutableArray *numRangeArray=[[NSMutableArray alloc]init];
    
//    获取字号，默认是16号字
	UIFont *font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
	//	字体颜色
	UIColor *textColor = [UIColor blackColor];
	
	//	输出字符或图片的位置
	CGPoint point;
    
	//
	float pointX = LEFT_OFFSET;
	float pointY = TOP_OFFSET;
	
	//	字符或这表情的大小
	CGSize tempSize;
	
	NSString *tempStr;
	
	//	一行的内容的最大长度，最大长度
	float rowWidth = self.maxWidth - LEFT_OFFSET - RIGHT_OFFSET;
	
	//	行高
    CGSize _size = [@"我" sizeWithFont:font];
	float rowHeight = _size.height;
    
//    表情的尺寸要随着字号的变化而变化
    float faceSize = rowHeight;
    
	float _width;
	
	//					设置画笔颜色
    if (self.textColor) {
        [self.textColor set];
    }else{
        [textColor set];
    }
    
	for(int i = 0;i<[message count];i++)
	{
		//            取出数组中的第一条记录
		tempStr=[message objectAtIndex:i];
		
		//			如果是表情
		if ([tempStr hasPrefix: BEGIN_FLAG] && [tempStr hasSuffix: END_FLAG])
		{
            NSString *imageName = [FaceUtil getFaceIconNameWithFaceMsg:tempStr];
            
			UIImage *image = [StringUtil getImageByResName:imageName];
            
			
			_width = pointX + faceSize;//image.size.width/2;
			
			if(_width > rowWidth)
			{
                //				一个新行，那么先移到下一行，然后画图，然后pointX向后移
				pointY = pointY + rowHeight;
				pointX = LEFT_OFFSET;
			}
			
			[image drawInRect:CGRectMake(pointX, pointY, faceSize,faceSize)];//image.size.width/2, image.size.height/2)];
            pointX = pointX +faceSize;// image.size.width/2;
		}
		else
		{
            //           NSLog(@"-----numRangeArray--count-- %d",[self.numRangeArray count]);
            //选出位置
			_width = pointX;
			
            //			通过判断可以不用一次写一个字符，而是写一个字符串
			int fromIndex = 0;
            
			for (int j = 0; j < [tempStr length]; j++)
			{
                //				NSLog(@"tempStr len is %d,j is %d,fromIndex is %d",tempStr.length,j,fromIndex);
				//					取出一个字符
				NSString *temp = [tempStr substringWithRange:NSMakeRange(j, 1)];
				
				if([temp isEqualToString:@"\n"] || [temp isEqualToString:@"\r"])
				{
					//					一个新的行
					NSString *subStr = [tempStr substringWithRange:NSMakeRange(fromIndex, j-fromIndex)];
					//						//			NSLog(@"draw str:%@",subStr);
					point = CGPointMake(pointX, pointY);
					
					[subStr drawAtPoint:point withFont:font];
					
					fromIndex = j + 1;
                    
					pointY = pointY + rowHeight;
					pointX =LEFT_OFFSET;
					_width = 0;
				}
				else
				{
					tempSize = [temp sizeWithFont:font];
					
					_width = _width + tempSize.width;
					if(_width > rowWidth && j < tempStr.length - 1)
					{
						//					一个新的行
						NSString *subStr = [tempStr substringWithRange:NSMakeRange(fromIndex, j-fromIndex)];
                        //						//			NSLog(@"draw str:%@",subStr);
						point = CGPointMake(pointX, pointY);
						
						[subStr drawAtPoint:point withFont:font];
						
						fromIndex = j;
						pointX = LEFT_OFFSET;
						pointY = pointY + rowHeight;
						_width = pointX + tempSize.width;
						
					}
					//				已经到了最后一个字符
					else if(j == tempStr.length-1)
					{
						NSString *subStr = [tempStr substringFromIndex:fromIndex];
						tempSize = [subStr sizeWithFont:font];
						
						_width = pointX + tempSize.width;
						//					输入完所有字符，超过了最大长度，那么最后一个字符需要另起一行
						if(_width < rowWidth)
						{ //  NSLog(@"draw str------1");
							point = CGPointMake(pointX, pointY);
							
							//						NSLog(@"draw str %@",subStr);
							[subStr drawAtPoint:point withFont:font];
							
							pointX = pointX + tempSize.width;
							
						}
						else
						{ // NSLog(@"draw str------2");
							NSString *tempSubStr = [subStr substringToIndex:(subStr.length - 1)];
							point = CGPointMake(pointX, pointY);
							//						NSLog(@"draw str %@",tempSubStr);
							[tempSubStr drawAtPoint:point withFont:font];
							
							pointX = 0;
							pointY = pointY + rowHeight;
							point = CGPointMake(pointX, pointY);
							tempSubStr = [subStr substringFromIndex:(subStr.length - 1)];
							//						NSLog(@"draw str %@",tempSubStr);
							
							[tempSubStr drawAtPoint:point withFont:font];
							pointX = pointX + [tempSubStr sizeWithFont:font].width;
							
						}
					}
				}
			}
		}
	}
}
@end
