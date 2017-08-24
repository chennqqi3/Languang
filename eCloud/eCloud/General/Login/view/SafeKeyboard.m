//
//  safeKeyboard.m
//  safeKeyboard
//
//  Created by Alex L on 15/11/13.
//  Copyright © 2015年 Alex L. All rights reserved.
//

#import "SafeKeyboard.h"
#import "RoundCornersButton.h"
#import "RoundCornersView.h"
#import "RoundCornersLabel.h"
#import "StringUtil.h"

#define PASSWD_MAXLEN 16
#define IMAGEVIEW_TAG 721

#define BLUE_COLOR [UIColor colorWithRed:66/255.0 green:165/255.0 blue:245/255.0 alpha:1]

#define NUMBERS @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"]

@interface SafeKeyboard()
{
    BOOL _isCapital;
    NSInteger _alphabetIndex;
}

@property (nonatomic, strong) UIImageView *alphabetImage;

@property (nonatomic, strong) UIView *keyboard;
@property (nonatomic, strong) UIView *numberKeyboard;
@property (nonatomic, strong) UIView *punctuationKeyboard;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *upBtn;
@property (nonatomic, strong) UIButton *downBtn;
@property (nonatomic, strong) UIButton *capitalBtn;

@property (nonatomic, strong) NSMutableString *mText;
@property (nonatomic, strong) NSArray *myLowerCharacters;
@property (nonatomic, strong) NSArray *myUpperCharacters;
@property (nonatomic, strong) NSArray *myNumbers;
@property (nonatomic, strong) NSArray *myPunctuation;

@end


@implementation SafeKeyboard

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"clearPasswordTextNotification" object:nil];
}

- (NSArray *)myUpperCharacters
{
    if (_myUpperCharacters == nil)
    {
        _myUpperCharacters = @[@"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",@"A",@"S",@"D",@"F",@"G",@"H",@"J",@"K",@"L",@"Z",@"X",@"C",@"V",@"B",@"N",@"M"];
    }
    return _myUpperCharacters;
}

- (NSArray *)myLowerCharacters
{
    if (_myLowerCharacters == nil)
    {
        _myLowerCharacters = @[@"q",@"w",@"e",@"r",@"t",@"y",@"u",@"i",@"o",@"p",@"a",@"s",@"d",@"f",@"g",@"h",@"j",@"k",@"l",@"z",@"x",@"c",@"v",@"b",@"n",@"m"];
    }
    return _myLowerCharacters;
}

- (NSArray *)myPunctuation
{
    if (_myPunctuation == nil)
    {
        NSMutableString *string = [NSMutableString stringWithString:@"\\\\"];
        [string deleteCharactersInRange:NSMakeRange(0, 1)];
        NSMutableString *string1 = [NSMutableString stringWithString:@"\\\""];
        [string1 deleteCharactersInRange:NSMakeRange(0, 1)];
        
        _myPunctuation = @[@"<",@">",@"{",@"}",@"(",@")",@"[",@"]",@"$",@"=",string,@"|",@"&",@"%",@"^",@"`",@",",@".",@"?",@"!",@":",@";",@"@",@"~",@"_",@"-",string1,@"'",@"/",@"#",@"*",@"+"];
    }
    return _myPunctuation;
}

- (NSArray *)myNumbers
{
    if (_myNumbers == nil)
    {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:NUMBERS];
        for (int i = 0; i < 10; i++)
        {
            [mArr exchangeObjectAtIndex:arc4random_uniform((int)mArr.count) withObjectAtIndex:arc4random_uniform((int)mArr.count)];
        }
        _myNumbers = mArr;
    }
    return _myNumbers;
}

- (NSMutableString *)mText
{
    if (_mText == nil)
    {
        _mText = [[NSMutableString alloc] init];
    }
    return _mText;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearPasswordText)name:@"clearPasswordTextNotification" object:nil];
        
        [self addKeyboard];
        [self addNumberKeyboard];
        [self addPunctuation];
    }
    return self;
}

- (void)clearPasswordText
{
    _mText = nil;
}

