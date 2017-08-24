//
//  ImageUtil.m
//  eCloud
//
//  Created by robert on 13-1-14.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ImageUtil.h"
#import "UserDisplayUtil.h"
#import "conn.h"
#import "ImageSet.h"
#import "UIRoundedRectImage.h"
#import "StringUtil.h"
#import "PermissionModel.h"
#import "StringUtil.h"
#import "UserInterfaceUtil.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif
@implementation ImageUtil

+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;   //返回的就是已经改变的图片
}

+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    //   如果使用原来方式缩小图片尺寸有问题，那么使用新的方法
    UIImage *_image = [self resizeImage:source withWidth:size.width withHeight:size.height];
    if (!_image) {
        return source;
    }
    return _image;
    
//    CGImageRef cgImage  = [self newScaledImage:source.CGImage withOrientation:source.imageOrientation toSize:size withQuality:quality];
//    if (cgImage == nil) {
//        return source;
//    }
//    
//    UIImage * result = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
//    CGImageRelease(cgImage);
//    return result;
}

//新的修改图片尺寸的方法
+ (UIImage*)resizeImage:(UIImage*)image withWidth:(CGFloat)width withHeight:(CGFloat)height
{
    CGSize newSize = CGSizeMake(width, height);
//    CGFloat widthRatio = newSize.width/image.size.width;
//    CGFloat heightRatio = newSize.height/image.size.height;
//    
//    if(widthRatio > heightRatio)
//    {
//        newSize=CGSizeMake(image.size.width*heightRatio,image.size.height*heightRatio);
//    }
//    else
//    {
//        newSize=CGSizeMake(image.size.width*widthRatio,image.size.height*widthRatio);
//    }
    
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGSize(newImage.size));
    
    return newImage;
}

+ (UIImage*)imageProcess:(UIImage*)image
{
    //第一步：确定图片的宽高
    /*
     两种方案
     1 image.size.width
     2 GImageGetWidth(<#CGImageRef  _Nullable image#>)
     
     */
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //第二步：创建颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    //第三部：创建图片上下文(解析图片信息，绘制图片)
    /*
     开辟内存空间，这块空间用于处理马赛克图片
     参数1：数据源
     参数2：图片宽
     参数3：图片高
     参数4：表示每一个像素点，每一个分量大小
     在我们图像学中，像素点：ARGB组成 每一个表示一个分量（例如，A，R，G，B）
     在我们计算机图像学中每一个分量的大小是8个字节
     参数5：每一行大小（其实图片是由像素数组组成的）
     如何计算每一行的大小，所占用的内存
     首先计算每一个像素点大小（我们取最大值）： ARGB是4个分量 = 每个分量8个字节 * 4
     参数6:颜色空间
     参数7:是否需要透明度
     
     */
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, width*4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    
    //第四步：根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    //第五步：获取图片的像素数组
    unsigned char * bitMapData = CGBitmapContextGetData(contextRef);
    
    //第六步：图片打码，加入马赛克
    /*
     核心算法
     马赛克：将图片模糊，（马赛克算法可以是可逆，也可以是不可逆，取决于打码的算法）
     对图片进行采样
     
     我们今天处理的原理：让一个像素点替换为和它相同的矩形区域（正方形，圆形都可以）
     矩形区域包含了N个像素点
     
     */
    
    //选择马赛克区域
    //矩形区域：认为是打码的级别，马赛克点的大小（失真的强度）
    //这里将级别写死了level
    //level 马赛克点的大小
    NSUInteger currentIndex , preCurrentIndex, level = width/4;
    //像素点默认是4个通道,默认值是0
    unsigned char * pixels[4] = {0};
    for (NSUInteger i = 0; i < height - 1; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            //循环便利每一个像素点，然后筛选，打码
            //获取当前像素点坐标-》指针位移方式处理像素点-》修改
            //指针位移
            currentIndex = (i * width) + j ;
            //计算矩形的区域
            
            
            //通过这个算法，截取了一个3*3的一个矩形
            
            if (i % level==0) {
                if (j % level==0) {
                    //拷贝区域 c语言拷贝数据的函数
                    /*
                     参数1:拷贝目标（像素点）
                     参数2:源文件
                     参数3:要截取的长度（字节计算）
                     */
                    memcpy(pixels, bitMapData+4*currentIndex, 4);
                    
                }else{
                    //将上一个像素点的值赋值给第二个（指针位移的方式计算原理）
                    memcpy(bitMapData+4*currentIndex, pixels, 4);
                }
                
            }else{
                /*
                 例如：i=1  j=0
                 preCurrentIndex = (i - 1) * width + j;
                 */
                preCurrentIndex = (i - 1) * width + j;
                memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
            }
            
            
        }
    }
    
    //第七步：获取图片数据集合
    NSUInteger size = width * height * 4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitMapData, size, NULL);
    //第八部：创建马赛克图片
    /*
     参数1:宽
     参数2:高
     参数3:表示每一个像素点，每一个分量的大小
     参数4:每一个像素点的大小
     参数5:每一行内存大小
     参数6:颜色空间
     参数7:位图信息
     参数8:数据源（数据集合）
     参数9:数据解码器
     参数10:是否抗锯齿
     参数11:渲染器
     */
    CGImageRef mossicImageRef = CGImageCreate(width,
                                              height,
                                              8,
                                              4*8,
                                              width*4,
                                              colorSpaceRef,kCGImageAlphaPremultipliedLast,
                                              providerRef,
                                              NULL,
                                              NO,
                                              kCGRenderingIntentDefault);
    
    //第九步：创建输出马赛克图片（填充颜色）
    CGContextRef outContextRef = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       8,
                                                       width*4,
                                                       colorSpaceRef,
                                                       kCGImageAlphaPremultipliedLast);
    //绘制图片
    CGContextDrawImage(outContextRef, CGRectMake(0, 0, width, height),mossicImageRef);
    
    //创建图片
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outContextRef);
    UIImage *outImage = [UIImage imageWithCGImage:resultImageRef];
    
    
    
    //释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(mossicImageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);
    CGContextRelease(outContextRef);
    
    
    
    return outImage;
}

