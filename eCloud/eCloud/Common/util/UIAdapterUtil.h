//设置导航栏的颜色

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Emp;
@class contactViewController;

//国美表格分割线的颜色 e9e9e9
#define GOME_SEPERATE_COLOR [UIColor colorWithRed:0xE9/255.0 green:0xE9/255.0 blue:0xE9/255.0 alpha:1]
#define GOME_NAME_COLOR [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1]
#define GOME_TRA_NAME_COLOR [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:0.4]
#define GOME_BLUE_COLOR [UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:1]
#define GOME_TRA_BLUE_COLOR [UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:0.4]
#define GOME_BACKGROUND_COLOR [UIColor colorWithRed:0xf3/255.0 green:0xf3/255.0 blue:0xf3/255.0 alpha:1]
#define GOME_SUBTITLE_COLOR [UIColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1]

@interface UIAdapterUtil : NSObject

/**
 第三方图片选择界面 toolBar 颜色设置

 @param toolBar  要被赋值的颜色bar
 */
+ (void)customToolBar:(UIToolbar *)toolBar;

/**
 初始化自定义导航栏颜色
 */
+ (void)customNavigationBar;

/**
 初始化自定义搜索框颜色
 */
+ (void)customSearchBar;

/**
 设置自定义搜索框颜色
 */
+ (void)setSearchBarBackgroundColor:(UIColor *)color;

/**
 初始化自定义tabbar颜色
 */
+ (void)customTabBar;

/**
 获取searchBar的背景颜色

 @return serachbar的颜色
 */
+ (UIColor *)getSearchBarColor;

/**
 获取主色调颜色
 
 @return 主色调颜色
 */
+ (UIColor *)getDominantColor;

/**
 ios7下打开聊天界面，组织架构，选择某一个员工，打开聊天界面，查看用户详细资料，点击发送消息，打开聊天界面

 @param currentViewController 当前操作的控制器
 @param curEmp                当前的员工实体
 */
+ (void)openConversation:(UIViewController *)currentViewController andEmp:(Emp *)curEmp;

/**
 获取会话列表界面

 @param currentViewController 当前操作的界面控制器

 @return 会话列表控制器对象
 */
+ (contactViewController *)getContactViewController:(UIViewController *)currentViewController;

/**
 ios7防止导航栏遮挡显示视图

 @param currentController 当前操作控制器
 */
+ (void)processController:(UIViewController *)currentController;

/**
 清除cell的背景颜色，以及选中后的背景颜色

 @param cell 需要处理的cell对象
 */
+ (void)removeBackground:(UITableViewCell *)cell;

/**
 设置指定cell的背景颜色

 @param tableView tableview对象
 @param cell      指定的cell对象
 @param indexPath indexPath对象
 */
+ (void)customCellBackground:(UITableView *)tableView andCell:(UITableViewCell *)cell andIndexPath:(NSIndexPath *)indexPath;

/**
 调整switch控件的x值，因为ios7下面这个控件的宽度变小了

 @param _switch UISwitch对象
 @param cell    UISwitch对象所在的cell对象
 */
+ (void)positionSwitch:(UISwitch *)_switch ofCell:(UITableViewCell *)cell;

/**
 设置左边按钮，指定标题，指定target，指定action

 @param btnTitle          按钮标题
 @param currentController 当前操作控制器
 @param _sel              点击按钮要执行的方法

 @return 封装后的按钮对象
 */
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel;

/**
 设置左边按钮，指定标题，指定target，指定action
 
 @param btnTitle          按钮标题
 @param targetController  按钮事件实现控制器
 @param currCtrl          当前操作控制器
 @param _sel              点击按钮要执行的方法
 
 @return 封装后的按钮对象
 */
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)targetController andCurrCtrl:(UIViewController *)currCtrl andSelector:(SEL)_sel;


/**
 设置导航栏左侧按钮

 @param imageName 按钮图片名称
 @param currentController 按钮所在VC
 @param _sel 点击按钮事件
 @return 按钮本身
 */
+(UIButton *)setLeftButtonItemWithImageName:(NSString *)imageName andTarget:(UIViewController *)currentController andSelector:(SEL)_sel;


/**
 设置右边按钮，指定标题，指定target，指定action

 @param btnTitle          按钮标题
 @param currentController 当前操作控制器
 @param _sel              点击按钮要执行的方法

 @return 封装后的按钮对象
 */
