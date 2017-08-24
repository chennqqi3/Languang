//
//  TestCoreTextView.m
//  testCoreText
//
//  Created by  lyong on 13-8-14.
//  Copyright (c) 2013年 lyong. All rights reserved.
//

#import "TestCoreTextView.h"

@implementation TestCoreTextView
@synthesize originalStr;
@synthesize imageArray;
@synthesize content;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
//        self.originalStr=@"解析所有触发点击事件和替换所有需要http://www.baidu.com显示图片的位置test解析所有http://www.xo.com.cn触发点击事件\n和替换所有需4354564576547要显示图片WWW.GGGG 的位置test解析所有触发986768980点击事件和替换所有需要显示图片的位置test解析所有触发点击www.google.com事件和替换所有需要显http://www.cnblogs.com/chivas/archive/2012/03/30/2424511.html示图片的位置test----core---text";
//        nowColor=[UIColor blueColor];
        activieIndex=-1;
    }
    return self;
}

-(void)buildAttribute{
   
    if (activieArray==nil) {
        activieArray=[[NSMutableArray alloc]init];
    }
    [activieArray removeAllObjects];
    if (new_originalStr) {
        [new_originalStr release];
    }
    new_originalStr=[[NSMutableString alloc]initWithFormat:@"%@",originalStr];
//    NSString *tempstr=[NSString stringWithFormat:@"%@",self.originalStr];
//    NSString *newmessage = [tempstr  stringByReplacingOccurrencesOfString:@".com" withString:@".com " options:NSRegularExpressionSearch range:NSMakeRange(0, [tempstr  length])];
//    newmessage = [newmessage  stringByReplacingOccurrencesOfString:@".cn" withString:@".cn " options:NSRegularExpressionSearch range:NSMakeRange(0, [newmessage  length])];
//    newmessage = [newmessage  stringByReplacingOccurrencesOfString:@".html" withString:@".html " options:NSRegularExpressionSearch range:NSMakeRange(0, [newmessage  length])];
//    //newmessage = [newmessage  stringByReplacingOccurrencesOfString:@" ." withString:@"." options:NSRegularExpressionSearch range:NSMakeRange(0, [newmessage  length])];
//    newmessage = [newmessage  stringByReplacingOccurrencesOfString:@" /" withString:@"/" options:NSRegularExpressionSearch range:NSMakeRange(0, [newmessage  length])];
//
//    new_originalStr=[NSMutableString stringWithFormat:@"%@",newmessage];
//    NSError *error = NULL;
//    NSDataDetector *checkdetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
//    [checkdetector enumerateMatchesInString:new_originalStr options:0 range:NSMakeRange(0, [new_originalStr length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
//        
//        NSRange matchRange = [match range];
//        //  NSRange matchRange = [match range];
//        if ([match resultType] == NSTextCheckingTypeLink) {
//        NSLog(@"---- location %d  length %d",matchRange.location,matchRange.length);
//        NSLog(@"----urlstr--  %@",[new_originalStr substringWithRange:matchRange]);
//        NSString *urlstr=[new_originalStr substringWithRange:matchRange];
//            
//     //  NSString *newmessage = [message  stringByReplacingOccurrencesOfString:@" " withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, [message  length])];
//        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
//            
//              //
//        }
//    }];

    self.content = [[NSMutableAttributedString alloc]initWithString:new_originalStr];
  
    for (int i=0; i<[self.imageArray count]; i++) {
        NSDictionary *dic=[self.imageArray objectAtIndex:i];
        NSString *imgName =[dic objectForKey:@"imageName"];
       
        //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
        CTRunDelegateCallbacks imageCallbacks;
        imageCallbacks.version = kCTRunDelegateVersion1;
        imageCallbacks.dealloc = RunDelegateDeallocCallback;
        imageCallbacks.getAscent = RunDelegateGetAscentCallback;
        imageCallbacks.getDescent = RunDelegateGetDescentCallback;
        imageCallbacks.getWidth = RunDelegateGetWidthCallback;
        //创建CTRun回调
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, imgName);
        //这里为了简化解析文字，所以直接认为最后一个字符是需要显示图片的位置，对需要显示图片的位置，都用空字符来替换原来的字符，空格用于给图片留位置
        NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
        //设置图片预留字符使用CTRun回调
        [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(id)runDelegate range:NSMakeRange(0,1)];
        CFRelease(runDelegate);
        //设置图片预留字符使用一个imageName的属性，区别于其他字符
        NSString *imageid=[dic objectForKey:@"imageId"];
        [imageAttributedString addAttribute:imageid value:imgName range:NSMakeRange(0,1)];
        int index=[[dic objectForKey:@"imageLocation"]intValue];
 //        NSLog(@"-------imgName- %@ ---index---%@ --%d",imgName,imageid,index);
//        if (index<[content length]) {
        [new_originalStr insertString:@" " atIndex:index];
        [self.content insertAttributedString:imageAttributedString atIndex:index];
//        }else
//        {
//            [new_originalStr appendString:@" "];
//            [content appendAttributedString:imageAttributedString];
//        }
       
    }
