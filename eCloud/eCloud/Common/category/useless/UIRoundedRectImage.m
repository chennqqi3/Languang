///*
//     设置头像圆角，并加上灰色边框
//     */
//   imgView.layer.masksToBounds=YES; 
//   imgView.layer.cornerRadius=10.0; 
//   imgView.layer.borderWidth=1.0;
//   imgView.layer.borderColor=[[UIColor grayColor] CGColor];

#import "UIRoundedRectImage.h"
#import "eCloudConfig.h"

@implementation UIImage(UIRoundedRectImage)
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
                                 float ovalHeight)
{
    float fw,fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


+ (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
{
    return image;
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    
	w = image.size.width;
	h = image.size.height;
	
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    // changed 0811 8 -> 60
    float ovalWidth = [eCloudConfig getConfig].userLogoRoundArc.floatValue * w;
    float ovalHeight = ovalWidth;
    addRoundedRectToPath(context, rect, ovalWidth , ovalHeight);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}
@end


