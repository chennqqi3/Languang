/*
 公众号入口显示工具类 deprecated
 */

#import <Foundation/Foundation.h>
//图片大小
#define ps_logo_size 30
//文字字体大小
#define ps_font_size 17
//文字显示宽度
#define ps_width 200

//行高度
#define ps_row_height 50

//headview字体大小

#define org_header_font_size 16
//headView高度
#define org_header_view_height 30

@interface PSOrgViewUtil : NSObject

//公众服务号显示界面
+ (UITableViewCell *)pSTableViewCellWithReuseIdentifier:(NSString *)identifier;
//
+(void)configurePsCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;

//组织架构标题View
+(UIView *)orgViewForHeaderInSection:(NSInteger)section;
@end
