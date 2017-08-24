//
//  NMCustomLabel.m
//  NewsMe
//
//  Created by Robert Haining on 8/30/11.
//  Copyright 2012, News.me
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//

#import "NMCustomLabel.h"
#import "picTextViewController.h"
static NSString *kNMImageInfoAttributeName = @"kNMImageInfoAttributeName";
static NSString *kNMImageAttributeName = @"kNMImageAttributeName";
static NSString *kNMImageVerticalOffsetAttributeName = @"kNMImageVerticalOffsetAttributeName";

static NSRegularExpression *usernameRegEx;
static NSRegularExpression *usernameEndRegEx;
static NSRegularExpression *hashtagRegEx;
static NSRegularExpression *tagRegEx;
//static NSRegularExpression *markupTagRegEx;
static NSRegularExpression *spanTagRegEx;
static NSCharacterSet *emojiCharacterSet;
static NSCharacterSet *alphaNumericCharacterSet;

@interface NMCustomLabel(Private)
-(void)createAttributedString;
@property (nonatomic, strong) NSMutableDictionary *styles;
@end

@implementation NMCustomLabel

//, textColorBold
@synthesize  cleanText, ctTextAlignment, linkColor, activeLinkColor, lineHeight, numberOfLines, shouldBoldAtNames, kern, delegate;
@synthesize shouldLinkTypes;

