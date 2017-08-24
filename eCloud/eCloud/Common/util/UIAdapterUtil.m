
#import "MLNavigationController.h"
#import "UIAdapterUtil.h"
#import "UserInterfaceUtil.h"
#import "UserDefaults.h"
#import "OpenCtxDefine.h"

#import "AppDelegate.h"
#import "LogUtil.h"

#ifdef _BGY_FLAG_
#import "BGYMoreViewControllerARC.h"
#endif

#import "eCloudConfig.h"
#import "TabbarUtil.h"

#import "ImageUtil.h"
#import "eCloudDefine.h"
#import "Conversation.h"
#import "contactViewController.h"
#import "PSBackButtonUtil.h"
#import "talkSessionViewController.h"
#import "Conversation.h"
#import "StringUtil.h"
#import "MessageView.h"
#import "contactViewController.h"
#import "NewChooseMemberViewController.h"
#import "LANGUANGAgentViewControllerARC.h"


#define BLACK_COLOR [UIColor colorWithRed:0X11/255.0 green:0X11/255.0 blue:0X11/255.0 alpha:1]
#define WHITE_COLOR [UIColor colorWithRed:0Xf8/255.0 green:0Xf8/255.0 blue:0Xf8/255.0 alpha:1]

//南航budnle名称
#define CSAIR_BUNDLE_NAME @"CsairBundle"
//国美bundle名称
#define GOME_BUNDLE_NAME @"GOMEBundle"
//泰禾bundle名称
#define TAIHE_BUNDLE_NAME @"TaiHeBundle"
//碧桂园bundle名称
#define BGY_BUNDLE_NAME @"BGYBundle"
//龙湖bundle名称
#define LONGHU_BUNDLE_NAME @"LongHuBundle"
//华夏幸福bundle名称
#define HXXF_BUNDLE_NAME @"HUAXIABundle"
//新华网bundle名称
#define XINHUA_BUNDLE_NAME @"XINHUABundle"
/** 蓝光bundle名称 */
#define LANGUANG_BUNDLE_NAME @"LANGUANGBundle"
/** 祥源bundle名称 */
#define XIANGYUAN_BUNDLE_NAME @"XIANGYUANBundle"

@implementation UIAdapterUtil

