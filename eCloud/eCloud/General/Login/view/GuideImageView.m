//
//  GuideImageView.m
//  GuideImageDemo
//
//  Created by Alex L on 17/1/11.
//  Copyright © 2017年 Alex L. All rights reserved.
//

#import "GuideImageView.h"
#import "YYImage.h"
#import "YYAnimatedImageView.h"
#import "StringUtil.h"

#define SCRREN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCRREN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define GIF_LAST_INDEX 33

@interface GuideImageView ()<UIScrollViewDelegate>
{
    NSTimer *_timer;
    
    NSInteger _currentIndex;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation GuideImageView

- (void)dealloc
{
    [self removeTimer];
    
    NSLog(@"%s", __func__);
}

- (instancetype)initWithImages:(NSArray *)images
{
    if (self = [super init])
    {
        [self setupUI];
        
        self.images = images;
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupUI];
    }
    
    return self;
}

- (void)setImages:(NSArray *)images
{
    _images = images;
    
    self.pageControl.numberOfPages = _images.count;
    
    self.scrollView.contentSize = CGSizeMake(SCRREN_WIDTH*_images.count, 0);
    
    for (int i = 0; i < _images.count; i++)
    {
        NSString *imageName = [[StringUtil getBundle] pathForResource:_images[i] ofType:nil];
        YYImage *image = [YYImage imageWithContentsOfFile:imageName];
        YYAnimatedImageView *animatedImageView = [[YYAnimatedImageView alloc] initWithImage:image];
        animatedImageView.frame = CGRectMake(i*SCRREN_WIDTH, 0, SCRREN_WIDTH, SCRREN_HEIGHT);
        [self.scrollView addSubview:animatedImageView];
        
        if ([_images[i] hasSuffix:@"gif"])
        {
            [animatedImageView addObserver:self forKeyPath:@"currentAnimatedImageIndex" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        animatedImageView.tag = i+100;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        animatedImageView.userInteractionEnabled = YES;
        [animatedImageView addGestureRecognizer:tap];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 如果是gif图就监听当前播放到了哪一张，如果到最后一张就停止播放
    if ([keyPath isEqualToString:@"currentAnimatedImageIndex"])
    {
        int index = [[change valueForKey:NSKeyValueChangeNewKey] intValue];
        if (index == GIF_LAST_INDEX)
        {
            [object performSelector:@selector(stopAnimating)];
            [object removeObserver:self forKeyPath:keyPath];
        }
    }
}

- (void)tapImageView:(UIGestureRecognizer *)getsture
{
    if (_currentIndex == self.images.count-1)
    {
        self.userInteractionEnabled = NO;
        
        UIView *view = getsture.view;
        if (view.tag == 103)
        {
            [self removeSelfFromSuperView];
        }
    }
}

- (void)setupUI
{
    self.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCRREN_WIDTH, SCRREN_HEIGHT)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.center.x-60/2, SCRREN_HEIGHT-50, 60, 20)];
    [self addSubview:self.pageControl];
}

- (void)removeSelfFromSuperView
{
    //首尾式动画
    [UIView beginAnimations:nil context:nil];
    //执行动画
    //设置动画执行时间
    [UIView setAnimationDuration:1.2];
    //设置代理
    [UIView setAnimationDelegate:self];
    //设置动画执行完毕调用的事件
    [UIView setAnimationDidStopSelector:@selector(didStopAnimation)];
    
    self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.alpha = 0;
    
    [UIView commitAnimations];
    
    
    // 第二次启动就不展示引导页了
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:GUIDE_IMAGE_KEY];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)didStopAnimation
{
    NSLog(@"didStopAnimation");
    [self removeTimer];
    [self removeFromSuperview];
}


#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = (scrollView.contentOffset.x)/SCRREN_WIDTH;
    self.pageControl.currentPage = index;
    
    
    
    CGFloat distance = scrollView.contentOffset.x - (SCRREN_WIDTH*(self.images.count-1));
    if (index == self.images.count-1)
    {
        NSLog(@"%f",1 - distance/260);
        self.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1 - distance/260];
        
        if (distance > 90)
        {
            //首尾式动画
            [UIView beginAnimations:nil context:nil];
            //执行动画
            //设置动画执行时间
            [UIView setAnimationDuration:0.7];
            //设置代理
            [UIView setAnimationDelegate:self];
            //设置动画执行完毕调用的事件
            [UIView setAnimationDidStopSelector:@selector(didStopAnimation)];
            
            self.scrollView.frame = CGRectMake(-SCRREN_WIDTH, 0, SCRREN_WIDTH, SCRREN_HEIGHT);
            self.alpha = 0;
            
            [UIView commitAnimations];
        }
    }
    
    
    if (index != _currentIndex)
    {
        if (index == self.images.count-1)
        {
            _currentIndex = index;
            NSLog(@"index = %ld", (long)index);
            NSLog(@"开启定时器");
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerAction) userInfo:nil repeats:NO];
        }
        else
        {
            _currentIndex = index;
            
            [self removeTimer];
        }
    }
}

- (void)removeTimer
{
    if ([_timer isValid])
    {
        [_timer invalidate];
        
        NSLog(@"取消定时器");
    }
    
    _timer = nil;
}

- (void)timerAction
{
    [self removeSelfFromSuperView];
}

@end