//    //创建图片的名字
//    NSString *imgName = @"smile.png";
//    //设置CTRun的回调，用于针对需要被替换成图片的位置的字符，可以动态设置图片预留位置的宽高
//    CTRunDelegateCallbacks imageCallbacks;
//    imageCallbacks.version = kCTRunDelegateVersion1;
//    imageCallbacks.dealloc = RunDelegateDeallocCallback;
//    imageCallbacks.getAscent = RunDelegateGetAscentCallback;
//    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
//    imageCallbacks.getWidth = RunDelegateGetWidthCallback;
//    //创建CTRun回调
//    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, imgName);
//    //这里为了简化解析文字，所以直接认为最后一个字符是需要显示图片的位置，对需要显示图片的位置，都用空字符来替换原来的字符，空格用于给图片留位置
//    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
//    //设置图片预留字符使用CTRun回调
//    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(id)runDelegate range:NSMakeRange(0,1)];
//    CFRelease(runDelegate);
//    //设置图片预留字符使用一个imageName的属性，区别于其他字符
//    [imageAttributedString addAttribute:@"imageName" value:imgName range:NSMakeRange(0,1)];
//  
//    [new_originalStr insertString:@" " atIndex:5];
//    [new_originalStr insertString:@" " atIndex:6];
//     [new_originalStr insertString:@" " atIndex:7];
//    [new_originalStr insertString:@" " atIndex:9];
//    [new_originalStr insertString:@" " atIndex:15];
//     [new_originalStr insertString:@" " atIndex:16];
//    
//   // [content appendAttributedString:imageAttributedString];
//    [content insertAttributedString:imageAttributedString atIndex:5];
//     [imageAttributedString addAttribute:@"imageName1" value:imgName range:NSMakeRange(0,1)];
//    [content insertAttributedString:imageAttributedString atIndex:6];
//     [imageAttributedString addAttribute:@"imageName2" value:imgName range:NSMakeRange(0,1)];
//    [content insertAttributedString:imageAttributedString atIndex:7];
//  
//    [content insertAttributedString:imageAttributedString atIndex:9];
//    
//    [content insertAttributedString:imageAttributedString atIndex:15];
//     [imageAttributedString addAttribute:@"imageName3" value:imgName range:NSMakeRange(0,1)];
//     [content insertAttributedString:imageAttributedString atIndex:16];
    

//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    NSLog(@"-version-- %f",version);
//    if (version<6.0) {
//        UIFont *font = [UIFont systemFontOfSize:13];
//        CTFontRef fontR = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
//        [self.content addAttribute:(NSString*)kCTFontAttributeName
//                             value:(id)fontR
//                             range:NSMakeRange(0, [self.content length])];
//        CFRelease(fontR);
//    }else
//    {
//        UIFont *font = [UIFont systemFontOfSize:16];
//        CTFontRef fontR = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
//        [self.content addAttribute:(NSString*)kCTFontAttributeName
//                             value:(id)fontR
//                             range:NSMakeRange(0, [self.content length])];
//        CFRelease(fontR);
//    }
    
//    UIFont *font = [UIFont systemFontOfSize:16];
//    CTFontRef fontR = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
//    [self.content addAttribute:(NSString*)kCTFontAttributeName
//                         value:(id)fontR
//                         range:NSMakeRange(0, [self.content length])];
//    CFRelease(fontR);
    
    //设置字体