+(NSRegularExpression *)usernameRegEx{
	return usernameEndRegEx;
}
+(NSRegularExpression *)hashtagRegEx{
	return hashtagRegEx;
}
+(void)initialize{
	if(!usernameRegEx){
		NSError *error = NULL;
		usernameRegEx = [[NSRegularExpression regularExpressionWithPattern:@"(@.+?)(?:[^0-9A-Za-z_\\.]|$)" options:NSRegularExpressionCaseInsensitive error:&error]retain];
		if(!usernameRegEx){
			NSLog(@"error creating regex: %@", error);
		}
	}
	if(!usernameEndRegEx){
		NSError *error = NULL;
		usernameEndRegEx = [[NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z_\\.]" options:NSRegularExpressionCaseInsensitive error:&error]retain];
		if(!usernameEndRegEx){
			NSLog(@"error creating regex: %@", error);
		}
	}
	if(!hashtagRegEx){
		NSError *error = NULL;
		hashtagRegEx = [[NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z]" options:NSRegularExpressionCaseInsensitive error:&error]retain];		if(!hashtagRegEx){
			NSLog(@"error creating regex: %@", error);
		}
	}
	if(!tagRegEx){
		NSError *error = NULL;
		tagRegEx =[ [NSRegularExpression regularExpressionWithPattern:@"<.+?>" options:NSRegularExpressionCaseInsensitive error:&error]retain];
		if(!tagRegEx){
			NSLog(@"error creating regex: %@", error);
		}
	}
//	if(!markupTagRegEx){
//		NSError *error = NULL;
//		markupTagRegEx = [NSRegularExpression regularExpressionWithPattern:@"<([bi])>.+?</[bi]>" options:NSRegularExpressionCaseInsensitive error:&error];
//		if(!markupTagRegEx){
//			NSLog(@"error creating markupTagRegEx: %@", error);
//		}
//	}
	if(!spanTagRegEx){
		NSError *error = NULL;
		spanTagRegEx =[ [NSRegularExpression regularExpressionWithPattern:@"<span (.+?)>.+?</span>" options:NSRegularExpressionCaseInsensitive error:&error] retain];
		if(!spanTagRegEx){
			NSLog(@"error creating spanTagRegEx: %@", error);
		}
	}
//	if(!emojiCharacterSet){
//		emojiCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"😄😊😃☺😉😍😘😚😳😌😁😜😝😒😏😓😔😞😖😥😰😨😣😢😭😂😲😱😠😡😪😷👿👽💛💙💜💗💚❤💔💓💘✨🌟💢❕❔💤💨💦🎶🎵🔥💩👍👎👌👊✊✌👋✋👐👆👇👉👈🙌🙏☝👏💪🚶🏃👫💃👯🙆🙅💁🙇💏💑💆💇💅👦👧👩👨👶👵👴👱👲👳👷👮👼👸💂💀👣💋👄👂👀👃☀☔☁⛄🌙⚡🌀🌊🐱🐶🐭🐹🐰🐺🐸🐯🐨🐻🐷🐮🐗🐵🐒🐴🐎🐫🐑🐘🐍🐦🐤🐔🐧🐛🐙🐠🐟🐳🐬💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌴🌵🌾🐚🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🔔🎉🎈💿📀📷🎥💻📺📱📠☎💽📼🔊📢📣📻📡➿🔍🔓🔒🔑✂🔨💡📲📩📫📮🛀🚽💺💰🔱🚬💣🔫💊💉🏈🏀⚽⚾🎾⛳🎱🏊🏄🎿♠♥♣♦🏆👾🎯🀄🎬📝📖🎨🎤🎧🎺🎷🎸〽👟👡👠👢👕👔👗👘👙🎀🎩👑👒🌂💼👜💄💍💎☕🍵🍺🍻🍸🍶🍴🍔🍟🍝🍛🍱🍣🍙🍘🍚🍜🍲🍞🍳🍢🍡🍦🍧🎂🍰🍎🍊🍉🍓🍆🍅🏠🏫🏢🏣🏥🏦🏪🏩🏨💒⛪🏬🌇🌆🏧🏯🏰⛺🏭🗼🗻🌄🌅🌃🗽🌈🎡⛲🎢🚢🚤⛵✈🚀🚲🚙🚗🚕🚌🚓🚒🚑🚚🚃🚉🚄🚅🎫⛽🚥⚠🚧🔰🎰🚏💈♨🏁🎌🇯🇵🇰🇷🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧🇩🇪1⃣2⃣3⃣4⃣5⃣6⃣7⃣8⃣9⃣0⃣#⃣⬆⬇⬅➡↗↖↘↙◀▶⏪⏩🆗🆕🔝🆙🆒🎦🈁📶🈵🈳🉐🈹🈯🈺🈶🈚🈷🈸🈂🚻🚹🚺🚼🚭🅿♿🚇🚾㊙㊗🔞🆔✳✴💟🆚📳📴💹💱♈♉♊♋♌♍♎♏♐♑♒♓⛎🔯🅰🅱🆎🅾🔲🔴🔳🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚⭕❌©®™"];
//		
//		alphaNumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
//	}
}
-(void)setShouldLinkTypes:(kNMShouldLink)_shouldLinkTypes{
	shouldLinkTypes = _shouldLinkTypes;
	self.userInteractionEnabled = YES;
}
-(void)setDefaults{
	self.backgroundColor = [UIColor whiteColor];		
	[self setDefaultStyle:[NMCustomLabelStyle new]];
	
	highlightedTextIndex = NSNotFound;
}
-(UIColor *)backgroundColor{
	if(backgroundCGColor){
		return [UIColor colorWithCGColor:backgroundCGColor];
	}else{
		return nil;
	}
}
-(void)setBackgroundColor:(UIColor *)backgroundColor{
	if(backgroundCGColor){
		CGColorRelease(backgroundCGColor);
	}
	backgroundCGColor = CGColorRetain(backgroundColor.CGColor);
	if(CGColorGetAlpha(backgroundCGColor) < 0.1){
		[super setBackgroundColor:[UIColor clearColor]];
	}
	[self setNeedsDisplay];
}
-(UITextAlignment)textAlignment{
	switch (ctTextAlignment) {
		case kCTLeftTextAlignment:
			return UITextAlignmentLeft;
		case kCTRightTextAlignment:
			return UITextAlignmentRight;
		case kCTCenterTextAlignment:
			return UITextAlignmentCenter;
        default:
            return UITextAlignmentLeft;
	}
	return UITextAlignmentLeft;
}
-(void)setTextAlignment:(UITextAlignment)textAlignment{
	switch (textAlignment) {
		case UITextAlignmentLeft:
			ctTextAlignment = kCTLeftTextAlignment;
			break;
		case UITextAlignmentCenter:
			ctTextAlignment = kCTCenterTextAlignment;
			break;
		case UITextAlignmentRight:
			ctTextAlignment = kCTRightTextAlignment;
			break;
		default:
			ctTextAlignment = kCTLeftTextAlignment;
			break;
	}
}
-(id)initWithFrame:(CGRect)frame{
	if(self = [super initWithFrame:frame]){
		[self setDefaults];
	}
	return self;
}
- (id)init{
    if (self = [super init]) {
		[self setDefaults];
    }
    return self;
}
-(void)dealloc{
	if(attrString){ CFRelease(attrString); }
	if(framesetter){ CFRelease(framesetter); }
	if(backgroundCGColor){ CGColorRelease(backgroundCGColor); }
	if(ctFrame){ CFRelease(ctFrame); }
    if (self.styles) {
         CFRelease(self.styles);
    }
    [super dealloc]; 
}
-(CTFontRef)newCTFontWithUIFont:(UIFont *)font{
	return CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
}
-(UIFont *)uiFontWithCTFont:(CTFontRef)ctFont{
	if(ctFont){
		CFStringRef nameRef = CTFontCopyName(ctFont, kCTFontFullNameKey);
		NSString *name = (NSString *)nameRef;
		UIFont *font = [UIFont fontWithName:name size:CTFontGetSize(ctFont)];
		CFRelease(nameRef);
		return font;
	}else{
		return nil;
	}
}
-(void)clearAttrString{
	if(attrString){
		CFRelease(attrString);
		attrString = nil;
       // CFRelease(self.styles);
      //  NMCustomLabelStyle *style = [self.styles objectForKey:styleKey];
	}
}
-(void)setText:(NSString *)_text{
	if([self.text isEqualToString:_text]){
		return;
	}
	
	[super setText:_text];
	
	if(self.text && self.text.length > 0){
        if (cleanText) {
          [cleanText release];
          cleanText=nil;
        }
       
		cleanText =[ [tagRegEx stringByReplacingMatchesInString:self.text
													   options:0
														 range:NSMakeRange(0, [self.text length])
												  withTemplate:@""]retain];
		[self clearAttrString];
	}else{
		if(cleanText){
			cleanText = nil;
		}
		if(attrString){
			CFRelease(attrString);
			attrString = nil;
		}
		if(framesetter){
			CFRelease(framesetter);
			framesetter = nil;
		}
	}
	[self setNeedsDisplay];
	highlightedTextIndex = NSNotFound;
}
-(void)didUpdateColor{
	if(attrString){
		[self clearAttrString];
		[self setNeedsDisplay];
	}
}

-(NSMutableDictionary *)styles{
	if(!styles){
		styles =[[NSMutableDictionary dictionaryWithCapacity:5]retain];
	}
	return styles;
}
-(void)setStyle:(NMCustomLabelStyle *)style forKey:(NSString *)key{
	[self.styles setObject:style forKey:[key lowercaseString]];
}
-(void)setDefaultStyle:(NMCustomLabelStyle *)style{
	[self setStyle:style forKey:NMCustomLabelStyleDefaultKey];
}
-(NMCustomLabelStyle *)defaultStyle{
	if([self.styles objectForKey:NMCustomLabelStyleDefaultKey]){
		return [self.styles objectForKey:NMCustomLabelStyleDefaultKey];
	}else{
		return [NMCustomLabelStyle new];
	}
}
-(void)setLinkColor:(UIColor *)color{
	if([linkColor isEqual:color]){
		return;
	}
    if (linkColor) {
        [linkColor release];
    }
	linkColor = [color retain];
	[self didUpdateColor];
}
-(void)setActiveLinkColor:(UIColor *)color{
	if([activeLinkColor isEqual:color]){
		return;
	}
    if (activeLinkColor) {
        [activeLinkColor release];
    }
	activeLinkColor  = [color retain];
}
-(void)updateBackColorDeep:(id)sender
{
    UIButton *button=(UIButton *)sender;
    
    
    NSString *str=button.titleLabel.text;
    BOOL fromSelf=NO;
    NSLog(@"----------------down-----------updateBackColor--- %@",str);
    if ([str isEqualToString:@"self"]) {
        fromSelf=YES;
    }
    
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelfDown@2x":@"bubbleDown@2x" ofType:@"png"]];
	
	//	设定气泡拉伸的范围，自己和他人的信息气泡的拉伸范围有所不同，left和right的值是相反的
    //	UIEdgeInsets capInsets = UIEdgeInsetsMake(50,37,26,35);//48,20,22,30);
    //	if(!fromSelf)
    //		capInsets = UIEdgeInsetsMake(50,35,26,37);//UIEdgeInsetsMake(52,48,28,37);
    
	UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);//48,20,22,30);
    //	if(!fromSelf)
    //		capInsets = UIEdgeInsetsMake(50,35,26,37);//UIEdgeInsetsMake(52,48,28,37);
    
	UIImage *image=[self resizeImageWithCapInsets:capInsets andImage:bubble];
    UIImageView *imageview=(UIImageView *)[button viewWithTag:1];
    imageview.image=image;
    [self performSelector:@selector(updateBackColorLightDelay:) withObject:sender afterDelay:0.3];
    
}
-(void)updateBackColorLight:(id)sender
{
    
    [self performSelector:@selector(updateBackColorLightDelay:) withObject:sender afterDelay:0.2];
}
-(void)updateBackColorLightDelay:(id)sender
{
    UIButton *button=(UIButton *)sender;
    
    
    NSString *str=button.titleLabel.text;
    BOOL fromSelf=NO;
    NSLog(@"---------------up------------updateBackColor--- %@",str);
    if ([str isEqualToString:@"self"]) {
        fromSelf=YES;
    }
    
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf@2x":@"bubble@2x" ofType:@"png"]];
	
	//	设定气泡拉伸的范围，自己和他人的信息气泡的拉伸范围有所不同，left和right的值是相反的
    //	UIEdgeInsets capInsets = UIEdgeInsetsMake(50,37,26,35);//48,20,22,30);
    //	if(!fromSelf)
    //		capInsets = UIEdgeInsetsMake(50,35,26,37);//UIEdgeInsetsMake(52,48,28,37);
    
	UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);//48,20,22,30);
    //	if(!fromSelf)
    //		capInsets = UIEdgeInsetsMake(50,35,26,37);//UIEdgeInsetsMake(52,48,28,37);
    
	UIImage *image=[self resizeImageWithCapInsets:capInsets andImage:bubble];
    UIImageView *imageview=(UIImageView *)[button viewWithTag:1];
    imageview.image=image;
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

