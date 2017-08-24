//
//  NMCustomLabelStyle.h
//  Banana Stand
//
//  Created by Robert Haining on 6/18/12.
//  Copyright (c) 2012 News.me. All rights reserved.
//
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

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

extern NSString * const NMCustomLabelStyleDefaultKey;
extern NSString * const NMCustomLabelStyleBoldKey;

@interface NMCustomLabelStyle : NSObject

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat imageVerticalOffset;

@property (nonatomic, readonly) CTFontRef fontRef;
@property (nonatomic, readonly) CGColorRef colorRef;

+(id)styleWithFont:(UIFont *)font color:(UIColor *)color;
+(id)styleWithImage:(UIImage *)image verticalOffset:(CGFloat)verticalOffset;
+(id)styleWithImage:(UIImage *)image;

@end