#pragma mark - SafeKeyboardDelegate
- (void)setTextfield
{
    if (self.mText.length > PASSWD_MAXLEN)
    {
        [self.mText deleteCharactersInRange:NSMakeRange(self.mText.length - 1, 1)];
        return;
    }
    if(_safeKeyBoardDelegate && [_safeKeyBoardDelegate respondsToSelector:@selector(setPasswordTextField:)])
    {
        [_safeKeyBoardDelegate setPasswordTextField:_mText];
    }
}

#pragma mark - 添加标点符号键盘
- (void)addPunctuation
{
    self.punctuationKeyboard = [[UIView alloc] initWithFrame:self.frame];
    self.punctuationKeyboard.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    
    CGFloat buttonWidth = (self.frame.size.width/5.0) - 7;
    RoundCornersView *backGroundView = [[RoundCornersView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 50)];
    backGroundView.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - buttonWidth, 225)];
    self.scrollView.scrollEnabled = NO;
    self.scrollView.contentSize = CGSizeMake(0, 2*225);
    for (int i = 0; i < 32; i++)
    {
        RoundCornersButton *button = [RoundCornersButton buttonWithType:UIButtonTypeCustom];
        int index = i;
        button.frame = CGRectMake((index%4)*buttonWidth + (index%4)*5 + 5, (index/4)*(200/4.0) + (index/4)*5 + 5, buttonWidth, 50);
        [button setBackgroundImage:[self convertViewToImage:backGroundView] forState:UIControlStateHighlighted];
        
        [button setTitle:self.myPunctuation[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag = 700 + i;
        [button addTarget:self action:@selector(clickPunctuationKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
    }
    
    CGPoint point = self.scrollView.contentOffset;
    point.y = 220;
    self.scrollView.contentOffset = point;
    [self.punctuationKeyboard addSubview:self.scrollView];
    
    self.upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.upBtn.frame = CGRectMake((4*buttonWidth) + (3*5) + 5 + 5, 5, buttonWidth, 50);
    self.upBtn.backgroundColor = [UIColor lightGrayColor];
    [self.upBtn addTarget:self action:@selector(upClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *upImage = [StringUtil getImageByResName:@"up1.png"];
    UIImageView *upImageView = [[UIImageView alloc] initWithImage:upImage];
    upImageView.frame = CGRectMake((buttonWidth-(30*(4/3.0)))/2.0, 10, 30*(4/3.0), 30);
    [self.upBtn addSubview:upImageView];
    [self.punctuationKeyboard addSubview:self.upBtn];
    
    self.downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downBtn.frame = CGRectMake((4*buttonWidth) + (3*5) + 5 + 5, (200/4.0) + 5 + 5, buttonWidth, 50);
    self.downBtn.backgroundColor = [UIColor grayColor];
    [self.downBtn addTarget:self action:@selector(downClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *downImage = [StringUtil getImageByResName:@"down1.png"];
    UIImageView *downImageView = [[UIImageView alloc] initWithImage:downImage];
    downImageView.frame = CGRectMake((buttonWidth-(30*(4/3.0)))/2.0, 10, 30*(4/3.0), 30);
    [self.downBtn addSubview:downImageView];
    [self.downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.punctuationKeyboard addSubview:self.downBtn];
    
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 50)];
    highlightView.backgroundColor = [UIColor colorWithWhite:0.77 alpha:1];
    UIImage *highlightImage = [self convertViewToImage:highlightView];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake((4*buttonWidth) + (3*5) + 5 + 5, 2*(200/4.0) + 2*5 + 5, buttonWidth, 50);
    deleteBtn.backgroundColor = [UIColor lightGrayColor];
    [deleteBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self addDeleteImageWithDeleteBtn:deleteBtn];
//    UIImage *deleteImage = [StringUtil getImageByResName:@"delete123.png"];
//    UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
//    deleteImageView.frame = CGRectMake((deleteBtn.frame.size.width - deleteImage.size.width) * 0.5, (deleteBtn.frame.size.height - deleteImage.size.height) * 0.5, deleteImage.size.width, deleteImage.size.height);
//
////    deleteImageView.frame = CGRectMake((buttonWidth-(40*(4/3.0)))/2.0, 5, 40*(4/3.0), 40);
//    [deleteBtn addSubview:deleteImageView];
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.punctuationKeyboard addSubview:deleteBtn];
    
    UIButton *comeBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comeBackBtn.frame = CGRectMake((4*buttonWidth) + (3*5) + 5 + 5, 3*(200/4.0) + 3*5 + 5, buttonWidth, 50);
    comeBackBtn.backgroundColor = [UIColor lightGrayColor];
    [comeBackBtn addTarget:self action:@selector(comeBackClick:) forControlEvents:UIControlEventTouchUpInside];
    [comeBackBtn setTitle:@"back" forState:UIControlStateNormal];
    [self.punctuationKeyboard addSubview:comeBackBtn];
    
    
    [self addSubview:self.punctuationKeyboard];
}

- (void)upClick:(UIButton *)sender
{
    if (self.scrollView.contentOffset.y != 0)
    {
        [UIView animateWithDuration:0.3f animations:^{
            CGPoint point = self.scrollView.contentOffset;
            point.y = 0;
            self.scrollView.contentOffset = point;
        }];
    }
    
    [self.upBtn setBackgroundColor:[UIColor grayColor]];
    [self.downBtn setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)downClick:(UIButton *)sender
{
    if (self.scrollView.contentOffset.y != 220)
    {
        [UIView animateWithDuration:0.3f animations:^{
            CGPoint point = self.scrollView.contentOffset;
            point.y = 220;
            self.scrollView.contentOffset = point;
        }];
    }
    
    [self.upBtn setBackgroundColor:[UIColor lightGrayColor]];
    [self.downBtn setBackgroundColor:[UIColor grayColor]];
}

- (void)comeBackClick:(UIButton *)sender
{
    CGRect keyboardRect = self.keyboard.frame;
    keyboardRect.origin.y = 0;
    self.keyboard.frame = keyboardRect;
    
    CGRect punctuationKeyboardRect = self.punctuationKeyboard.frame;
    punctuationKeyboardRect.origin.y = 225;
    self.punctuationKeyboard.frame = punctuationKeyboardRect;
}

#pragma mark - 添加数字键盘
- (void)addNumberKeyboard
{
    self.numberKeyboard = [[UIView alloc] initWithFrame:self.frame];
    self.numberKeyboard.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    
    CGFloat buttonWidth = (self.frame.size.width/3.0) - 7;
    RoundCornersView *backGroundView = [[RoundCornersView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 50)];
    backGroundView.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < 10; i++)
    {
        RoundCornersButton *button = [RoundCornersButton buttonWithType:UIButtonTypeCustom];
        int index = i;
        if (i == 9)
        {
            index = i + 1;
        }
        button.frame = CGRectMake((index%3)*buttonWidth + (index%3)*5 + 5, (index/3)*(200/4.0) + (index/3)*5 + 5, buttonWidth, 50);
        [button setBackgroundImage:[self convertViewToImage:backGroundView] forState:UIControlStateHighlighted];
//        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitle:self.myNumbers[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag = 600 + i;
        [button addTarget:self action:@selector(clickNumberKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [self.numberKeyboard addSubview:button];
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 3*(200/4.0) + 5 + 3*5, buttonWidth, 50);
    backBtn.backgroundColor = [UIColor lightGrayColor];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"back" forState:UIControlStateNormal];
    [self.numberKeyboard addSubview:backBtn];
    
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 50)];
    highlightView.backgroundColor = [UIColor colorWithWhite:0.77 alpha:1];
    UIImage *highlightImage = [self convertViewToImage:highlightView];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(2*buttonWidth + 2*5 + 5, 3*(200/4.0) + 5 + 3*5, buttonWidth, 50);
    deleteBtn.backgroundColor = [UIColor lightGrayColor];
    [deleteBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self addDeleteImageWithDeleteBtn:deleteBtn];
//    UIImage *deleteImage = [StringUtil getImageByResName:@"delete123.png"];
//    UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
//    deleteImageView.frame = CGRectMake((buttonWidth-(40*(4/3.0)))/2.0, 5, 40*(4/3.0), 40);
//    [deleteBtn addSubview:deleteImageView];
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.numberKeyboard addSubview:deleteBtn];
    
    [self addSubview:self.numberKeyboard];
}

- (void)backClick:(UIButton *)sender
{
    CGRect keyboardRect = self.keyboard.frame;
    keyboardRect.origin.y = 0;
    self.keyboard.frame = keyboardRect;
    
    CGRect numberKeyboardRect = self.numberKeyboard.frame;
    numberKeyboardRect.origin.y = self.frame.size.height;
    self.numberKeyboard.frame = numberKeyboardRect;
}

- (void)clickNumberKeyboard:(UIButton *)sender
{
    NSString *number = self.myNumbers[sender.tag - 600];
    
    [self.mText appendString:number];
    
    [self setTextfield];
}

- (void)clickPunctuationKeyboard:(UIButton *)sender
{
    NSString *punctuation = self.myPunctuation[sender.tag - 700];
    
    [self.mText appendString:punctuation];
    
    [self setTextfield];
}


-(UIImage*)convertViewToImage:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 添加字母键盘
- (void)addKeyboard
{
    self.keyboard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 225)];
    self.keyboard.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 150, 25)];
    title.text = @"南航飞信安全键盘";
    [title setTextColor:[UIColor grayColor]];
    [self.keyboard addSubview:title];
    
    RoundCornersView *backGroundView = [[RoundCornersView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    backGroundView.backgroundColor = [UIColor clearColor];
    CGFloat buttonWidth = (self.frame.size.width/10.0);
    
    for (int i = 0; i < 26; i++)
    {
        RoundCornersLabel *label = [[RoundCornersLabel alloc]init];
        label.clipsToBounds = NO;
        
        int index = i;
        if (i >= 19)
        {
            index = i + 1;
        }
        label.frame = CGRectMake((index%10)*buttonWidth + (index/10)*(buttonWidth/2.0) + 3, (index/10)*(200/4.0) + 10 + 25, 30, 40);
        label.text = self.myLowerCharacters[i];
        [label setFont:[UIFont systemFontOfSize:18]];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:[UIColor blackColor]];
        label.tag = 500 + i;
        
        [self.keyboard addSubview:label];
    }
    /*
    for (int i = 0; i < 26; i++)
    {
        RoundCornersButton *button = [RoundCornersButton buttonWithType:UIButtonTypeCustom];
        int index = i;
        if (i >= 19)
        {
            index = i + 1;
        }
        button.frame = CGRectMake((index%10)*buttonWidth + (index/10)*(buttonWidth/2.0) + 3, (index/10)*(200/4.0) + 10 + 25, 30, 40);
        [button setBackgroundImage:[self convertViewToImage:backGroundView] forState:UIControlStateHighlighted];
        [button setTitle:self.myLowerCharacters[i] forState:UIControlStateNormal];
        [button setTitle:self.myUpperCharacters[i] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag = 500 + i;
        [button addTarget:self action:@selector(clickKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.keyboard addSubview:button];
    }
    */
    self.capitalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.capitalBtn.frame = CGRectMake(2, 2*(200/4.0) + 10 + 25, 30, 40);
    
    UIImage *caseImage = [StringUtil getImageByResName:@"lower.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.capitalBtn.frame.size.width - caseImage.size.width) * 0.5, (self.capitalBtn.frame.size.height - caseImage.size.height) * 0.5 , caseImage.size.width, caseImage.size.height)];
    imageView.image = caseImage;
    imageView.tag = IMAGEVIEW_TAG;
    [self.capitalBtn addSubview:imageView];
    [self.capitalBtn addTarget:self action:@selector(clickCapital:) forControlEvents:UIControlEventTouchUpInside];
    self.capitalBtn.backgroundColor = [UIColor lightGrayColor];
    [self.keyboard addSubview:self.capitalBtn];
    
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 40)];
    highlightView.backgroundColor = [UIColor colorWithWhite:0.77 alpha:1];
    UIImage *highlightImage = [self convertViewToImage:highlightView];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(self.frame.size.width - 55 - 2, 2*(200/4.0) + 10 + 25, 55, 40);
    deleteBtn.backgroundColor = [UIColor lightGrayColor];
    [deleteBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self addDeleteImageWithDeleteBtn:deleteBtn];