-(void)createAttributedString{
	if(!self.text || self.text.length == 0){ 
		//no text. return.
		return; 
	}
//	NSLog(@"customlabel - create - %@", text);
	
	[self clearAttrString];
	attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    // cleanText=@"123445656576 rdfgdfgdfg";
 //   NSLog(@"----cleanText -- %@ ",cleanText);
   
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)cleanText);
	
	NMCustomLabelStyle *defaultStyle = [self defaultStyle];

	//set default color
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, defaultStyle.colorRef);
	
//    CTFontRef sysUIFont = CTFontCreateUIFontForLanguage(kCTFontLabelFontType, 16.0, NULL);
//    
//	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName,sysUIFont);
	//set default font
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, defaultStyle.fontRef);
	
	__block int locOfTag = -1;
	__block int totalTagLength = 0;
//	static int eachTagLength = 7;
/*	
	[markupTagRegEx enumerateMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
		
		NSRange markupRange = [match range];
		markupRange.length -= eachTagLength;
		markupRange.location -= totalTagLength;
		locOfTag = markupRange.location + markupRange.length;
		totalTagLength += eachTagLength;
		
		CTFontRef font=nil;
		UIColor *color=nil;
		if(match.numberOfRanges > 1){
			NSRange tagTypeRange = [match rangeAtIndex:1];
			NSString *tagType = [[self.text substringWithRange:tagTypeRange] lowercaseString];
			if([tagType isEqualToString:@"b"]){
				font = bodyFontBold;
				color = textColorBold;
			}else if([tagType isEqualToString:@"i"]){
				font = bodyFontItalic;
				color = self.textColor;
			}
		}
		if(font && color){
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font, kCTFontAttributeName, [color CGColor], kCTForegroundColorAttributeName, nil];
			CFAttributedStringSetAttributes(attrString, CFRangeMake(markupRange.location, markupRange.length), (__bridge CFDictionaryRef)attributes, NO);
		}
	}];
 */
	[spanTagRegEx enumerateMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
		int thisTagLength = 14;
	
		CTFontRef font=nil;
		CGColorRef color=nil;
		UIImage *image=nil;
		CGFloat imageVerticalOffset=0;
		if(match.numberOfRanges > 1){
			NSRange tagTypeRange = [match rangeAtIndex:1];
			thisTagLength += tagTypeRange.length;
			NSString *tagInfo = [[self.text substringWithRange:tagTypeRange] lowercaseString];
			tagInfo = [tagInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			NSArray *metadata = [tagInfo componentsSeparatedByString:@"="];
			if(metadata.count == 2 && [[metadata objectAtIndex:0] isEqualToString:@"class"]){
				NSString *styleKey = [metadata objectAtIndex:1];
				styleKey = [styleKey stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
				NMCustomLabelStyle *style = [self.styles objectForKey:styleKey];
				if(style){
					font = style.fontRef;
					color = style.colorRef;
					image = style.image;
					imageVerticalOffset = style.imageVerticalOffset;
				}
			}
		}
		
		NSRange markupRange = [match range];
		markupRange.length -= thisTagLength;
		markupRange.location -= totalTagLength;
		locOfTag = markupRange.location + markupRange.length;
		totalTagLength += thisTagLength;
		
		if(font && color){
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)font, kCTFontAttributeName, color, kCTForegroundColorAttributeName, nil];
			CFAttributedStringSetAttributes(attrString, CFRangeMake(markupRange.location, markupRange.length), (CFDictionaryRef)attributes, NO);
		}
		if(image){
             NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			NSDictionary *imageAttr = [NSDictionary dictionaryWithObjectsAndKeys:image, kNMImageAttributeName, [NSNumber numberWithFloat:imageVerticalOffset], kNMImageVerticalOffsetAttributeName, nil];
			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:imageAttr, kNMImageInfoAttributeName, nil];
			CFAttributedStringSetAttributes(attrString, CFRangeMake(markupRange.location, markupRange.length), (CFDictionaryRef)attributes, NO);
           // [image release];
            [pool release];
                
		}

	}];

	if(self.shouldBoldAtNames && (self.shouldLinkTypes & kNMShouldLinkUsernames) ){
		[usernameRegEx enumerateMatchesInString:self.text options:0 range:NSMakeRange(0, [self.text length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
			
			if(match.numberOfRanges > 1){
				NSRange range = [match rangeAtIndex:1];
				if(range.length > 1){ //aka not just an '@' symbol
//					if(locOfTag >= 0 && locOfTag < boldRange.location){
//						boldRange.location -= totalTagLength;
//					}
					
					NSDictionary *attributes;
					if(linkColor){
						UIColor *tehLinkColor = linkColor;
						if(highlightedTextIndex != NSNotFound){
							if(highlightedTextIndex >= range.location && highlightedTextIndex < range.location+range.length){
								highlightedTextType = kNMTextTypeUsername;
								tehLinkColor = activeLinkColor;
								highlightedText = [[cleanText substringWithRange:NSMakeRange(range.location, range.length)]copy];
							}
						}
						attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[tehLinkColor CGColor], kCTForegroundColorAttributeName, nil];
					}else{
						NMCustomLabelStyle *boldStyle = [self.styles objectForKey:NMCustomLabelStyleBoldKey];
						attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)boldStyle.fontRef, kCTFontAttributeName, (id)[boldStyle colorRef], kCTForegroundColorAttributeName, nil];
					}
					CFAttributedStringSetAttributes(attrString, CFRangeMake(range.location, range.length), ( CFDictionaryRef)attributes, NO);
				}
			}
		}];
	}
	
	if(self.shouldLinkTypes & kNMShouldLinkURLs){
		NSError *error = NULL;
		NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
		[detector enumerateMatchesInString:self.cleanText options:0 range:NSMakeRange(0, [self.cleanText length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
			
			NSRange matchRange = [match range];
			NSDictionary *attributes;
			if(linkColor){
				UIColor *tehLinkColor = linkColor;
				if(highlightedTextIndex != NSNotFound){
					if(highlightedTextIndex >= matchRange.location && highlightedTextIndex < matchRange.location+matchRange.length){
						highlightedTextType = kNMTextTypeLink;
						tehLinkColor = activeLinkColor;
						highlightedText = [[cleanText substringWithRange:NSMakeRange(matchRange.location, matchRange.length)]copy];
					}
				}
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)[tehLinkColor CGColor], kCTForegroundColorAttributeName, nil];
			}else{
				NMCustomLabelStyle *boldStyle = [self.styles objectForKey:NMCustomLabelStyleBoldKey];
				attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)boldStyle.fontRef, kCTFontAttributeName, ( id)[boldStyle colorRef], kCTForegroundColorAttributeName, nil];
			}
			CFAttributedStringSetAttributes(attrString, CFRangeMake(matchRange.location, matchRange.length), ( CFDictionaryRef)attributes, NO);
		}];
	}
		
