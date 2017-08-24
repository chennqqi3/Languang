#import "OHAttributedLabelEx.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "MarkupParser.h"
#import "SCGIFImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "RegexKitLite.h"
#import "eCloudConfig.h"
#import "FaceUtil.h"
//表情格式定义
#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

@interface OHAttributedLabelEx()
{
    OHAttributedLabel * label_;
}
@property(nonatomic, retain) OHAttributedLabel * label;

@end


@implementation OHAttributedLabelEx
@synthesize delegate = delegate_;
@synthesize text = text_;
@synthesize maxWidth = maxWidth_;
@synthesize frameOrigin = frameOrigin_;
@synthesize label = label_;

- (id)init
{
    if(self = [super init])
    {
        self.label = [[[OHAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.delegate = (id)self;
        self.label.automaticallyAddLinksForType = 0;
#ifdef _TAIHE_FLAG_
        self.label.underlineLinks = YES;
#else
        self.label.underlineLinks = NO;
#endif
        self.label.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [text_ release];
    [label_ release];
    [super dealloc];
}

- (void)setFrameOrigin:(CGPoint)frameOrigin
{
    frameOrigin_ = frameOrigin;
    
    CGRect frame = self.label.frame;
    frame.origin = frameOrigin_;
    self.label.frame = frame;
}

- (void)setTextColor:(UIColor *)col{ self.label.textColor = col;  }
- (void)setLinkColor:(UIColor *)col{ self.label.linkColor = col; }
- (void)setFont:(UIFont *)font{ self.label.font = font; }
- (UIFont *)font{ return self.label.font; }

- (void)updateUI
{
    [self decodeText:self.text];
    [self.label setLineBreakMode:NSLineBreakByWordWrapping];
    // frame
    CGRect r;
    r.origin = self.frameOrigin;
    r.size = [self.label sizeThatFits:CGSizeMake(self.maxWidth, CGFLOAT_MAX)];
    self.label.frame = r;
    
    /// add emoji images to label
    //
    // must remove last time's subviews(all subview is SCGIFImageView).
    for(UIView * subView in self.label.subviews)
        [subView removeFromSuperview];
    // must remove the last time's imageInfoArr.
    [self.label.imageInfoArr removeAllObjects];
    // update UI, must be here. So the text can acting on the self.label.imageInfoArr.
    [self.label.layer display];// then self.label.imageInfoArr has objs.
    
    //    update by shisp 要从OpenCtxBundle里获取资源，从mainBundle里获取不到
    //获取静态库里面的资源
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"OpenCtxBundle" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString * imgPath;
    NSData * imgData;
    SCGIFImageView *imgView;
    int lineCount = 0;
    for (NSArray * imgInfo in self.label.imageInfoArr)
    {
        imgPath = [bundle pathForResource:[imgInfo objectAtIndex:0] ofType:nil];
        imgData = [[NSData alloc] initWithContentsOfFile:imgPath];
        imgView = [[SCGIFImageView alloc] initWithGIFData:imgData];
        [imgData release];
        imgView.frame = CGRectFromString([imgInfo objectAtIndex:2]);
        
        // 重新计算带表情的宽度  by yanlei
        
        if ((imgView.frame.origin.x+1) > r.size.width) {
            CGRect tmpRect = self.label.frame;
            if ((imgView.frame.origin.x-self.maxWidth*lineCount+20) > self.maxWidth) {
                lineCount++;
                tmpRect.size.height += imgView.frame.size.height;
            }
            
            tmpRect.size.width += imgView.frame.size.width;
            if (tmpRect.size.width >= self.maxWidth) {
                tmpRect.size.width = self.maxWidth;
            }
            self.label.frame = tmpRect;
            NSLog(@"self.label.frame--------------- = %@",NSStringFromCGRect(self.label.frame));
            
            // 改变表情的位置
            tmpRect = imgView.frame;
            if (tmpRect.origin.x+tmpRect.size.width > self.maxWidth) {
                tmpRect.origin.x -= self.maxWidth*lineCount;
                tmpRect.origin.y += tmpRect.size.height*lineCount;
            }
            imgView.frame = tmpRect;
            NSLog(@"imgView.frame = %@",NSStringFromCGRect(imgView.frame));
        }
        
        [self.label addSubview:imgView]; // add
        [imgView release];
        [self.label bringSubviewToFront:imgView];
    }
}

+ (CGSize)heightWithText:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    NSMutableAttributedString * attrStr = [self help2GetAttributedStringWithText:text font:font forLabel:nil];
    return attrStr ? [attrStr sizeConstrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) fitRange:NULL] : CGSizeZero;
}

- (UIView *)view{ return self.label; }

#pragma mark - Decode Text

- (void)decodeText:(NSString *)text
{
    NSArray * linkArr;
    /*
     <content>您可能需要以下服务：
     1. [link]万达广场楼层简介[/link]
     2. [link]广州萝岗万达广场万达影城门店信息[/link]
     3. [link]江阴五洲广场万达影城门店信息[/link]
     4. [link]余姚万达广场万达影城门店信息[/link]
     5. [link]万达广场多经场地招商[/link]
     点击相应问题回复答案</content>
     
     1. [link submit="1"]员工借款[/link]
     */
    
    // 处理<;a href=&quot;http://www.wanda.cn/navigation/weixin/&quot; target=&quot;_blank&quot;>;点击此处<;/a>;标签
    NSMutableArray *alinkArrTmp = [NSMutableArray array];
    if ([text rangeOfString:@"&lt;a href="].length > 0) {
        // 处理<;a href=标签，将显示的蓝色字体和跳转的链接放到一个数组中
        NSArray *alinksTmpArr = [text componentsSeparatedByString:@"&lt;a href=\""];
        for (int i = 1; i < alinksTmpArr.count; i++) {
            NSString *hrefContent = alinksTmpArr[i];
            // 获取显示的内容
            NSString *hrefClickContent = [[[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0] componentsSeparatedByString:@"&gt;"] lastObject];
            
            // 获取跳转的链接
            NSString *hrefGoto = [NSString stringWithFormat:@"href-%@",[hrefContent componentsSeparatedByString:@"\""][0]];
            [alinkArrTmp addObject:hrefClickContent];[alinkArrTmp addObject:hrefGoto];
            
            // 将<a标签中没用的东西都去掉
            text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@%@",@"&lt;a href=\"",[hrefContent componentsSeparatedByString:@"&lt;/a&gt;"][0],@"&lt;/a&gt;"] withString:hrefClickContent];
        }
    }
    // 对在小万中有链接功能的标签文字的解析
    if ([text rangeOfString:@"<name>wiki</name>"].length <= 0 && ([text rangeOfString:@"<relatedQuestions>"].length > 0 || [text rangeOfString:@"[link]"].length > 0 || [text rangeOfString:@"[link submit="].length > 0)) {
        
//        搜索的起始位置 默认为0
        int searchStartIndex = 0;
        
        NSMutableArray *linkArrTmp = [NSMutableArray array];
        if ([text rangeOfString:@"[link]"].length > 0 || [text rangeOfString:@"[link submit="].length > 0){
            if ([text rangeOfString:@"[AGENT]"].length > 0) {
                text = [text stringByReplacingOccurrencesOfString:@"[AGENT]" withString:@""];
                text = [text stringByReplacingOccurrencesOfString:@"[/AGENT]" withString:@""];
            }
            if ([text rangeOfString:@"[link submit="].length > 0) {
                NSArray *linksTmpArr = [text componentsSeparatedByString:@"[link submit="];
                for (int i = 1; i < linksTmpArr.count; i++) {
                    text = [text stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[link submit=\"%d\"]",i] withString:@"[link]"];
                }
            }
            
            // 将标签内容选出来
            NSArray *linksArr = [text componentsSeparatedByString:@"[link]"];

            searchStartIndex = (int)((NSString *)linksArr[0]).length;

            // 将标签内容选出来
            for (int i = 1; i < linksArr.count; i++) {
                NSString *linkContent = linksArr[i];
                [linkArrTmp addObject:[linkContent componentsSeparatedByString:@"[/link]"][0]];
            }
            // 将多余的
            text = [text stringByReplacingOccurrencesOfString:@"[link]" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"[/link]&#xD;" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"[/link]" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"&#xD;" withString:@""];
            linkArr = linkArrTmp;
        }
        
        NSMutableAttributedString * decodedText;
        decodedText = [[self class] help2GetAttributedStringWithText:text font:self.label.font forLabel:self.label];
        
        // link
        text = decodedText.string;
        
        NSRange searchRange = NSMakeRange((searchStartIndex > 0?searchStartIndex - 1:0), text.length - searchStartIndex);
        NSRange searchedRange;
        // 处理<a href=标签的链接
        if (alinkArrTmp.count > 0) {
            for (int i = 0; i < alinkArrTmp.count; i++) {
                NSString * alinkStr = alinkArrTmp[i];
                searchedRange = [text rangeOfString:alinkStr options:0 range:searchRange];
                [self.label addCustomLink:[NSURL URLWithString:alinkArrTmp[++i]] inRange:searchedRange];// set.
                searchRange = NSMakeRange(searchedRange.location + searchedRange.length,
                                          text.length - searchedRange.location - searchedRange.length);
            }
        }
        for (int i = 0; i < linkArr.count; i++) {
            NSString * linkStr = linkArr[i];
            searchedRange = [text rangeOfString:linkStr options:0 range:searchRange];
            [self.label addCustomLink:[NSURL URLWithString:[NSString stringWithFormat:@"www.%d.lyancom",i]] inRange:searchedRange];// set.
            searchRange = NSMakeRange(searchedRange.location + searchedRange.length,
                                      text.length - searchedRange.location - searchedRange.length);
        }
    }else{
        NSMutableAttributedString * decodedText;
        decodedText = [[self class] help2GetAttributedStringWithText:text font:self.label.font forLabel:self.label];
        
        // link
        text = decodedText.string;
        
        
        linkArr = [[self class] componentsMatchedLinkWithString:text];
        NSRange searchRange = NSMakeRange(0, text.length);
        NSRange searchedRange;
        // 处理<a href=标签的链接
        if (alinkArrTmp.count > 0) {
            for (int i = 0; i < alinkArrTmp.count; i++) {
                NSString * alinkStr = alinkArrTmp[i];
                searchedRange = [text rangeOfString:alinkStr options:0 range:searchRange];
                [self.label addCustomLink:[NSURL URLWithString:alinkArrTmp[++i]] inRange:searchedRange];// set.
                searchRange = NSMakeRange(searchedRange.location + searchedRange.length,
                                          text.length - searchedRange.location - searchedRange.length);
            }
        }
        
        for(NSString * linkStr in linkArr)
        {
            searchedRange = [text rangeOfString:linkStr options:0 range:searchRange];
            [self.label addCustomLink:[NSURL URLWithString:linkStr] inRange:searchedRange];// set.
            searchRange = NSMakeRange(searchedRange.location + searchedRange.length,
                                      text.length - searchedRange.location - searchedRange.length);
        }
    }
}