+ (UIButton *)setRightButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel;

/**
 设置导航栏右边图片按钮

 @param imageName         图片名称
 @param currentController 当前操作控制器
 @param _sel              点击按钮要执行的方法

 @return 封装后的按钮对象
 */
+ (UIButton *)setRightButtonItemWithImageName:(NSString *)imageName andTarget:(UIViewController *)currentController andSelector:(SEL)_sel;

/**
 创建一个自定义标题和图片的按钮

 @param btnTitle 标题名称
 @param image    图片

 @return 按钮对象
 */
+(UIButton *)setNewButton:(NSString *)btnTitle andBackgroundImage:(UIImage *) image;

/**
 隐藏tabbar

 @param currentController 当前操作的控制器对象
 */
+ (void)hideTabBar:(UIViewController *)currentController;

/**
 显示tabbar

 @param currentController 当前操作的控制器对象
 */
+(void)showTabar:(UIViewController *)currentController;

/**
 显示会话列表界面

 @param currentController 当前操作的控制器对象
 */
+ (void)showChatPage:(UIViewController *)currentController;

/**
 设置当前控制器的背景颜色

 @param currentController 当前操作的控制器对象
 */
+ (void)setBackGroundColorOfController:(UIViewController *)currentController;

/**
 设置状态栏样式
 */
+ (void)setStatusBar;

/**
 去掉tableview最底部的横线

 @param tableView
 */
+(void)setExtraCellLineHidden: (UITableView *)tableView;

/**
 ios7下tableview cell的分割线偏右，左侧留空白，现在去掉这个空白

 @param _tableView
 */
+ (void)removeLeftSpaceOfTableViewCellSeperateLine:(UITableView *)_tableView;

/**
 ios7下表格 每行之间的分割线 和 头像对齐

 @param _tableView
 */
+ (void)alignHeadIconAndCellSeperateLine:(UITableView *)_tableView;

/**
 ios7下表格 每行之间的分割线 和 头像对齐
 
 @param _tableView
 */

+ (void)alignHeadIconAndCellSeperateLine:(UITableView *)_tableView withOriginX:(CGFloat)originx;


/**
 去掉系统searchbar下面的线

 @param _searchBar
 */
+ (void)removeBorderOfSearchBar:(UISearchBar *)_searchBar;

/**
 定制searchBar的cancel按钮

 @param currentController 当前操作的控制器
 */
+ (void)customCancelButton:(UIViewController *)currentController;

/**
 获取搜索框中的搜索内容的textfield组件

 @param currentController 当前操作的控制器

 @return 搜索内容所在的textfield组件
 */
+ (UITextField *)getSearchBarTextField:(UIViewController *)currentController;

/**
 获取屏幕宽度

 @return 屏幕宽度值
 */
+ (float)getTableCellContentWidth;

/**
 获取屏幕宽度
 
 @return 屏幕宽度值
 */
+ (float)getDeviceMainScreenWidth;

/**
 表格高度自适应

 @param curTable
 */
+ (void)autoSizeTable:(UITableView *)curTable;

/**
 聊天资料界面 聊天成员 名字 对应的字体颜色 灰色

 @return 颜色对象
 */
+ (UIColor *)getCustomGrayFontColor;

/**
 是否龙湖应用

 @return 是：为龙湖应用   否: 不是龙湖应用
 */
+ (BOOL)isHongHuApp;

/**
 是否南航应用
 
 @return 是：为南航应用   否: 不是南航应用
 */
+ (BOOL)isCsairApp;

/**
 是否国美应用
 
 @return 是：为国美应用   否: 不是国美应用
 */
+ (BOOL)isGOMEApp;

/**
 查看是否新华网
 
 @return 是：为新华网   否: 不是新华网
 */
+ (BOOL)isXINHUAApp;

/**
 是否泰禾应用
 
 @return 是：为泰禾应用   否: 不是泰禾应用
 */
+ (BOOL)isTAIHEApp;

/**
 是否蓝光应用
 
 @return 是：为泰禾应用   否: 不是泰禾应用
 */
+ (BOOL)isLANGUANGApp;

/**
 是否为融合版本
 
 @return 是：为融合版本   否: 不是融合版本
 */