//	NSRange range = [self.cleanText rangeOfCharacterFromSet:emojiCharacterSet options:NSLiteralSearch range:NSMakeRange(0, self.cleanText.length)];
//	while(range.location != NSNotFound){
//		NSString *substring = [self.cleanText substringWithRange:range];
//		if([substring rangeOfCharacterFromSet:alphaNumericCharacterSet options:NSLiteralSearch range:NSMakeRange(0, substring.length)].location == NSNotFound){
////			NSLog(@"EMOJIII: %@", substring);
//			
//			CFDictionaryRef currentAttributes = CFAttributedStringGetAttributes(attrString, range.location, NULL);
//			CTFontRef currentFont = CFDictionaryGetValue(currentAttributes, @"NSFont");
//			CFStringRef currentFontName = CTFontCopyFullName(currentFont);
//			CTFontRef smallerFont = CTFontCreateWithName(currentFontName, CTFontGetSize(currentFont) * 0.8, NULL);
//			
//			NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)smallerFont, kCTFontAttributeName, nil];
//			CFRange emojiRange = CFRangeMake(range.location, range.length); 
//			CFAttributedStringSetAttributes(attrString, emojiRange, (__bridge CFDictionaryRef)attributes, NO);
//			
//			CFRelease(currentFontName);
//			CFRelease(smallerFont);
//		}
//		
//		CGFloat location = range.location + range.length;
//		range = [self.cleanText rangeOfCharacterFromSet:emojiCharacterSet options:NSLiteralSearch range:NSMakeRange(location, self.cleanText.length-location)];
//	}
	
	//create paragraph style and assign text alignment to it
	int numParagraphSpecifiers = 3;
	CTParagraphStyleSetting _settings[] = { 
		{kCTParagraphStyleSpecifierAlignment, sizeof(ctTextAlignment), &ctTextAlignment},
		{kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &lineHeight},
		{kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &lineHeight},
//		{kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
		{kCTParagraphStyleSpecifierCount, sizeof(int), &numParagraphSpecifiers}
	};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(_settings, sizeof(_settings) / sizeof(_settings[0]));
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
	
	CFNumberRef kernValue = (CFNumberRef) [NSNumber numberWithFloat:kern];
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTKernAttributeName, kernValue);
	
	if(framesetter){
		CFRelease(framesetter);
	}
	framesetter = CTFramesetterCreateWithAttributedString(attrString);
	
	CFRelease(paragraphStyle);
}