+ (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 CGImageGetBitsPerComponent(source), //CGImageGetBitsPerComponent(source),
                                                 size.width * 4,
                                                 CGImageGetColorSpace(source),
												 (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst)
                                                 );//kCGImageAlphaPremultipliedLast
	
    
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}
#pragma mark 获取用户头像
+(UIImage*)getLogo:(Emp*)emp
{
 	NSString *empLogo = emp.emp_logo;
	NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
	UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
	if (image)
	{
//            image=[UIImage createRoundedRectImage:image size:CGSizeZero];
	}
    else
    {
//        NSLog(@"获取某个联系人的头像时，发现头像不存在，启动下载");
        [StringUtil downloadUserLogo:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo andNeedSaveUrl:false];
    }
	return image;
}

#pragma mark 用户头像是否存在
+ (UIImage *)getEmpLogoWithoutDownload:(Emp *)emp
{
    UIImage *image = nil;
    NSString *empLogo = emp.emp_logo;
	NSString *logoPath = [StringUtil getMicroLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
    if ([[NSFileManager defaultManager]fileExistsAtPath:logoPath]) {
        image = [UIImage imageWithContentsOfFile:logoPath];
    }
    else
    {
        logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
        if ([[NSFileManager defaultManager]fileExistsAtPath:logoPath]) {
            image = [UIImage imageWithContentsOfFile:logoPath];
        }
    }
    if (image) {
//        image = [UIImage createRoundedRectImage:image size:CGSizeZero];
    }
	return image;
}

#pragma mark 获取默认的头像
+(UIImage*)getDefaultLogo:(Emp*)emp
{
//    如果使用用户名字作为用户头像，那么就不返回默认头像
    if ([eCloudConfig getConfig].useNameAsLogo) {
        NSDictionary *dic = [UserDisplayUtil getUserDefinedChatMessageLogoDicOfEmp:emp];
        UIImage *image = [ImageUtil createUserDefinedLogo:dic];
        if (image) {
            return image;
        }
        
        return default_logo_image;
    }
    
	UIImage *image = nil;
    
    if (emp.permission.hideState) {
        image = [StringUtil getImageByResName:@"offline.png"];
        return image;
    }
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    /** 华夏和正荣 取到人员的头像后，不保存在本地，取到就要，没取到就不用 */
    image = [[HuaXiaOrgUtil getUtil]getHXEmpLogoByEmpId:emp.emp_id withUserInfo:nil withCompleteHandler:nil];
    if (image) {
        return image;
    }
#endif

    //	conn *_conn = [conn getConn];
    //	if(_conn.userStatus == status_online)
    //	{
//    if(emp.emp_status==status_online || emp.emp_status == status_leave)
//    {//在线
        if (emp.emp_sex==0)
        {//女
            image=[StringUtil getImageByResName:@"female.png"];
        }
        else
        {
            image=[StringUtil getImageByResName:@"male.png"];
        }
//    }
    //		else if(emp.emp_status==status_leave)//离开
    //		{
    //			if (emp.emp_sex==0)
    //			{//女
    //				image=[UIImage imageNamed:@"female_leave.png"];
    //			}else
    //			{
    //				image=[UIImage imageNamed:@"male_leave.png"];
    //			}
    //		}
//    else//离线，或离开
//    {
//        image = [UIImage imageNamed:@"offline.png"];
//    }
    //	}
    //	else
    //	{
    //		image=[UIImage imageNamed:@"offline.png"];
    //	}
	return image;
}

#pragma mark 获取默认的头像
+(UIImage*)getDefaultMiLiaoLogo:(Emp*)emp
{
    UIImage *image;
    
    if (emp.emp_sex==0)
    {//女
        image=[StringUtil getImageByResName:@"female_encrypt.png"];
    }
    else
    {
        image=[StringUtil getImageByResName:@"male_encrypt.png"];
    }
        return image;
}


#pragma mark 第二个获取头像方法，如果没有就返回默认
+(UIImage *)getEmpLogo:(Emp*)emp
{
	UIImage *image = nil;
	NSString *empLogo = emp.emp_logo;
	if(empLogo.length > 0)
	{
		image = [self getLogo:emp];
	}
	if(image == nil)
	{
		image = [self getDefaultLogo:emp];
	}
	return image;
}

#pragma mark =========展示用户头像的时候不判断用户状态========

+(UIImage*)getOnlineLogo:(Emp*)emp
{
    //	conn *_conn = [conn getConn];
	
	NSString *empLogo = emp.emp_logo;
	NSString *logoPath = [StringUtil getLogoFilePathBy:[StringUtil getStringValue:emp.emp_id] andLogo:empLogo];
	UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
	if (image)
	{
//        image=[UIImage createRoundedRectImage:image size:CGSizeZero];
    }
	return image;
}
#pragma mark 获取默认的头像
+(UIImage*)getDefaultOnlineLogo:(Emp*)emp
{
    if ([eCloudConfig getConfig].useNameAsLogo) {
        
        NSDictionary *dic = [UserDisplayUtil getUserDefinedChatMessageLogoDicOfEmp:emp];
        UIImage *image = [ImageUtil createUserDefinedLogo:dic];
        if (image) {
            return image;
        }
        
        return default_logo_image;
    }
	UIImage *image;
  
    if (emp.emp_sex==0)
    {//女
        image=[StringUtil getImageByResName:@"female.png"];
    }
    else
    {
        image=[StringUtil getImageByResName:@"male.png"];
    }
    
	return image;
}

#pragma mark 第二个获取头像方法，如果没有就返回默认
+(UIImage *)getOnlineEmpLogo:(Emp*)emp
{
	UIImage *image = nil;
	NSString *empLogo = emp.emp_logo;
	if(empLogo.length > 0)
	{
		image = [self getOnlineLogo:emp];
	}
	if(image == nil)
	{
		image = [self getDefaultOnlineLogo:emp];
	}
	return image;
}

+ (UIImage *)getNoAlarmImage:(int)type
{
    if(type == 0)
    {
        UIImage *image = [StringUtil getImageByResName:@"no_alarm_gray.png"];
        return image;
    }
    else if(type == 1)
    {
        UIImage *image = [StringUtil getImageByResName:@"ic_actbar_chat_no_alarm.png"];
        return image;        
    }
    return nil;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)createUserDefinedLogo:(NSDictionary *)logoDic{
    
    int scale = 3;
    
    NSNumber *tempNumber;
    UIColor *tempColor;
    
    //    logo 尺寸
    float logoSize = 50.0 * scale;
    
    tempNumber = logoDic[KEY_USER_DEFINE_LOGO_SIZE];
    if (tempNumber) {
        logoSize = [tempNumber floatValue] * scale;
    }
    
    //    logo 文本
    NSString *logoText = logoDic[KEY_USER_DEFINE_LOGO_TEXT];
    
    //    logo 文本字体大小
    UIFont *textFont = [UIFont boldSystemFontOfSize:13.0 * scale];
    tempNumber = logoDic[KEY_USER_DEFINE_LOGO_TEXT_SIZE];
    if (tempNumber) {
        textFont = [UIFont systemFontOfSize:tempNumber.floatValue * scale];// [UIFont boldSystemFontOfSize:tempNumber.floatValue * scale];
    }
    //    logo文本颜色
    UIColor *logoTextColor = [UIColor whiteColor];
    tempColor = logoDic[KEY_USER_DEFINE_LOGO_TEXT_COLOR];
    if (tempColor) {
        logoTextColor = tempColor;
    }
    
    CGSize textSize = [logoText sizeWithAttributes:@{NSFontAttributeName:textFont}];
    
    if (textSize.width > logoSize) {
        logoSize = textSize.width;
    }
    
    float textX = (logoSize - textSize.width) * 0.5;
    float textY = (logoSize - textSize.height) * 0.5;

    
    CGRect rect = CGRectMake(0.0f, 0.0f, logoSize, logoSize);
    
    UIGraphicsBeginImageContext(rect.size); //在这个范围内开启一段上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    logo 背景颜色
    UIColor *logoBGColor = [UIColor blueColor];
    tempColor = logoDic[KEY_USER_DEFINE_LOGO_BG_COLOR];
    if (tempColor) {
        logoBGColor = tempColor;
    }
    
    CGContextSetFillColorWithColor(context, [logoBGColor CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    [logoText drawAtPoint:CGPointMake(textX,textY) withAttributes:@{NSFontAttributeName:textFont,NSForegroundColorAttributeName:logoTextColor}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
