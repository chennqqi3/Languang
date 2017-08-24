
#import <UIKit/UIKit.h>
@class ServiceModel;
@interface PSMsgDtlViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>{
    UIView *subfooterView;
    UIView *listMenu;
    UIButton *hideListMenuBtn;//切换菜单和输入框
    UIView *linebreakView;
    BOOL _hasListMenu; //是否有子菜单
    
    NSMutableArray *menuBtns;//自定义菜单数组
}

@property (nonatomic,retain) ServiceModel *serviceModel;

+(PSMsgDtlViewController*)getPSMsgDtlViewController;

//	要操作的indexPath
@property(retain)NSIndexPath *editIndexPath;
//	是否需要刷新界面
@property(assign) BOOL needRefresh;

@property(nonatomic)  BOOL hasListMenu; //是否有子菜单

@end