- (CGSize)sizeThatFits:(CGSize)size{
	if(!self.text || self.text.length == 0){
		return CGSizeZero;
	}
	CGSize suggestedSize = CGSizeZero;
	if(!attrString){
		[self createAttributedString];
	}
	if(framesetter){
		if(size.width < 1){ size.width = 10000; }
		if(size.height < 1){ size.height = 10000; }
		suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
																	 framesetter, /* Framesetter */
																	 CFRangeMake(0, CFAttributedStringGetLength(attrString)), /* String range (entire string) */
																	 NULL, /* Frame attributes */
																	 size, /* Constraints (CGFLOAT_MAX indicates unconstrained) */
																	 NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
																	 );
		//on iOS 4, we were getting heights of 14.9 where the line height was 15, so it was getting cut off.  after we stop supporting iOS 4, we could safely kill these lines.
		suggestedSize.width = round(suggestedSize.width);
		suggestedSize.height = round(suggestedSize.height);

//		NSLog(@"NMCustomLabel-sizeThatFits: %@ %@ --> %@", cleanText, NSStringFromCGSize(size), NSStringFromCGSize(suggestedSize));
	}else{
		suggestedSize = size;
	}
//	if(NO){
//		if(self.numberOfLines > 0 && self.lineHeight > 0){
//			if(suggestedSize.height / self.lineHeight > self.numberOfLines){
//				CGFloat oldheight = suggestedSize.height;
//				suggestedSize.height = self.numberOfLines * self.lineHeight;
//				NSLog(@"suggested height reduced from %f to %f", oldheight, suggestedSize.height);
//				shouldTruncate = YES;
//			}
//		}
//	}	
	return suggestedSize;
}
-(void)setFrame:(CGRect)frame{
	if(!CGRectEqualToRect(self.frame, frame)){
		[super setFrame:frame];
		[self setNeedsDisplay];
	}
}
- (void)drawTextInRect:(CGRect)rect{
//	NSLog(@"drawRect: %@ - %@", NSStringFromCGRect(rect), text);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	if(backgroundCGColor){
		CGContextSetFillColorWithColor(context, backgroundCGColor);
		CGContextFillRect(context, rect);
	}

	if(!self.text || self.text.length == 0){
		return;
	}
	CGSize fullSize = [self sizeThatFits:CGSizeMake(rect.size.width, 2000.0)];
	
