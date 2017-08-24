
#import "BgImageUtil.h"
#import "MessageView.h"

@implementation BgImageUtil

+ (UIImage *)getDateBgImage
{
    MessageView *messageView = [MessageView getMessageView];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
    UIImage *dateBgImage = [messageView resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]];
    return dateBgImage;
}

+ (UIImage *)getSndBubbleImage
{
    MessageView *messageView = [MessageView getMessageView];
    
    UIImage *bubble = [StringUtil getImageByResName:@"bubbleSelf.png"];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);
    UIImage *sndBubbleImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubble];
    return sndBubbleImage;
}

+ (UIImage *)getSndHighlightBubbleImage
{
    MessageView *messageView = [MessageView getMessageView];
    
    UIImage *bubbleHighlighted = [StringUtil getImageByResName:@"bubbleSelfDown.png"];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);
    UIImage *sndHighlightBubbleImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubbleHighlighted];
    return sndHighlightBubbleImage;
}

+ (UIImage *)getRcvBubbleImage
{
    MessageView *messageView = [MessageView getMessageView];
    
    UIImage *bubble = [StringUtil getImageByResName:@"bubble.png"];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);
    UIImage *rcvBubbleImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubble];
    
    return rcvBubbleImage;
}

+ (UIImage *)getRcvHighlightBubbleImage
{
    MessageView *messageView = [MessageView getMessageView];
    
    UIImage *bubbleHighlighted = [StringUtil getImageByResName:@"bubbleDown.png"];
    
    UIEdgeInsets capInsets = UIEdgeInsetsMake(30,22,9,22);
    UIImage *rcvHighlightBubbleImage = [messageView resizeImageWithCapInsets:capInsets andImage:bubbleHighlighted];
    return rcvHighlightBubbleImage;
}
@end