+ (void)customToolBar:(UIToolbar *)toolBar
{
    UIColor *_color = [UIAdapterUtil getDarkNavigationBarColor];
#ifdef _LANGUANG_FLAG_
    _color = [UIColor whiteColor];
#endif
    if (IOS7_OR_LATER)
    {
        toolBar.barTintColor = _color;
    }
    else
    {
        UIImage *bgImage = [ImageUtil imageWithColor:_color];
        [toolBar setBackgroundImage:bgImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

+ (void)customLightNavigationBar:(UINavigationBar *)navigationBar
{
    UIColor *_color = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0];
    if (IOS7_OR_LATER)
    {
        navigationBar.barTintColor = _color;
        navigationBar.tintColor = [UIColor whiteColor];
    }
    else
    {
        UIImage *bgImage = [ImageUtil imageWithColor:_color];
        [navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    }
}

+ (UIColor *)getDarkNavigationBarColor
{
    UIColor *_color = [UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
    return _color;
}

+ (void)customNavigationBar
{
//    UIColor *_color = [UIColor colorWithRed:27/255.0 green:73/255.0 blue:138/255.0 alpha:1];
   // UIColor *_color = [UIColor colorWithRed:40/255.0 green:83/255.0 blue:142/255.0 alpha:1];
    // change by toxicanty
    //UIColor *_color = [UIColor colorWithRed:49/255.0 green:143/255.0 blue:246/255.0 alpha:1];
    // changed 0802 跟随图片颜色, 以免判断万达or南航
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    UIColor *_color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navImage"]];
#elif defined(_BGY_FLAG_)
    UIColor *_color = WHITE_COLOR;
#else
    UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
#endif
    if (IOS7_OR_LATER)
    {
        
//        [UINavigationBar appearance].barTintColor = _color;
        UIImage *bgImage = [ImageUtil imageWithColor:_color];
        [[UINavigationBar appearance] setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];

#ifdef _BGY_FLAG_
        [[UINavigationBar appearance]setTintColor:BLACK_COLOR];
#else
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
#endif
        //去除UINavigationBar底部的黑线
//        [[UINavigationBar appearance] setShadowImage:[[[UIImage alloc] init] autorelease]];
        
#ifdef _BGY_FLAG_
        // 标题
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{ NSForegroundColorAttributeName:BLACK_COLOR,
            NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
#else
        
#ifdef _LANGUANG_FLAG_
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{ NSForegroundColorAttributeName: [UIColor blackColor],
            NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
        
#else
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{ NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]}];
        
#endif
        
#endif
        
        
        /*
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 20)];
        statusBarView.backgroundColor=[UIColor blackColor];
        [[UINavigationBar appearance] addSubview:statusBarView];
        [statusBarView release];
         */
//        设置返回按钮文字旁的图片
//        [[UINavigationBar appearance] setBackIndicatorImage:[StringUtil getImageByResName:@"left_button_bg.png"]];
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[StringUtil getImageByResName:@"left_button_bg.png"]];
//        设置默认的按钮上的字的颜色
//        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
        
//        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor]} forState:UIControlStateHighlighted];
//         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:<#(UIControlState)#>]
//        [[UIBarButtonItem appearance] setTitleTextAttributes:
//        [NSDictionarydictionaryWithObjectsAndKeys:
//         [UIColor whiteColor],	 UITextAttributeTextColor, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
//         [UIFont fontWithName:@"AmericanTypewriter" size:0.0],
//         UITextAttributeFont, nil] forState:UIControlStateNormal];
    }
    else
    {
         UIImage *bgImage = [ImageUtil imageWithColor:_color];
        [[UINavigationBar appearance] setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    }
    
//    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 20)];
//    statusBarView.backgroundColor=[UIColor blackColor];
//    [[UINavigationBar appearance] addSubview:statusBarView];
//    [statusBarView release];
}

+ (void)setSearchBarBackgroundColor:(UIColor *)color
{
    UIImage *image = [ImageUtil imageWithColor:color];
    
    if (IOS7_OR_LATER)
    {
        [[UISearchBar appearance]setBarTintColor:color];
        
#ifdef _XINHUA_FLAG_
      
        [[UISearchBar appearance]setBarTintColor:[UIColor colorWithWhite:0.75 alpha:1]];
#endif
        
        [[UISearchBar appearance] setBackgroundImage:image];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    }
    else
    {
        UIImage *backGroundImage = [ImageUtil imageWithColor:color];
        [[UISearchBar appearance] setBackgroundImage:backGroundImage];
    }
}

+ (void)customSearchBar
{
    UIColor *bgColor = [UIAdapterUtil getSearchBarColor];
    
    
    
    UIImage *image = [ImageUtil imageWithColor:bgColor];// [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1]];
    
    if (IOS7_OR_LATER)
    {
        [[UISearchBar appearance]setBarTintColor:bgColor];
        
        [[UISearchBar appearance] setBackgroundImage:image];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:35/255.0 green:135/255.0 blue:252/255.0 alpha:1],UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    
    }
    else
    {
        UIImage *backGroundImage = [ImageUtil imageWithColor:bgColor];
        [[UISearchBar appearance] setBackgroundImage:backGroundImage];
    }
}

+ (void)customTabBar
{
    UIColor *_color = [UIAdapterUtil getDarkNavigationBarColor];
    if (IOS7_OR_LATER)
    {
        [UITabBar appearance].barTintColor = _color;
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],UITextAttributeTextColor, nil] forState:UIControlStateSelected];
     }
    else
    {
        UIImage *bgImage = [ImageUtil imageWithColor:_color];
        [[UITabBar appearance]setBackgroundImage:bgImage];
    }
}

+ (UIColor *)getSearchBarColor
{
    if ([self isBGYApp])
    {
        return [UIColor colorWithWhite:0.93 alpha:1];
    }
    return SEARCH_BAR_BGCOLOR;//  [UIColor colorWithRed:210/255.0 green:215/255.0 blue:220/255.0 alpha:1];
}