//	NSLog(@"taco - %f > %d", fullSize.height /  self.lineHeight, self.numberOfLines);
	if(self.numberOfLines && self.lineHeight && fullSize.height / self.lineHeight > self.numberOfLines){
		shouldTruncate = YES;
	}	

	if(!attrString){
		[self createAttributedString];
	}
//	if(YES && numberOfLines > 0 && shouldTruncate){
	if(YES){
		// don't set any line break modes, etc, just let the frame draw as many full lines as will fit 
		CGRect frameRect = rect;
		CGMutablePathRef framePath = CGPathCreateMutable(); 
//		CGPathAddRect(framePath, NULL, frameRect); 
		
		CGContextSetTextMatrix(context, CGAffineTransformIdentity);
		CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGAffineTransform reverseT = CGAffineTransformIdentity;
		reverseT = CGAffineTransformScale(reverseT, 1.0, -1.0);
		reverseT = CGAffineTransformTranslate(reverseT, 0.0, -self.bounds.size.height);
		
		CGPathAddRect(framePath, NULL, CGRectApplyAffineTransform(frameRect, reverseT));

		if(ctFrame){
			CFRelease(ctFrame);
		}
		ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrString)), framePath, NULL); 
		CFArrayRef lines = CTFrameGetLines(ctFrame); 
		CFIndex count = CFArrayGetCount(lines);
		if(count == 0){
			CGPathRelease(framePath);
			CFRelease(ctFrame);
			return;
		}
		CGPoint origins[count];//the origins of each line at the baseline
		CFRange range = CFRangeMake(0, count);
		CTFrameGetLineOrigins(ctFrame, range, origins); 
		// note that we only enumerate to count-1 in here-- we draw the last line separately 
		for (CFIndex i = 0; i < count-1; i++) 
		{ 
			// draw each line in the correct position as-is 
			CGContextSetTextPosition(context, origins[i].x, origins[i].y); 
			CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, i); 
			CTLineDraw(line, context); 
		} 
		
		// truncate the last line before drawing it 
		CGPoint lastOrigin = origins[count-1]; 
		CTLineRef lastLine = CFArrayGetValueAtIndex(lines, count-1); 
		// truncation token is a CTLineRef itself 
		CFDictionaryRef stringAttrs = nil;
		CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("\u2026"), stringAttrs); 
		CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString); 
		CFRelease(truncationString); 
		// now create the truncated line -- need to grab extra characters from the source string, 
		// or else the system will see the line as already fitting within the given width and 
		// will not truncate it. 
		// range to cover everything from the start of lastLine to the end of the string 
		CFRange rng = CFRangeMake(CTLineGetStringRange(lastLine).location, 0); 
		rng.length = CFAttributedStringGetLength(attrString) - rng.location; 
		// substring with that range 
		CFAttributedStringRef longString = CFAttributedStringCreateWithSubstring(NULL, attrString, rng); 
		// line for that string 
		CTLineRef longLine = CTLineCreateWithAttributedString(longString); 
		CFRelease(longString); 
		CTLineRef truncated = CTLineCreateTruncatedLine(longLine, frameRect.size.width, kCTLineTruncationEnd, truncationToken); 
		CFRelease(longLine); 
		CFRelease(truncationToken); 
		// if 'truncated' is NULL, then no truncation was required to fit it 
		if (truncated == NULL) 
			truncated = (CTLineRef)CFRetain(lastLine); 
		// draw it at the same offset as the non-truncated version
     
     
		CGContextSetTextPosition(context, lastOrigin.x, lastOrigin.y); 
		CTLineDraw(truncated, context); 
		CFRelease(truncated);
		
		[self drawImagesForFrame:ctFrame fromAttributedString:(__bridge NSAttributedString *)attrString];
