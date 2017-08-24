// 上传头像至文件服务器
//通知服务器头像修改

#import <Foundation/Foundation.h>

@interface EmpLogoUtil : NSObject

//新的头像
@property (nonatomic,retain) UIImage *logoImage;

+ (EmpLogoUtil *)getUtil;

//上传头像
- (void)uploadImage;

@end
