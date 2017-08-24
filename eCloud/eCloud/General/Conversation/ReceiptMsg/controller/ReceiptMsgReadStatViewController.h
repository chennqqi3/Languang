#import <UIKit/UIKit.h>

@class ConvRecord;

@interface ReceiptMsgReadStatViewController : UIViewController
{
    UILabel *blueLabel;
}

@property (retain) ConvRecord *convRecord;
@property(assign)int msgId;

@property(retain) NSArray *readItemArray;
@property(retain) NSArray *unReadItemArray;

@end
