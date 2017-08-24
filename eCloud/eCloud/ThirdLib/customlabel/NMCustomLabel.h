//
//  NMCustomLabel.h
//  NewsMe
//
//  Created by Robert Haining on 8/30/11.
//
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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "NMCustomLabelStyle.h"

typedef enum{
	kNMTextTypeNone=0,
	kNMTextTypeUsername=1,
	kNMTextTypeLink=2
}kNMTextType;

typedef enum{
	kNMShouldLinkNothing	= 0,
	kNMShouldLinkUsernames	= 1 << 0,
	kNMShouldLinkURLs		= 2 << 0
}kNMShouldLink;

@class NMCustomLabel;

@protocol NMCustomLabelDelegate <NSObject>
@optional
//-(void)customLabel:(NMCustomLabel *)customLabel didAddGestureRecog:(UILongPressGestureRecognizer *)recog;
-(void)customLabelDidBeginTouch:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog;
-(void)customLabelDidBeginTouchOutsideOfHighlightedText:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog;
-(void)customLabel:(NMCustomLabel *)customLabel didChange:(UILongPressGestureRecognizer *)recog;
-(void)customLabelDidEndTouch:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog;
-(void)customLabelDidEndTouchOutsideOfHighlightedText:(NMCustomLabel *)customLabel recog:(UILongPressGestureRecognizer *)recog;
-(void)customLabel:(NMCustomLabel *)customLabel didSelectText:(NSString *)text type:(kNMTextType)textType;
@end


@interface NMCustomLabel : UILabel <UIGestureRecognizerDelegate> {
	CTFramesetterRef framesetter;
	CTFrameRef ctFrame;
	CFMutableAttributedStringRef attrString;
	
	BOOL shouldTruncate;
	
	CGColorRef backgroundCGColor;
	
	UILongPressGestureRecognizer *pressRecog;
	BOOL recogOutOfBounds;
	CGFloat highlightedTextIndex;
	NSString *highlightedText;
	kNMTextType highlightedTextType;
	
	NSMutableDictionary *styles;
    id<NMCustomLabelDelegate> delegate;
}

@property (nonatomic, readonly) NSString *cleanText;
@property (nonatomic) CTTextAlignment ctTextAlignment;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *activeLinkColor;
@property (nonatomic) CGFloat lineHeight;
@property (nonatomic) int numberOfLines;
@property (nonatomic) BOOL shouldBoldAtNames;
@property (nonatomic) kNMShouldLink shouldLinkTypes;
@property (nonatomic) CGFloat kern;
@property (assign) id<NMCustomLabelDelegate> delegate;

-(BOOL)hasHighlightedText;
+(NSRegularExpression *)usernameRegEx;
+(NSRegularExpression *)hashtagRegEx;

-(void)setDefaultStyle:(NMCustomLabelStyle *)style;
-(void)setStyle:(NMCustomLabelStyle *)style forKey:(NSString *)key;


@end
