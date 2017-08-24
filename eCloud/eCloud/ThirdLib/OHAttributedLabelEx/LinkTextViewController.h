/*
 * @brief 测试OHAttributedLabelEx的viewController.
 */

#import <UIKit/UIKit.h>

@interface LinkTextViewController : UIViewController
{
    NSString *textstr;
    float textWidth;
}
@property(nonatomic, retain)  NSString *textstr;
@property (assign) float textWidth;
@end
