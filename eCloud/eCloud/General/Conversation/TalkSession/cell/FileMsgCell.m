
#import "FileMsgCell.h"

@implementation FileMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
#pragma mark --文件类型消息--
        UIView *fileView = [[UIView alloc]initWithFrame:CGRectZero];
        fileView.tag = file_tag;
        
        //	文件对应的图片
        UIImageView *filePicView = [[UIImageView alloc]initWithFrame:CGRectZero];
        filePicView.contentMode=UIViewContentModeScaleAspectFit;
        filePicView.tag = file_pic_tag;
        [fileView addSubview:filePicView];
        [filePicView release];
        
        //	显示文件下载进度
        UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        progressLabel.backgroundColor = [UIColor clearColor];
        //	progressLabel.textColor = [UIColor whiteColor];
        progressLabel.textAlignment = UITextAlignmentCenter;
        progressLabel.tag = file_progress_tag;
        progressLabel.font = [UIFont systemFontOfSize:message_font];
        [filePicView addSubview:progressLabel];
        [progressLabel release];
        
        
        //	文件名称和大小，和分组通知的文字大小一致
        UILabel *fileNameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        fileNameLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        fileNameLabel.font = [UIFont systemFontOfSize:time_font_size];
        fileNameLabel.textColor = [UIColor whiteColor];
        fileNameLabel.textAlignment = UITextAlignmentCenter;
        //	CGFloat R  = (CGFloat) 0/255.0;
        //    CGFloat G = (CGFloat) 66/255.0;
        //    CGFloat B = (CGFloat) 88/255.0;
        //    CGFloat alpha = (CGFloat) 0.5;
        fileNameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        fileNameLabel.tag = file_name_tag;
        [fileView addSubview:fileNameLabel];
        [fileNameLabel release];
        
        [contentView addSubview:fileView];
        [fileView release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
