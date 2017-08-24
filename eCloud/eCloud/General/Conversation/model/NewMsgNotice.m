#import "NewMsgNotice.h"

@implementation NewMsgNotice
@synthesize msgType;
@synthesize msgId;
@synthesize convId;
@synthesize serviceId;
@synthesize serviceMsgId;
@synthesize appid;
@synthesize appMsgId;

-(void)dealloc
{
	self.msgId = nil;
	self.convId = nil;
	[super dealloc];
}
@end