+ (UIColor *)getDominantColor
{
    return [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
}

+ (void)openConversation:(UIViewController *)currentViewController andEmp:(Emp *)curEmp
{
    // 初始化聊天界面的基本内容
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = singleType;
    talkSession.titleStr = curEmp.emp_name;
	talkSession.needUpdateTag = 1;
    talkSession.convId = [NSString stringWithFormat:@"%d",curEmp.emp_id];
    talkSession.convEmps = [NSArray arrayWithObject:curEmp];
    
    // 若当前控制器就是聊天控制器，不做处理直接返回
	for(UIViewController *controller in currentViewController.navigationController.viewControllers)
	{
		if([controller isKindOfClass:[talkSessionViewController class]])
		{
			[currentViewController.navigationController popToViewController:talkSession animated:YES];
			return;
		}
	}
    // 初始化会话对象
    Conversation *conv = [[Conversation alloc]init];
    conv.conv_id = [StringUtil getStringValue:curEmp.emp_id];
    conv.conv_type = singleType;
    conv.recordType = normal_conv_record_type;
    conv.emp = curEmp;
    
    contactViewController *contactView = [UIAdapterUtil getContactViewController:currentViewController];
    [contactView openConversation:conv];
    [conv release];
    
//    [currentViewController.tabBarController setSelectedIndex:0];
    [UIAdapterUtil showChatPage:currentViewController];
    
    for (UIViewController *viewController in currentViewController.navigationController.viewControllers){
        if([viewController isKindOfClass:[contactViewController class]])
		{
			return;
		}
    }
//    [currentViewController dismissModalViewControllerAnimated:YES];
    [currentViewController.navigationController popToRootViewControllerAnimated:YES];
}

+ (contactViewController *)getContactViewController:(UIViewController *)currentViewController
{
    UINavigationController *firstNavigation = (UINavigationController *)[currentViewController.tabBarController.viewControllers objectAtIndex:[eCloudConfig getConfig].conversationIndex];
    
    contactViewController *contactView = (contactViewController *)[firstNavigation.viewControllers objectAtIndex:0];
    
    return contactView;

}

+ (void)processController:(UIViewController *)currentController
{
    // 在导航栏不透明的时候，是否可以拓展，与translucent搭配使用，默认translucent是YES为半透明
    // 当translucent为NO时，视图会自动下压，以导航栏下方作为y=0
    // extendedLayoutIncludesOpaqueBars默认是NO，是不进行拓展的，也就是说translucent=NO时，默认视图的y的0点在导航栏下方
    // extendedLayoutIncludesOpaqueBars为YES时，且translucent=NO时，视图的y的0点屏幕左上方
    if ([currentController respondsToSelector:@selector(extendedLayoutIncludesOpaqueBars)]) {
        currentController.extendedLayoutIncludesOpaqueBars = NO;
        currentController.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 是对上面的一个补充，上面只是在导航栏不透明时才生效
    // 当导航栏为默认的半透明状态时，当前控制器视图默认是UIRectEdgeAll会进行自动延伸，这里设置不允许向上进行延伸，这样导航栏就不会遮挡住显示的视图
    if ([currentController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        currentController.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
}

//不显示默认的背景
+ (void)removeBackground:(UITableViewCell *)cell
{
    cell.backgroundView = nil;
    cell.selectedBackgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
}

+ (void)customCellBackground:(UITableView *)tableView andCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cornerRadius = 6.0f;
    cell.backgroundColor = UIColor.clearColor;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(cell.bounds, 10, 0);
    BOOL addLine = NO;
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
    } else if (indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        addLine = YES;
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
        addLine = YES;
    }
    layer.path = pathRef;
    CFRelease(pathRef);
    layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.5f].CGColor;

#ifdef _LANGUANG_FLAG_
    
    layer.strokeColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0.2].CGColor;
#else
    layer.strokeColor = [UIColor lightGrayColor].CGColor;
#endif

    if (addLine == YES) {
        CALayer *lineLayer = [[CALayer alloc] init];
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
#ifdef _LANGUANG_FLAG_
        
        lineLayer.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0.5].CGColor;
#else
        lineLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
#endif
        
        
        [layer addSublayer:lineLayer];
    }
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    testView.backgroundColor = UIColor.clearColor;
    cell.backgroundView = testView;
}


+ (void)positionSwitch:(UISwitch *)_switch ofCell:(UITableViewCell *)cell
{
//    if (IOS7_OR_LATER)
//    {
//        float x = cell.frame.size.width - _switch.frame.size.width - 15;
        // 在iphone 6及以上版本，系统返回的cell宽度为320，而不是375，所以通过屏幕宽度变向获取
        float x = [[UIScreen mainScreen] applicationFrame].size.width - _switch.frame.size.width - 15;
        float y = (cell.frame.size.height - _switch.frame.size.height) / 2;
        CGRect switchRect = _switch.frame;
        switchRect.origin.x = x;
        switchRect.origin.y = y;
        _switch.frame = switchRect;
//    }
}

