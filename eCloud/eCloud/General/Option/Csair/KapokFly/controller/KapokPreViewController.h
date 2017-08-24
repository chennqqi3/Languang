//
//  HelpViewController.h
//  GrooveStik
//
//  Created by  lyong on 12-8-18.
//
//

#import <UIKit/UIKit.h>

@interface KapokPreViewController : UIViewController<UIScrollViewDelegate>
{
    UIScrollView *scrollview;
    UINavigationBar *navBar;
    UIPageControl *pageControl;
    UIButton *closebutton;
    NSArray *dataArray;
}
@property(nonatomic,retain)IBOutlet  UIScrollView *scrollview;
@property(nonatomic,retain)IBOutlet  UINavigationBar *navBar;
@property(nonatomic,retain)IBOutlet UIButton *closebutton;
@property(nonatomic,retain) NSArray *dataArray;
-(IBAction)closeAction:(id)sender;
@end