//        NSLog(@"--self.frame.size.height- %0.0f  --lastOrigin.y- %0.0f",self.frame.size.height,lastOrigin.y);
//        self.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+lastOrigin.y);
		CGPathRelease(framePath);

	}else{
		
		CGRect topRect = self.frame;
		topRect.origin = CGPointZero;
		
		CGContextSetTextMatrix(context, CGAffineTransformIdentity);
		CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGAffineTransform reverseT = CGAffineTransformIdentity;
		reverseT = CGAffineTransformScale(reverseT, 1.0, -1.0);
		reverseT = CGAffineTransformTranslate(reverseT, 0.0, -self.bounds.size.height);
		
		
		CGMutablePathRef topFramePath = CGPathCreateMutable();
		CGPathAddRect(topFramePath, NULL, CGRectApplyAffineTransform(topRect, reverseT));
		
		CTFrameRef topFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,0), topFramePath, NULL);  
		CFRelease(topFramePath);
		CTFrameDraw(topFrame, context);
		CFRelease(topFrame);
		
		CGAffineTransform ctm = CGContextGetCTM(context);
		CGContextConcatCTM(context, CGAffineTransformInvert(ctm));

	}
	if(!pressRecog){
		pressRecog = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didPress:)];
		pressRecog.minimumPressDuration = 0.02;
		pressRecog.delaysTouchesBegan = YES;
		pressRecog.delaysTouchesEnded = YES;
		pressRecog.cancelsTouchesInView = YES;
		pressRecog.delegate = self;
//		pressRecog.allowableMovement = 0; //pixels.. default=10
		[self addGestureRecognizer:pressRecog];
        NSLog(@"-----addGestureRecognizer w %0.0f h %0.0f",self.frame.origin.x,self.frame.origin.y);
//		if([self.delegate respondsToSelector:@selector(customLabel:didAddGestureRecog:)]){
//			[self.delegate customLabel:self didAddGestureRecog:pressRecog];
//		}
	}
}

//borrowed from https://github.com/adamjernst/AEImageAttributedString/blob/master/AEImageAttributedString/AEImageAttributedString.m
-(void)drawImagesForFrame:(CTFrameRef)frame fromAttributedString:(NSAttributedString *)string {
    CGRect rect = CGPathGetBoundingBox(CTFrameGetPath(frame));
	CFArrayRef lines = CTFrameGetLines(frame);
	
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    [string enumerateAttribute:kNMImageInfoAttributeName inRange:NSMakeRange(0, [string length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
		NSDictionary *attributes = (NSDictionary *)value;
		UIImage *image = [attributes objectForKey:kNMImageAttributeName];
		CGFloat verticalOffset = [[attributes objectForKey:kNMImageVerticalOffsetAttributeName] floatValue];
		
		if(!image){
			return;
		}
		
		CGRect imageRect = {
			.origin = rect.origin,
			.size = image.size
		};
		
		for (CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			CFRange r = CTLineGetStringRange(line);
			int localIndex = range.location - r.location;
			if (localIndex >= 0 && localIndex < r.length) {
				imageRect.origin.x += CTLineGetOffsetForStringIndex(line, range.location, NULL);
				CGPoint lineOrigin;
				CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), &lineOrigin);
				imageRect.origin.x += lineOrigin.x;
				imageRect.origin.y += lineOrigin.y - 2.0f;
				break;
			}
		}
		imageRect.origin.y += verticalOffset;
		
		CGContextDrawImage(c, imageRect, image.CGImage);
	}];
}