//导航栏左侧按钮 是否显示 小于号 图片
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)targetCtrl andCurrCtrl:(UIViewController *)currCtrl andSelector:(SEL)_sel andDisplayLeftButtonImage:(BOOL)displayLeftButtonImage
{
    UIButton *_button = [PSBackButtonUtil initBackButton:btnTitle];
    
    CGFloat spaceWidth = -10.0f;
    
    if (!displayLeftButtonImage)
    {
        spaceWidth = -20.0f;
        [_button setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    [_button addTarget:targetCtrl action:_sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:_button];
    
    //ios7 直接使用 setLeftBarButtonItem item会向右靠 用此方法恢复它的位置
    if (IOS7_OR_LATER)
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = spaceWidth;
        
        NSArray* barButtons = nil;
        barButtons = [NSArray arrayWithObjects: space, item,nil ];
        
        [currCtrl.navigationItem setLeftBarButtonItems:barButtons];
        [space release];
    }
    else
    {
        if (!displayLeftButtonImage)
        {
            [_button setBackgroundImage:nil forState:UIControlStateNormal];
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = -10.0f;
            
            NSArray* barButtons = nil;
            barButtons = [NSArray arrayWithObjects: space, item,nil ];
            
            [currCtrl.navigationItem setLeftBarButtonItems:barButtons];
            [space release];
            [item release];
            return _button;
        }
        [currCtrl.navigationItem setLeftBarButtonItem:item];
    }
    [item release];
    
#ifdef _BGY_FLAG_
    [_button setTitleColor:BLACK_COLOR forState:(UIControlStateNormal)];
#endif
    return _button;
}

// 更改左侧返回按钮的文字标题
+ (void)changeLeftButtonTitle:(NSArray<UIBarButtonItem *> *)leftBarButtonItems andTarget:(UIViewController *)currentController
{
    if (leftBarButtonItems && leftBarButtonItems.count == 2) {
        // 取出带有标题的按钮
        UIBarButtonItem *itemBtn = leftBarButtonItems[leftBarButtonItems.count - 1];
        if (itemBtn && [itemBtn.customView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)itemBtn.customView;
            
            NSString *title = [StringUtil getLocalizableString:@"back"];
            
            // 待办首页因为一直是同一个控制器，要通过判断webview是否能返回确定返回按钮的文字内容
            if ([currentController isKindOfClass:[LANGUANGAgentViewControllerARC class]]) {
                LANGUANGAgentViewControllerARC *agentViewCtrl = (LANGUANGAgentViewControllerARC *)currentController;
                if (![agentViewCtrl isCanBack] && currentController.navigationController.childViewControllers.count > 0) {
                    if (currentController.navigationController.childViewControllers.count == 2) {
                        // 取出前一个控制器的标题
                        title = currentController.navigationController.childViewControllers[0].title;
                    }
                }
            }
            [btn setTitle:title forState:UIControlStateNormal];
        }
    }
}

//导航栏左侧按钮 是否显示 小于号 图片
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
               andDisplayLeftButtonImage:(BOOL)displayLeftButtonImage
{
    //    PSBackButtonUtil中已经定义了返回按钮，这里直接使用 add by shisp
    NSString *leftTitle = [StringUtil getLocalizableString:@"back"];
    if (currentController.navigationController.childViewControllers.count > 0) {
        
        if (currentController.navigationController.childViewControllers.count == 2) {
            // 取出前一个控制器的标题
            leftTitle = currentController.navigationController.childViewControllers[0].title;
        }
    }
    
    UIButton *_button = [PSBackButtonUtil initBackButton:leftTitle];
    
    CGFloat spaceWidth = -10.0f;
    
    if (!displayLeftButtonImage)
    {
        spaceWidth = -20.0f;
        [_button setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    [_button addTarget:currentController action:_sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:_button];
    
    //ios7 直接使用 setLeftBarButtonItem item会向右靠 用此方法恢复它的位置
    if (IOS7_OR_LATER)
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = spaceWidth;
        
        NSArray* barButtons = nil;
        barButtons = [NSArray arrayWithObjects: space, item,nil ];
        
        [currentController.navigationItem setLeftBarButtonItems:barButtons];
        [space release];
    }
    else
    {
        if (!displayLeftButtonImage)
        {
            [_button setBackgroundImage:nil forState:UIControlStateNormal];
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = -10.0f;
            
            NSArray* barButtons = nil;
            barButtons = [NSArray arrayWithObjects: space, item,nil ];
            
            [currentController.navigationItem setLeftBarButtonItems:barButtons];
            [space release];
            [item release];
            return _button;
        }
        [currentController.navigationItem setLeftBarButtonItem:item];
    }
    [item release];
    
#ifdef _BGY_FLAG_
    [_button setTitleColor:BLACK_COLOR forState:(UIControlStateNormal)];
#endif
    return _button;
}

//设置左边按钮，指定标题，指定target，指定action
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
{
    return [[self class]setLeftButtonItemWithTitle:btnTitle andTarget:currentController andSelector:_sel andDisplayLeftButtonImage:YES];
}

+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)targetController andCurrCtrl:(UIViewController *)currCtrl andSelector:(SEL)_sel
{
    return [[self class]setLeftButtonItemWithTitle:btnTitle andTarget:targetController andCurrCtrl:currCtrl andSelector:_sel andDisplayLeftButtonImage:YES];
}

+ (float)getRightButtonWidth:(NSString *)btnTitle
{
    float curWidth = [btnTitle sizeWithFont:[UIFont systemFontOfSize:default_button_font_size]].width;
    
    if ((curWidth + 20) < default_right_button_width) {
        return default_right_button_width;
    }
    return curWidth + 20;
}

//设置右边按钮，指定标题，指定target，指定action
+ (UIButton *)setRightButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
{
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, [self getRightButtonWidth:btnTitle], 44);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 25, 0,6);
    UIImage *normalImage = [[MessageView getMessageView]resizeImageWithCapInsets:insets andImage:[StringUtil getImageByResName:@"right_button_bg.png"]];
    [_button setBackgroundImage:normalImage forState:UIControlStateNormal];
    _button.titleLabel.font=[UIFont systemFontOfSize:default_button_font_size];
    _button.titleLabel.textAlignment = NSTextAlignmentRight;