//    CTFontRef aFont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
 //   if (fontR) {
    //  CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(aFont, 0.0, NULL, kCTFontItalicTrait, kCTFontBoldTrait);    //将默认黑体字设置为其它字体
    //@"Helvetica"  @"Helvetica Bold"
    CTFontRef ref = CTFontCreateWithName((CFStringRef)@"Helvetica", 16, NULL);
    CTFontRef italicFont = CTFontCreateCopyWithSymbolicTraits(ref, 16, NULL, kCTFontItalicTrait, kCTFontBoldTrait);
  //  CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(fontR, 0.0, NULL, kCTFontItalicTrait, kCTFontBoldTrait);    //将默认黑体字设置为其它字体
   // [self.content removeAttribute:(NSString*)kCTFontAttributeName range:NSMakeRange(0,[self.content length])];
    [self.content addAttribute:(NSString*)kCTFontAttributeName
                         value:(id)italicFont
                         range:NSMakeRange(0,[self.content length])];
     CFRelease(italicFont);
  //  }
   
    
    //    if (version>5.1)
//    long number = 0;
//    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
//    [self.content addAttribute:(id)kCTStrokeWidthAttributeName value:(id)num range:NSMakeRange(0, [self.content length])];
    
//    //设置空心字颜色
//    [self.content addAttribute:(id)kCTStrokeColorAttributeName value:(id)[UIColor darkTextColor].CGColor range:NSMakeRange(0, [self.content length])];
    //换行模式，设置段落属性
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    CTParagraphStyleSetting settings[] = {
        lineBreakMode
    };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)style forKey:(id)kCTParagraphStyleAttributeName ];
    [self.content addAttributes:attributes range:NSMakeRange(0, [self.content length])];
  //  [content addAttribute:(id)kCTFontAttributeName value:(id)[UIFont systemFontOfSize:16] range:NSMakeRange(0, [content length])];
//    CTFontRef font = CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Bold", 16, NULL);
//    NSDictionary *txtAttr = @{
//                              (NSString *)kCTFontAttributeName : (id)CFBridgingRelease(font)
//                              };
  
//    NSString * urlString = @"blah blah blah http://www.google.com blah blah blah http://www.stackoverflow.com blah blah balh http://www.apple.com";
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
//        NSArray *urls = [new_originalStr componentsMatchedByRegex:@"www.*.com"];
//        NSLog(@"urls: %@", urls);
//        NSString *urlstr;
//        NSRange range;
//        for (int i=0; i<[urls count]; i++) {
//            urlstr=[urls objectAtIndex:i];
//            range=[new_originalStr rangeOfString:urlstr];
//            NSMutableDictionary *attributes=[[NSMutableDictionary alloc]init];
//            NSString *loaction=[NSString stringWithFormat:@"%d",range.location];
//            NSString *length=[NSString stringWithFormat:@"%d",range.length];
//            [attributes setValue:loaction forKey:@"location"];
//            [attributes setValue:length forKey:@"length"];
//            [attributes setValue:@"url" forKey:@"type"];
//            [activieArray addObject:attributes];
//            [attributes release];
//            if (activieIndex>=range.location&&activieIndex<=(range.location+range.length)) {
//                [content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor greenColor] CGColor] range:range];
//            }else
//            {
//                [content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor] CGColor] range:range];
//            }
//        }
//
//    }
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
    [detector enumerateMatchesInString:new_originalStr options:0 range:NSMakeRange(0, [new_originalStr length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange matchRange = [match range];
      //  NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSMutableDictionary *attributes=[[NSMutableDictionary alloc]init];
            NSString *loaction=[NSString stringWithFormat:@"%d",matchRange.location];
            NSString *length=[NSString stringWithFormat:@"%d",matchRange.length];
            [attributes setValue:loaction forKey:@"location"];
            [attributes setValue:length forKey:@"length"];
            [attributes setValue:@"url" forKey:@"type"];
            [activieArray addObject:attributes];
            [attributes release];
            NSLog(@"---- location %d  length %d",matchRange.location,matchRange.length);
            //
            //        attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[nowColor CGColor], kCTForegroundColorAttributeName, nil];
 
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
          
            NSMutableDictionary *attributes=[[NSMutableDictionary alloc]init];
            NSString *loaction=[NSString stringWithFormat:@"%d",matchRange.location];
            NSString *length=[NSString stringWithFormat:@"%d",matchRange.length];
            [attributes setValue:loaction forKey:@"location"];
            [attributes setValue:length forKey:@"length"];
            [attributes setValue:@"tel" forKey:@"type"];
            [activieArray addObject:attributes];
            [attributes release];
            NSLog(@"---- location %d  length %d",matchRange.location,matchRange.length);
            //
        }
        
        if (activieIndex>=matchRange.location&&activieIndex<=(matchRange.location+matchRange.length)) {
            [self.content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor grayColor] CGColor] range:matchRange];
        }else
        {
            [self.content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor] CGColor] range:matchRange];
        }