-(CGFloat)stringIndexAtLocation:(CGPoint)location{
	CFArrayRef lines = CTFrameGetLines(ctFrame); 
	CFIndex numLines = CFArrayGetCount(lines);
	CGPoint origins[numLines];//the origins of each line at the baseline
	CFRange range = CFRangeMake(0, numLines);
	CTFrameGetLineOrigins(ctFrame, range, origins); 
	for (CFIndex i = 0; i < numLines; i++){
		CGPoint origin = origins[i];
		if(location.y >= origin.y && location.y < origin.y + lineHeight){
			CFIndex lineIndex = numLines-i-1;
			CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, lineIndex); 
			CFIndex stringIndex = CTLineGetStringIndexForPosition(line, CGPointMake(location.x, 0));
//			NSLog(@"stringIndex = %ld", stringIndex);
			return stringIndex;
		}
	}
	return -1;
}
-(void)performActionOnHighlightedText{
	if([self.delegate respondsToSelector:@selector(customLabel:didSelectText:type:)]){
		[self.delegate customLabel:self didSelectText:highlightedText type:highlightedTextType];
	}
}
-(BOOL)hasHighlightedText{
	return highlightedTextIndex != NSNotFound;
}
-(void)resetHighlightedText{
	highlightedTextIndex = NSNotFound;
	highlightedText = nil;
	highlightedTextType = kNMTextTypeNone;
	[self createAttributedString];
	[self setNeedsDisplay];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recog shouldReceiveTouch:(UITouch *)touch{
	NSLog(@"-----shouldReceiveTouch");
    UIButton*button=(UIButton*)((picTextViewController*)self.delegate).view.superview;
    [self updateBackColorDeep:button];
	CGPoint location = [touch locationInView:self];
	highlightedTextIndex = [self stringIndexAtLocation:location];
	[self createAttributedString];
	return highlightedText != nil;
}

-(void)didPress:(UILongPressGestureRecognizer *)recog{
	CGPoint location = [recog locationInView:self];
	NSLog(@"didPress: touch= %@ , bounds = %@ - state = %d", NSStringFromCGPoint(location), NSStringFromCGRect(self.bounds), recog.state);
	
	if(!CGRectContainsPoint(self.bounds, location)){
		recogOutOfBounds = YES;
        NSLog(@"--222-CGRectContainsPoint");
	}
    
	switch (recog.state) {
		case UIGestureRecognizerStateBegan:
            
			recogOutOfBounds = NO; //reset.
			if(highlightedTextIndex == NSNotFound){
				highlightedTextIndex = [self stringIndexAtLocation:location];
				[self createAttributedString];
			}
			if(highlightedText){
				if([self.delegate respondsToSelector:@selector(customLabelDidBeginTouch:recog:)]){
					[self.delegate customLabelDidBeginTouch:self recog:recog];
				}
			}else{
				if([self.delegate respondsToSelector:@selector(customLabelDidBeginTouchOutsideOfHighlightedText:recog:)]){
					[self.delegate customLabelDidBeginTouchOutsideOfHighlightedText:self recog:recog];
				}
			}
			[self setNeedsDisplay];
			break;
		
		case UIGestureRecognizerStateChanged:
			if([self.delegate respondsToSelector:@selector(customLabel:didChange:)]){
				[self.delegate customLabel:self didChange:recog];
			}
			if(recogOutOfBounds){
//				recog.enabled = NO;
//				recog.enabled = YES;
				[self resetHighlightedText];
				if([self.delegate respondsToSelector:@selector(customLabelDidEndTouchOutsideOfHighlightedText:recog:)]){
					[self.delegate customLabelDidEndTouchOutsideOfHighlightedText:self recog:recog];
				}
			}
			break;
		
		case UIGestureRecognizerStateEnded:
			if(highlightedText && !recogOutOfBounds){
				[self performActionOnHighlightedText];
			}
			//no break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed:
			if(highlightedText && !recogOutOfBounds){
				if([self.delegate respondsToSelector:@selector(customLabelDidEndTouch:recog:)]){
					[self.delegate customLabelDidEndTouch:self recog:recog];
				}
			}else{
				if([self.delegate respondsToSelector:@selector(customLabelDidEndTouchOutsideOfHighlightedText:recog:)]){
					[self.delegate customLabelDidEndTouchOutsideOfHighlightedText:self recog:recog];
				}
			}
			[self resetHighlightedText];

			break;
			
		default:
			break;
	}
}


@end
