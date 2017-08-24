#import <UIKit/UIKit.h>
@class eCloud;
@interface modifyMailViewController : UIViewController<UITextFieldDelegate>
{
    //	会话id
    NSString* _emp_id;
    eCloud *_ecloud;
    UITextField *inputField;
    NSString *_oldMail;
    UILabel *titlelabel;
}
@property(nonatomic,retain) NSString *emp_id;
@property(nonatomic,retain) NSString *oldMail;
@end