//        CFAttributedStringSetAttributes(originalStr, CFRangeMake(matchRange.location, matchRange.length), (CFDictionaryRef)attributes, NO);
    }];
  

//    NSError *tel_error = NULL;
//    NSDataDetector *tel_detector = [NSDataDetector dataDetectorWithTypes: NSTextCheckingTypePhoneNumber error:&tel_error];
//    [tel_detector enumerateMatchesInString:originalStr options:0 range:NSMakeRange(0, [originalStr length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
//        
//        NSRange matchRange = [match range];
//        NSMutableDictionary *attributes=[[NSMutableDictionary alloc]init];
//        NSString *loaction=[NSString stringWithFormat:@"%d",matchRange.location];
//        NSString *length=[NSString stringWithFormat:@"%d",matchRange.length];
//        [attributes setValue:loaction forKey:@"location"];
//        [attributes setValue:length forKey:@"length"];
//        [attributes setValue:@"tel" forKey:@"type"];
//        [activieArray addObject:attributes];
//        [attributes release];
//        NSLog(@"---- location %d  length %d",matchRange.location,matchRange.length);
//        //
//        //        attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[nowColor CGColor], kCTForegroundColorAttributeName, nil];
//        if (activieIndex>=matchRange.location&&activieIndex<=(matchRange.location+matchRange.length)) {
//            [content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor greenColor] CGColor] range:matchRange];
//        }else
//        {
//            [content addAttribute:(id)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor] CGColor] range:matchRange];
//        }
//        
//        //        CFAttributedStringSetAttributes(originalStr, CFRangeMake(matchRange.location, matchRange.length), (CFDictionaryRef)attributes, NO);
//    }];
//
    //这里对需要进行点击事件的字符heightlight效果，这里简化解析过程，直接hard code需要heightlight的范围
   
}
//CTRun的回调，销毁内存的回调
void RunDelegateDeallocCallback( void* refCon ){
    
}

//CTRun的回调，获取高度
CGFloat RunDelegateGetAscentCallback( void *refCon ){
   // NSString *imageName = (NSString *)refCon;
    return 24;//[UIImage imageNamed:imageName].size.height;
}

CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}
//CTRun的回调，获取宽度
CGFloat RunDelegateGetWidthCallback(void *refCon){
 //   NSString *imageName = (NSString *)refCon;
    return 24;//[UIImage imageNamed:imageName].size.width;
}
- (int)getAttributedStringHeightWithString:(NSAttributedString *)  string  WidthValue:(int) width
{
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
    
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];  
    //设置NSMutableAttributedString的所有属性
    [self buildAttribute];
   // NSLog(@"rect:%@ --height- %0.0f",NSStringFromCGRect(rect),self.frame.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置context的ctm，用于适应core text的坐标体系
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    //设置CTFramesetter

    CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.content);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height));
    //创建CTFrame
    _frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.content.length), path, NULL);
    //把文字内容绘制出来
    CTFrameDraw(_frame, context);
    //获取画出来的内容的行数
    CFArrayRef lines = CTFrameGetLines(_frame);
    //获取每行的原点坐标
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), lineOrigins);
   // NSLog(@"line count = %ld",CFArrayGetCount(lines));
     float viewheight=0;
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        //获取每行的宽度和高度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
      //  NSLog(@"ascent = %f,descent = %f,leading = %f",lineAscent,lineDescent,lineLeading);
        //获取每个CTRun
        CFArrayRef runs = CTLineGetGlyphRuns(line);
       // NSLog(@"run count = %ld",CFArrayGetCount(runs));
        viewheight=viewheight+lineAscent;
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            //获取每个CTRun
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            //调整CTRun的rect
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
          
            
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            //NSLog(@"----line-- lineOrigin.y -- %0.0f -runDescent %0.0f runAscent %0.0f",lineOrigin.y,runDescent,runAscent);
            for (int k=0; k<[self.imageArray count]; k++) {
                NSDictionary *dic=[self.imageArray objectAtIndex:k];
                NSString *imageid=[dic objectForKey:@"imageId"];
                NSString *imageName = [attributes objectForKey:imageid];
                //  NSLog(@"-11111-- imagename  %@ --%@",imageName,[NSString stringWithFormat:@"imagename%d",j]);
                //图片渲染逻辑，把需要被图片替换的字符位置画上图片
                if (imageName) {
                    UIImage *image = [UIImage imageNamed:imageName];
                    if (image) {
                        CGRect imageDrawRect;
                        imageDrawRect.size = CGSizeMake(24, 24);
                        imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                        imageDrawRect.origin.y = lineOrigin.y;
                        CGContextDrawImage(context, imageDrawRect, image.CGImage);
                    //    NSLog(@"--imge-x %0.0f  y %0.0f",imageDrawRect.origin.x,imageDrawRect.origin.y);
                    }
                }
            }
     
        }
        
    }
    CGContextRestoreGState(context);
  //  NSLog(@"-----viewheight--  %0.0f",viewheight);