//    _button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    [_button setTitle:btnTitle forState:UIControlStateNormal];
    
#ifdef _LANGUANG_FLAG_
    [_button setTitleColor:lg_main_color forState:UIControlStateNormal];
#else
    [_button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
#endif
    
    
    
    
    [_button addTarget:currentController action:_sel forControlEvents:UIControlEventTouchUpInside];
//    [_button sizeToFit];

    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:_button];
//    currentController.navigationItem.rightBarButtonItem = item;
    if (IOS7_OR_LATER) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -16.0f;
        NSArray *barBtns = nil;
        barBtns = [NSArray arrayWithObjects:space,item, nil];
        
        [currentController.navigationItem setRightBarButtonItems:barBtns];
        [space release];
    }
    else
    {
        [currentController.navigationItem setRightBarButtonItem:item];
    }
    [item release];
    return _button;
}

+(UIButton *)setRightButtonItemWithImageName:(NSString *)imageName andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
{
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 46, 44);
    
    //    [_button setBackgroundImage:[StringUtil getImageByResName:imageName] forState:UIControlStateNormal];
    [_button setImage:[StringUtil getImageByResName:imageName] forState:UIControlStateNormal];
    [_button addTarget:currentController action:_sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:_button];
    
    if (IOS7_OR_LATER) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = -12.0f;
        NSArray *barBtns = nil;
        barBtns = [NSArray arrayWithObjects:space,item, nil];
        
        [currentController.navigationItem setRightBarButtonItems:barBtns];
        [space release];
    }
    else
    {
        [currentController.navigationItem setRightBarButtonItem:item];
    }
    [item release];
    return _button;
}

+(UIButton *)setLeftButtonItemWithImageName:(NSString *)imageName andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
{
    //    PSBackButtonUtil中已经定义了返回按钮，这里直接使用 add by shisp
    UIButton *_button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 46, 44);
    
    //    [_button setBackgroundImage:[StringUtil getImageByResName:imageName] forState:UIControlStateNormal];
    [_button setImage:[StringUtil getImageByResName:imageName] forState:UIControlStateNormal];
    [_button addTarget:currentController action:_sel forControlEvents:UIControlEventTouchUpInside];

    CGFloat spaceWidth = -10.0f;
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc]initWithCustomView:_button]autorelease];
    
    //ios7 直接使用 setLeftBarButtonItem item会向右靠 用此方法恢复它的位置
    if (IOS7_OR_LATER)
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        space.width = spaceWidth;
        
        NSArray* barButtons = nil;
        barButtons = [NSArray arrayWithObjects: space, item,nil ];
        
        [currentController.navigationItem setLeftBarButtonItems:barButtons];
        [space release];
    }
    else
    {
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = -10.0f;
            
            NSArray* barButtons = nil;
            barButtons = [NSArray arrayWithObjects: space, item,nil ];
            
            [currentController.navigationItem setLeftBarButtonItems:barButtons];
            [space release];
    }
    return _button;
}

+(UIButton *)setNewButton:(NSString *)btnTitle andBackgroundImage:(UIImage *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:btnTitle forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
//    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20,20 ,20);
    image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    return button;
}