//    UIImage *deleteImage = [StringUtil getImageByResName:@"delete123.png"];
//    UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
//    deleteImageView.frame = CGRectMake((55-(34*(4/3.0)))/2.0, 0, 34*(4/3.0), 40);
//    [deleteBtn addSubview:deleteImageView];
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboard addSubview:deleteBtn];
    
    
    UIButton *numberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    numberBtn.frame = CGRectMake(10, 3*(200/4.0) + 10 + 25, 40, 30);
    numberBtn.backgroundColor = BLUE_COLOR;
    [numberBtn setTitle:@"123" forState:UIControlStateNormal];
    [numberBtn addTarget:self action:@selector(numberClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboard addSubview:numberBtn];
    
    UIButton *punctuationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    punctuationBtn.frame = CGRectMake(10 + buttonWidth + 10, 3*(200/4.0) + 10 + 25, 50, 30);
    punctuationBtn.backgroundColor = BLUE_COLOR;
    [punctuationBtn setTitle:@"@#%" forState:UIControlStateNormal];
    [punctuationBtn addTarget:self action:@selector(punctuationClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboard addSubview:punctuationBtn];
    
    UIButton *spaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    spaceBtn.frame = CGRectMake(20 + 2 * buttonWidth + 10 + 10, 3*(200/4.0) + 10 + 25, self.frame.size.width*(2/5.0), 30);
    [spaceBtn setBackgroundColor:[UIColor whiteColor]];
    [spaceBtn addTarget:self action:@selector(spaceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboard addSubview:spaceBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(self.frame.size.width - 50 - 30, 3*(200/4.0) + 10 + 25, 55, 30);
    doneBtn.backgroundColor = BLUE_COLOR;
    [doneBtn setTitle:@"done" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboard addSubview:doneBtn];
    [self addSubview:self.keyboard];
}

- (void)clickKeyboard:(UIButton *)sender
{
    NSString *character = _isCapital ? self.myUpperCharacters[sender.tag - 500] : self.myLowerCharacters[sender.tag - 500];
    
    [self.mText appendString:character];
    
    [self setTextfield];
}

- (void)clickCapital:(UIButton *)sender
{
    _isCapital = !_isCapital;
    
    NSInteger count = 0;
    for (UIView *character in self.keyboard.subviews)
    {
        if ([[character class] isEqual:[RoundCornersLabel class]])
        {
            RoundCornersLabel *label = (RoundCornersLabel *)character;
            label.text = _isCapital ? self.myUpperCharacters[count++] : self.myLowerCharacters[count++];
        }
    }
    
    UIImageView *imageView = [self.capitalBtn viewWithTag:IMAGEVIEW_TAG];
    if (_isCapital)
    {
        imageView.image = [StringUtil getImageByResName:@"upper.png"];
    }
    else
    {
        imageView.image = [StringUtil getImageByResName:@"lower.png"];
    }
}

- (void)deleteClick:(UIButton *)sender
{
    if (self.mText.length > 0)
    {
        [self.mText deleteCharactersInRange:NSMakeRange(self.mText.length - 1, 1)];
    }
    [self setTextfield];
}

- (void)spaceClick:(UIButton *)sender
{
    [self.mText appendString:@" "];
    [self setTextfield];
}

// 弹出数字键盘
- (void)numberClick:(UIButton *)sender
{
    CGRect keyboardRect = self.keyboard.frame;
    keyboardRect.origin.y = 225;
    self.keyboard.frame = keyboardRect;
    
    CGRect numberKeyboardRect = self.numberKeyboard.frame;
    numberKeyboardRect.origin.y = 0;
    self.numberKeyboard.frame = numberKeyboardRect;
}

// 弹出标点符号键盘
- (void)punctuationClick:(UIButton *)sender
{
    CGRect keyboardRect = self.keyboard.frame;
    keyboardRect.origin.y = 225;
    self.keyboard.frame = keyboardRect;
    
    CGRect punctuationKeyboardRect = self.punctuationKeyboard.frame;
    punctuationKeyboardRect.origin.y = 0;
    self.punctuationKeyboard.frame = punctuationKeyboardRect;
}

- (void)doneClick:(UIButton *)sender
{
    if(_safeKeyBoardDelegate && [_safeKeyBoardDelegate respondsToSelector:@selector(clickLoginButton)])
    {
        [_safeKeyBoardDelegate clickLoginButton];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint gestureStartPoint = [touch locationInView:self.keyboard];
    NSInteger count = self.keyboard.subviews.count;
    for (UIView *view in self.keyboard.subviews)
    {
        if ([[view class] isEqual:[RoundCornersLabel class]])
        {
            if (CGRectContainsPoint(view.frame, gestureStartPoint))
            {
                UILabel *label = (UILabel *)view;
                self.alphabetImage = [[UIImageView alloc] init];
                NSString *imageName = nil;
                if (label.tag == 500)
                {
                    imageName = @"alphabetLeft.png";
                    self.alphabetImage.frame = CGRectMake(0, -50, 45, 90);
                }
                else if (label.tag == 500+9)
                {
                    imageName = @"alphabetRight.png";
                    self.alphabetImage.frame = CGRectMake(-15, -50, 45, 90);
                }
                else
                {
                    imageName = @"alphabet.png";
                    self.alphabetImage.frame = CGRectMake(-7, -50, 45, 90);
                }
                UIImage *image = [StringUtil getImageByResName:imageName];
//                self.alphabetImage.backgroundColor = [UIColor redColor];
                self.alphabetImage.image = image;
                
                UILabel *bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 45, 35)];
                bigLabel.text = label.text;
                [bigLabel setFont:[UIFont systemFontOfSize:30]];
                bigLabel.textAlignment = NSTextAlignmentCenter;
                [self.alphabetImage addSubview:bigLabel];
                [view addSubview:self.alphabetImage];
                
                _alphabetIndex = label.tag - 500;
                
                return;
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint gestureStartPoint = [touch locationInView:self.keyboard];
    NSInteger count = self.keyboard.subviews.count;
    for (UIView *view in self.keyboard.subviews)
    {
        if ([[view class] isEqual:[RoundCornersLabel class]])
        {
            if (CGRectContainsPoint(view.frame, gestureStartPoint))
            {
                UILabel *label = (UILabel *)view;
                if (label.tag == _alphabetIndex) {
                    return;
                }
                if (self.alphabetImage != nil)
                {
                    [self.alphabetImage removeFromSuperview];
                    self.alphabetImage = nil;
                }
                
                self.alphabetImage = [[UIImageView alloc] init];
                NSString *imageName = nil;
                if (label.tag == 500)
                {
                    imageName = @"alphabetLeft.png";
                    self.alphabetImage.frame = CGRectMake(0, -50, 45, 90);
                }
                else if (label.tag == 500+9)
                {
                    imageName = @"alphabetRight.png";
                    self.alphabetImage.frame = CGRectMake(-15, -50, 45, 90);
                }
                else
                {
                    imageName = @"alphabet.png";
                    self.alphabetImage.frame = CGRectMake(-7, -50, 45, 90);
                }
                UIImage *image = [StringUtil getImageByResName:imageName];
                self.alphabetImage.image = image;
                
                UILabel *bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 45, 35)];
                bigLabel.text = label.text;
                [bigLabel setFont:[UIFont systemFontOfSize:30]];
                bigLabel.textAlignment = NSTextAlignmentCenter;
                [self.alphabetImage addSubview:bigLabel];
                [view addSubview:self.alphabetImage];
                
                _alphabetIndex = label.tag - 500;
                
                return;
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.alphabetImage removeFromSuperview];
    self.alphabetImage = nil;
    
    
    UITouch *touch = [touches anyObject];
    CGPoint gestureStartPoint = [touch locationInView:self.keyboard];
    NSInteger count = self.keyboard.subviews.count;
    UIView *view = [self.keyboard viewWithTag:_alphabetIndex +500];
    if (CGRectContainsPoint(view.frame, gestureStartPoint))
    {
        NSString *character = _isCapital ? self.myUpperCharacters[_alphabetIndex] : self.myLowerCharacters[_alphabetIndex];
        [self.mText appendString:character];
        [self setTextfield];
    }
    NSLog(@"%@",self.mText);
}

- (void)addDeleteImageWithDeleteBtn:(UIButton *)deleteBtn
{
    UIImage *deleteImage = [StringUtil getImageByResName:@"delete123.png"];
    UIImageView *deleteImageView = [[UIImageView alloc] initWithImage:deleteImage];
    deleteImageView.frame = CGRectMake((deleteBtn.frame.size.width - deleteImage.size.width) * 0.5, (deleteBtn.frame.size.height - deleteImage.size.height) * 0.5, deleteImage.size.width, deleteImage.size.height);
    
    //    deleteImageView.frame = CGRectMake((buttonWidth-(40*(4/3.0)))/2.0, 5, 40*(4/3.0), 40);
    [deleteBtn addSubview:deleteImageView];
}

@end