+ (NSMutableAttributedString *)help2GetAttributedStringWithText:(NSString *)text
                                                           font:(UIFont *)font /**< 必须不为空. */
                                                       forLabel:(OHAttributedLabel *)label/**< 可为空. */
{
    NSMutableAttributedString * res;
    
    // 替换掉html格式字符'<'、'>'
    text = [[text stringByReplacingOccurrencesOfString:@"<" withString:@"&lt"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt"];
    
    // emoji转换称html
    MarkupParser * mp = [[[MarkupParser alloc] init] autorelease];
    res = [mp attrStringFromMarkup:[[self class] help2TransformEmojiToHtmlFormatWithString:text emojiHeight:
                                    [@"gH" sizeWithFont:font].height]];
    //
    [res setFont:font];
    
    if(label)
    {
        [res setTextColor:label.textColor];
        [label setAttString:res withImages:mp.images];
    }
    
    return res;
}

+ (NSString *)help2TransformEmojiToHtmlFormatWithString:(NSString *)text emojiHeight:(CGFloat)emojiHeight
{
    NSArray * emojiArr = [[self class] componentsMatchedEmojiWithString:text];
    NSRange searchRange = NSMakeRange(0, text.length);
    NSRange searchedRange;
    NSString * imgName;
    for(NSString * emoji in emojiArr)
    {
        searchedRange = [text rangeOfString:emoji options:0 range:searchRange];
        
        imgName = [[self class] imageResourceNameOfEmoji:emoji];
        
        if (imgName.length)
            text = [text stringByReplacingCharactersInRange:searchedRange withString:
                    [NSString stringWithFormat:@"<img src='%@' width='%f' height='%f'>",imgName, emojiHeight, emojiHeight]];
        
        searchRange = NSMakeRange(searchedRange.location + searchedRange.length,
                                  text.length - searchedRange.location - searchedRange.length);
    }
    return text;
}

#pragma mark - OHAttributedLabelDelegate

- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if([self.delegate respondsToSelector:@selector(attributedLabelEx:didClickLinkWithURL:)])
        [self.delegate attributedLabelEx:self didClickLinkWithURL:linkInfo.URL];
    return NO;
}

#pragma mark - 表情资源名(可重载)

+ (NSString *)imageResourceNameOfEmoji:(NSString *)emoji
{
    //NSLog(@"---pic--imgName- %@",emoji);
    //if([emoji isEqualToString:@"[太开心]"])return @"face.png";
    NSString *imageName=nil;
    if ([emoji hasPrefix: BEGIN_FLAG] && [emoji hasSuffix: END_FLAG])
    {
        imageName = [FaceUtil getFaceIconNameWithFaceMsg:emoji];        
    }
    return imageName;
    // return nil;
}

#pragma mark - 正则匹配(可重载)

+ (NSArray *)componentsMatchedLinkWithString:(NSString *)text
{
    NSMutableArray *array=[NSMutableArray array];
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
    [detector enumerateMatchesInString:text options:0 range:NSMakeRange(0, [text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSRange matchRange = [match range];
        //  NSRange matchRange = [match range];
        if ([match resultType] == NSTextCheckingTypeLink) {
            //        attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[nowColor CGColor], kCTForegroundColorAttributeName, nil];
            
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            
            
            //
        }
        NSString *str=[text substringWithRange:matchRange];
        [array addObject:str];
        //        CFAttributedStringSetAttributes(originalStr, CFRangeMake(matchRange.location, matchRange.length), (CFDictionaryRef)attributes, NO);
    }];
    return array;
    //    NSString * regex = @"(https?|ftp|file)+://[^\\s]*";
    //    return regex.length ? [text componentsMatchedByRegex:regex] : [NSArray array];
}

+ (NSArray *)componentsMatchedEmojiWithString:(NSString *)text
{
    //NSString * regex = @"\\[/\\[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    //NSString * regex = @"\\[/[^\\]+]";
    
    NSString * regex = @"\\[/(\\S*?)]";
    
    return regex.length ? [text componentsMatchedByRegex:regex] : [NSArray array];
}

@end