+ (void)hideTabBar:(UIViewController *)currentController
{
    UITabBarController *tabbarController = [TabbarUtil getTabbarController];
    if ([tabbarController respondsToSelector:@selector(hideTabar)]) {
        [tabbarController hideTabar];
    }else{
        if ([StringUtil isTestApp]) {
            tabbarController = currentController.tabBarController;
            if ([tabbarController isKindOfClass:[UITabBarController class]]) {
                tabbarController.tabBar.hidden = YES;
            }
        }
    }
}

+(void)showTabar:(UIViewController *)currentController{
    UITabBarController *tabbarController = [TabbarUtil getTabbarController];
    if ([tabbarController respondsToSelector:@selector(showTabar)]) {
        [tabbarController showTabar];
    }else{
        if ([StringUtil isTestApp]) {
            tabbarController = currentController.tabBarController;
            if ([tabbarController isKindOfClass:[UITabBarController class]]) {
                tabbarController.tabBar.hidden = NO;
            }
        }
    }
}

+ (void)showChatPage:(UIViewController *)currentController{
    [TabbarUtil showChatPage];
}

+ (void)setBackGroundColorOfController:(UIViewController *)currentController
{
    if ([UIAdapterUtil isGOMEApp])
    {
        currentController.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    }
    else
    {
        currentController.view.backgroundColor = [StringUtil colorWithHexString:@"#F8F8F8"];
//        currentController.view.backgroundColor = [UIColor colorWithRed:244/255.0 green:246/255.0 blue:249/255.0 alpha:1];
    }
}

+ (void)setStatusBar
{
#if defined(_BGY_FLAG_) || defined(_LANGUANG_FLAG_)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    if (IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }
#else
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    if (IOS7_OR_LATER)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
#endif
}

+(void)setStatusBarColor:(UINavigationController *)navController
{
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 320, 20)];
    statusBarView.backgroundColor=[UIColor blackColor];
    [navController.navigationBar addSubview:statusBarView];
    [statusBarView release];
}

+(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
    
    [view release];
}

//在ios7下tableview cell的分割线偏右，左侧留空白，现在去掉这个空白
+ (void)removeLeftSpaceOfTableViewCellSeperateLine:(UITableView *)_tableView
{
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

//在ios7下表格 每行之间的分割线 和 头像对齐
+ (void)alignHeadIconAndCellSeperateLine:(UITableView *)_tableView
{
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        
    }
}

//传参数对分割线进行对齐
+ (void)alignHeadIconAndCellSeperateLine:(UITableView *)_tableView withOriginX:(CGFloat)originx
{
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0,originx,0,0)];
        
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_tableView setLayoutMargins:UIEdgeInsetsMake(0,originx,0,0)];
        
    }
}


//设置searchBar的背景颜色
+ (void)setSearchBar:(UISearchBar *)searchBar withColor:(UIColor *)color
{
    UIView* searchBarBgView = [[UIView alloc] init];
    searchBarBgView.backgroundColor = color;
    searchBarBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    UIGraphicsBeginImageContext(searchBarBgView.bounds.size);
    [searchBarBgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [searchBar setBackgroundImage:image];
}

// 去掉系统searchbar下面的线
+ (void)removeBorderOfSearchBar:(UISearchBar *)_searchBar
{
    if(IOS7_OR_LATER){
        _searchBar.layer.borderWidth = 0.45;
        _searchBar.layer.borderColor = [[UIColor clearColor] CGColor];
//         _searchBar.layer.borderColor = [_searchBar.backgroundColor CGColor];
    }
  
}

//searchBar 的 cancel按钮定制
+ (void)customCancelButton:(UIViewController *)currentController
{
    currentController.searchDisplayController.searchBar.showsCancelButton = YES;
    UIButton *cancelButton = nil;
    
    if(IOS7_OR_LATER)
    {
        UIView *topView = currentController.searchDisplayController.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
    }
    else
    {
        for (UIView *subView in currentController.searchDisplayController.searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
    }
    
    
    if (cancelButton) {
        [cancelButton setTitle: [StringUtil getLocalizableString:@"cancel"] forState:UIControlStateNormal];
    }
}

+(UITextField *)getSearchBarTextField:(UIViewController *)currentController
{
    UITextField *textField = nil;
    if (IOS7_OR_LATER)
    {
        UIView *topView = currentController.searchDisplayController.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITextField")]) {
                textField = (UITextField*)subView;
            }
        }
    }
    else
    {
        for (UIView *subView in currentController.searchDisplayController.searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITextField")]) {
                textField = (UITextField*)subView;
            }
        }
    }
    return textField;
}

//=============适配iphone6 6plus===============

+ (float)getTableCellContentWidth
{
    return SCREEN_WIDTH;
}

// 获得设备屏幕宽度 add by toxicanty 0803
+ (float)getDeviceMainScreenWidth{
    
   CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    return screenWidth;
}