//    if (CFArrayGetCount(lines)>0) {
//        self.frame=CGRectMake(0, 0, self.frame.size.width,viewheight);
//        CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, viewheight));
//    }

}
//接受触摸事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    NSLog(@"touch:%@",NSStringFromCGPoint(location));
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(_frame);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(_frame);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
      //  NSLog(@"origin:%@",NSStringFromCGPoint(origin));
     //   NSLog(@"rect:%@",NSStringFromCGRect(rect));
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        NSLog(@"y:%f",y);
        //判断点击的位置处于那一行范围内
        if ((location.y <= y) && (location.x >= origin.x))
        {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    NSLog(@"index:%ld",index);
    for (int i=0; i<[activieArray count]; i++) {
        NSDictionary *dic=[activieArray objectAtIndex:i];
        NSString *loaction=[dic objectForKey:@"location"];
        NSString *length=[dic objectForKey:@"length"];
        NSString *type=[dic objectForKey:@"type"];
        //判断点击的字符是否在需要处理点击事件的字符串范围内，这里是hard code了需要触发事件的字符串范围
        if (index>=loaction.intValue&&index<=(length.intValue+loaction.intValue)) {
            //        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"click event" message:[originalStr substringWithRange:NSMakeRange(0, 10)] delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
            //        [alert show];
            activieIndex=index;
            nowColor=[UIColor yellowColor];
            [self setNeedsDisplay];
            if([type isEqualToString:@"tel"])
            {  
                NSString *iphonestr=[new_originalStr substringWithRange:NSMakeRange([loaction intValue], [length intValue])];
                [self  showTelephone:iphonestr];
            }
            if([type isEqualToString:@"url"])
            {
                NSString *iphonestr=[new_originalStr substringWithRange:NSMakeRange([loaction intValue], [length intValue])];
                [self  showUrl:iphonestr];
            }
            
            break;
        }
    }    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    nowColor=[UIColor blueColor];
    activieIndex=-1;
    [self setNeedsDisplay];
  

}

-(void)showTelephone:(NSString *)iphoneNumStr
{
    NSURL *phoneURL;
    //手机call
    phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",iphoneNumStr]];
    NSLog(@"-tel-here---doing-- %@",iphoneNumStr);
    
    UIWebView *callPhoneWebVw = [[UIWebView alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:phoneURL];
    [callPhoneWebVw loadRequest:request];
}

-(void)showUrl:(NSString *)urlstr
{
    NSString *newstr=[urlstr lowercaseString];
    NSRange httprange=[newstr rangeOfString:@"http://"];
    NSRange httpsrange=[newstr rangeOfString:@"https://"];
    NSString *newhttp=newstr;
    if (httprange.location==NSNotFound && httpsrange.location==NSNotFound ) {
        newhttp=[NSString stringWithFormat:@"http://%@",urlstr];
    }
    [[NSNotificationCenter defaultCenter ]postNotificationName:OPEN_WEB_NOTIFICATION object:newhttp userInfo:nil];
    
//    NSString *newstr=[urlstr lowercaseString];
//    NSRange httprange=[newstr rangeOfString:@"http://"];
//    NSString *newhttp=newstr;
//    if (httprange.location==NSNotFound) {
//        newhttp=[NSString stringWithFormat:@"http://%@",urlstr];
//    }
// [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newhttp]];
}
@end
