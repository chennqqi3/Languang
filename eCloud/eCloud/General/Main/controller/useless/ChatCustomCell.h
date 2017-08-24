

#import <UIKit/UIKit.h>

@interface ChatCustomCell : UITableViewCell{
	UILabel      *dateLabel;
    UILabel      *nameLabel;
    UILabel      *stateLabel;
}

@property (nonatomic, retain) IBOutlet UILabel      *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel      *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel      *stateLabel;

@end
