
#import "MassParentCell.h"
#import "eCloudDefine.h"

@implementation MassParentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews
{
    [super layoutSubviews];
	
    if (IOS7_OR_LATER)
    {
        self.contentView.frame = CGRectMake(
                                            10,
                                            self.contentView.frame.origin.y,
                                            self.frame.size.width - 20,
                                            self.contentView.frame.size.height
                                            );
    }
    
}
@end