+ (BOOL)isCombineApp;

/**
 显示菜单前 查看菜单是否是显示的状态，如果是 那么先将其关闭
 */
+ (void)dismissMenu;

/**
 在window的根控制器视图上弹出一个视图

 @param vc 即将弹出的视图
 */
+ (void)presentVC:(UIViewController *)vc;

/**
 设置 MLNavigationController 属性
 
 @param currentVC 即将弹出的视图
 */
+ (void)disableDragBackOfNavigationController:(UIViewController *)currentVC;

/**
 设置 MLNavigationController 属性
 
 @param currentVC 即将弹出的视图
 */
+ (void)enableDragBackOfNavigationController:(UIViewController *)currentVC;

/**
 是否为横屏
 
 @return 是：为横屏   否: 不是横屏
 */
+ (BOOL)isLandscap;

/**
 是否为竖屏
 
 @return 是：为竖屏   否: 不是竖屏
 */
+ (BOOL)isPortrait;

/**
 ios9和ios8 tableviewcell 显示不同，需要设置此属性

 @param curTableView
 */
+ (void)setPropertyOfTableView:(UITableView *)curTableView;

/**
 获取当前所在控制器对象

 @return 控制器对象
 */
+ (UIViewController *)getCurrentVC;

/**
 获取presentViewController当前控制器的上一个控制器对象
 
 @return 控制器对象
 */
+ (UIViewController *)getPresentedViewController;

/**
 设置导航栏左侧按钮

 @param btnTitle               按钮名称
 @param currentController      对应的控制器对象
 @param _sel                   按钮点击后触发的方法
 @param displayLeftButtonImage 按钮显示的图片

 @return 处理后的左侧按钮对象
 */
+ (UIButton *)setLeftButtonItemWithTitle:(NSString *)btnTitle andTarget:(UIViewController *)currentController andSelector:(SEL)_sel
               andDisplayLeftButtonImage:(BOOL)displayLeftButtonImage;

/**
 选中后cell的背景颜色

 @param cell
 */
+ (void)customSelectBackgroundOfCell:(UITableViewCell *)cell;

/**
 设置button的image和title之间有10像素的间隔

 @param button
 */
+ (void)customButtonStyle:(UIButton *)button;

/**
 (已废弃)
 新建一个view添加到导航栏上
 
 @param navController 导航栏控制器
 */
+(void)setStatusBarColor:(UINavigationController *)navController;

/**
 (已废弃)
 选择人员界面
 
 @param navigationBar 导航栏的bar对象
 */
+ (void)customLightNavigationBar:(UINavigationBar *)navigationBar;

/**
 (已废弃)
 设置搜索框的颜色
 
 @param searchBar 需要赋值颜色的searchbar对象
 @param color     颜色的值
 */
+ (void)setSearchBar:(UISearchBar *)searchBar withColor:(UIColor *)color;


/**
 是否为华夏幸福
 
 @return 是：华夏幸福   否: 华夏幸福
 */
+ (BOOL)isHXXFApp;

/**
 //查看是否碧桂园
 
 @return 是：碧桂园   否: 碧桂园
 */
+ (BOOL)isBGYApp;

/**
 是否为祥源
 
 @return 是：   否:
 */
+ (BOOL)isXIANGYUANApp;

/**
 设置view圆角属性

 @param view
 */
+ (void)setCornerPropertyOfView:(UIView *)view;

/**
 设置搜索背景界面不透明，便于显示提示文字
 
 @param controller 搜索控制器
 */
+ (void)addTipsViewWithView:(UISearchDisplayController*)controller;

/**
  添加展示左边侧边栏的按钮
 @param VC 要添加左边按钮的控制器
 */
+ (void)setupLeftIconItem:(UIViewController *)VC;

#pragma mark - 搜索提示
+ (void)setSearchResultsTitle:(NSString *)title andCurVC:(UIViewController *)curVC;

// 更改左侧返回按钮的文字标题
+ (void)changeLeftButtonTitle:(NSArray<UIBarButtonItem *> *)leftBarButtonItems andTarget:(UIViewController *)currentController;

/**
 设置搜索框的外框颜色与内部文本框的背景颜色

 @param searchBar 搜索bar对象
 */
+ (void)setSearchColorForTextBarAndBackground:(UISearchBar *)searchBar;
@end
