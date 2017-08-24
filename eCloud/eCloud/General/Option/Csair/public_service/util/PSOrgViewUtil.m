
// create by shisp
//在通讯录界面展示 公众服务号入口
#import "PSOrgViewUtil.h"
#import "StringUtil.h"
@implementation PSOrgViewUtil
+ (UITableViewCell *)pSTableViewCellWithReuseIdentifier:(NSString *)identifier
{
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	CGRect rect = CGRectMake(10, (ps_row_height - ps_logo_size) / 2, ps_logo_size,ps_logo_size);
	
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ps_logo" ofType:@"png"];	
	UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
	
	UIImageView *logoView = [[UIImageView alloc]initWithFrame:rect];
	logoView.image = image;
	[cell.contentView addSubview:logoView];
	[logoView release];
		
	rect = CGRectMake(logoView.frame.origin.x + ps_logo_size + 10,0, 200, ps_row_height);
	UILabel *label = [[UILabel alloc]initWithFrame:rect];
	label.font = [UIFont systemFontOfSize:ps_font_size];
	label.backgroundColor = [UIColor colorWithRed:12 green:12 blue:12 alpha:0];
	label.text = [StringUtil getLocalizableString:@"public_service"];
	[cell.contentView addSubview:label];
	[label release];
	
	return cell;
}

+(void)configurePsCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
 
}
+(UIView *)orgViewForHeaderInSection:(NSInteger)section
{
	if(section == 1)
	{
		UIView *_temp = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, org_header_view_height)]autorelease];
		_temp.backgroundColor = [UIColor lightGrayColor];

		UILabel *_label = [[UILabel alloc]initWithFrame:CGRectMake(10,0, 280, org_header_view_height)];
		_label.font = [UIFont systemFontOfSize:org_header_font_size];
		_label.text = [StringUtil getLocalizableString:@"org"];
		_label.backgroundColor = [UIColor clearColor];
		
		[_temp addSubview:_label];
		[_label release];
		return _temp;
	}
	return nil;
}

@end