//设置表格高度自适应
+ (void)autoSizeTable:(UITableView *)curTable
{
    curTable.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;//|UIViewAutoresizingFlexibleTopMargin;
}

//========聊天资料界面 聊天成员 名字 对应的字体颜色 灰色=========
+ (UIColor *)getCustomGrayFontColor
{
    return [UIColor colorWithRed:97.0/255 green:96.0/255 blue:96.0/255 alpha:1.0];
}
//查看是否龙湖应用
+ (BOOL)isHongHuApp
{
    if ([[StringUtil getAppBundleName] compare:LONGHU_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}
//查看是否南航
+ (BOOL)isCsairApp
{
    if ([[StringUtil getAppBundleName] compare:CSAIR_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
//    return [[eCloudConfig getConfig]needFixSecurityGap];
}

//查看是否国美
+ (BOOL)isGOMEApp
{
    if ([[StringUtil getAppBundleName] compare:GOME_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
    //    return [[eCloudConfig getConfig]needFixSecurityGap];
}

//查看是否泰禾
+ (BOOL)isTAIHEApp
{
    if ([[StringUtil getAppBundleName] compare:TAIHE_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

//查看是否碧桂园
+ (BOOL)isBGYApp
{
    if ([[StringUtil getAppBundleName] compare:BGY_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

+ (BOOL)isLANGUANGApp
{
    if ([[StringUtil getAppBundleName] compare:LANGUANG_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}
//查看是否华夏幸福
+ (BOOL)isHXXFApp
{
    if ([[StringUtil getAppBundleName] compare:HXXF_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

//查看是否新华网
+ (BOOL)isXINHUAApp
{
    if ([[StringUtil getAppBundleName] compare:XINHUA_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

/** 查看是否是祥源 */
+ (BOOL)isXIANGYUANApp
{
    if ([[StringUtil getAppBundleName] compare:XIANGYUAN_BUNDLE_NAME options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
    
}
//是独立版本还是融合版本
+ (BOOL)isCombineApp
{
    NSString *appType = [UserDefaults getAppType];
    if ([appType isEqualToString:independent_enterprise_type]) {
        return NO;
    }
    return YES;
}

//显示菜单前 查看菜单是否是显示的状态，如果是 那么先将其关闭
+ (void)dismissMenu
{
    UIMenuController * menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [LogUtil debug:@"长按显示菜单时，发现菜单是显示的状态，这时关闭显示"];
        [menu setMenuVisible:NO animated:YES];
    }
}

//弹出viewcontroller
+ (void)presentVC:(UIViewController *)vc
{
    [((AppDelegate *)([UIApplication sharedApplication].delegate)).window.rootViewController presentViewController:vc animated:YES completion:nil];
}

/** 设置 MLNavigationController 属性 */
+ (void)disableDragBackOfNavigationController:(UIViewController *)currentVC
{
    if ([currentVC.navigationController isKindOfClass:[MLNavigationController class]]) {
        MLNavigationController *navi = (MLNavigationController *)currentVC.navigationController;
        navi.canDragBack = NO;
    }
}

/** 设置 MLNavigationController 属性 */
+ (void)enableDragBackOfNavigationController:(UIViewController *)currentVC
{
    if ([currentVC.navigationController isKindOfClass:[MLNavigationController class]]) {
        MLNavigationController *navi = (MLNavigationController *)currentVC.navigationController;
        navi.canDragBack = YES;
    }
}

//是横屏
+ (BOOL)isLandscap
{
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]);
}
//是竖屏
+ (BOOL)isPortrait
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication]statusBarOrientation]);
}

//设置tableview的属性
+ (void)setPropertyOfTableView:(UITableView *)curTableView
{
    if (IOS9_OR_LATER) {
        curTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    if ([UIAdapterUtil isGOMEApp]) {
        
        curTableView.separatorColor = GOME_SEPERATE_COLOR;
    }
    
}
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC

{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
        return topVC;
    }
    
    return nil;
}

//定义选中cell的背景颜色
+ (void)customSelectBackgroundOfCell:(UITableViewCell *)cell
{
    if ([UIAdapterUtil isGOMEApp]) {
        UIColor *color = [[UIColor alloc]initWithRed:0xdd/255.0 green:0xdd/255.0 blue:0xdd/255.0 alpha:1];
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor = color;
    }else{
#ifdef _LANGUANG_FLAG_
//        #EEF5FF 
        UIColor *color = [UIColor colorWithRed:238/255.0 green:245/255.0 blue:255/255.0 alpha:1/1.0];
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor = color;
#else
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
#endif
    }
}

//设置button的image和title之间有10像素的间隔
+ (void)customButtonStyle:(UIButton *)button{
    
    float cellSpaceing = 10.0;
    
    CGSize strSize = [button.currentTitle sizeWithFont:button.titleLabel.font];
    CGFloat totalLen = strSize.width + cellSpaceing + button.imageView.image.size.width;
    
    CGFloat edgeLen = (button.frame.size.width - totalLen) / 2;
    if (edgeLen < cellSpaceing) {
        edgeLen = cellSpaceing;
    }
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, edgeLen, 0, edgeLen + cellSpaceing)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeLen + cellSpaceing, 0, edgeLen)];
}

//设置view圆角属性
+ (void)setCornerPropertyOfView:(UIView *)view
{
    if ([eCloudConfig getConfig].isUserLogoCircle) {
        float width = view.frame.size.width;
        if (width) {
            view.layer.cornerRadius = width * 0.5;
        }else{
            view.layer.cornerRadius = 3;
        }
    }else{
        view.layer.cornerRadius = 3;
    }
    view.clipsToBounds = YES;
}

#ifdef _BGY_FLAG_
// 添加展示左边侧边栏的按钮
+ (void)setupLeftIconItem:(UIViewController *)VC
{
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setImage:[StringUtil getImageByResName:@"touxiang"] forState:(UIControlStateNormal)];
    button.imageEdgeInsets = UIEdgeInsetsMake(-1, -6, 1, 6);
    button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [button addTarget:self action:@selector(showTheMoreVC) forControlEvents:(UIControlEventTouchUpInside)];
    button.frame = CGRectMake(0, 0, 35, 35);
    UIBarButtonItem *fakeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    VC.navigationItem.leftBarButtonItem = fakeButtonItem;
}

+ (void)showTheMoreVC
{
    [[BGYMoreViewControllerARC getMoreViewController] showMoreViewController];
}
#endif

#pragma mark - 搜索提示
+ (void)setSearchResultsTitle:(NSString *)title andCurVC:(UIViewController *)curVC{
    for(UIView *subview in curVC.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            UILabel *tmpSearchResultL = (UILabel *)subview;
            tmpSearchResultL.numberOfLines = 0;
            CGRect lRect = tmpSearchResultL.frame;
            lRect.size.height += lRect.size.height;
            tmpSearchResultL.frame = lRect;
            [(UILabel*)subview setText:title];
        }
    }
}

#pragma mark - 设置搜索背景界面不透明，便于显示提示文字
+ (void)addTipsViewWithView:(UISearchDisplayController*)controller
{
    UIView *supV = controller.searchResultsTableView.superview;
    UIView *supsupV = supV.superview;
    
    for (UIView *view in supsupV.subviews) {
        for (UIView *sencondView in view.subviews) {
            if ([sencondView isKindOfClass:[NSClassFromString(@"_UISearchDisplayControllerDimmingView") class]])
            {
                if (![sencondView viewWithTag:99]) {
                    [sencondView addSubview:[self addBgViewForSearchController]];
                }
                sencondView.alpha = 1;
            }
        }
    }
}

+ (UIView *)addBgViewForSearchController
{
    UIView *tempSearchDisplayBackgroungView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    tempSearchDisplayBackgroungView.backgroundColor = [StringUtil colorWithHexString:@"#F8F8F8"];
    tempSearchDisplayBackgroungView.tag = 99;
    tempSearchDisplayBackgroungView.userInteractionEnabled = NO;
    
    CGFloat fontSize = 14.0f;
    NSString *tips = [StringUtil getLocalizableString:@"search_start_tip"];
    CGSize font = [tips sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    UILabel *labelTips = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-font.width)/2, 100, font.width, font.height)];
    labelTips.font = [UIFont systemFontOfSize:fontSize];
    labelTips.text = tips;
    labelTips.textColor = [StringUtil colorWithHexString:@"#A2A2A2"];
    [tempSearchDisplayBackgroungView addSubview:labelTips];
    return tempSearchDisplayBackgroungView;
}

+ (void)setSearchColorForTextBarAndBackground:(UISearchBar *)searchBar
{
    searchBar.backgroundImage = [[UIImage alloc] init];
    // 设置SearchBar的颜色主题为白色
    searchBar.barTintColor = [UIColor whiteColor];
    // 边框颜色
    searchBar.backgroundColor = [UIColor whiteColor];
    UIView *searchTextView = [[[searchBar.subviews firstObject] subviews] lastObject];
    if (searchTextView) {
        searchTextView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    }
}
@end
