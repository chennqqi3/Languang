
#import "QueryResultViewController.h"
#import "Conversation.h"
#import "QueryResultCell.h"
#import "QueryDAO.h"
#import "talkSessionViewController.h"
#import "eCloudDAO.h"
#import "PSBackButtonUtil.h"
#import "QueryResultHeaderCell.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"

@interface QueryResultViewController ()
@property (nonatomic,retain) NSMutableArray *itemArray;
@end

@implementation QueryResultViewController
{
    eCloudDAO *_ecloud;
    QueryDAO *queryDAO;
    UITableView *tableView;
}

@synthesize searchStr;
@synthesize conv;
@synthesize itemArray;

- (void)dealloc
{
    tableView = nil;
    self.searchStr = nil;
    self.conv = nil;
    self.itemArray = nil;
    
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _ecloud = [eCloudDAO getDatabase];
        queryDAO = [QueryDAO getDatabase];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStylePlain];
    [UIAdapterUtil setPropertyOfTableView:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = conv_row_height;
    
    [self.view addSubview:tableView];
    [tableView release];
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:tableView];
    [UIAdapterUtil setExtraCellLineHidden:tableView];

    [self setLeftBtn];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    NSString *_title = [StringUtil getAppLocalizableString:@"main_chats"];
	UIButton *backButton = [UIAdapterUtil setLeftButtonItemWithTitle:_title andTarget:self andSelector:@selector(backButtonPressed:)];
	[PSBackButtonUtil showNoReadNum:nil andButton:backButton andBtnTitle:_title];
}

-(void)backButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [self.conv getConvTitle];
    self.itemArray = [queryDAO getSearchResultsByConversation:self.conv andSearchStr:self.searchStr];
    [tableView reloadData];
}

#pragma mark tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return search_result_header_view_hight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    QueryResultHeaderCell *headerCell = [[[QueryResultHeaderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    NSString *tmp = [NSString stringWithFormat:[StringUtil getLocalizableString:@"records_num_of_match"],self.itemArray.count,self.searchStr];
    [headerCell configCell:tmp];
    return headerCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
        [cell initSubView];
    }
    cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
    
    Conversation *_conv = [self.itemArray objectAtIndex:indexPath.row];
    _conv.displayTime = YES;
    _conv.displayRcvMsgFlag = NO;
    _conv.specialStr = self.searchStr;
    [cell configSearchResultCell:_conv];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
    
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = conv.conv_type;
    talkSession.convId = conv.conv_id;
    talkSession.needUpdateTag = 1;
    talkSession.titleStr = [conv getConvTitle];
    talkSession.convEmps = [conv getConvEmps];
    talkSession.fromConv = conv;
    
    //    代表从会话查询结果来到会话界面的
    talkSession.fromType = talksession_from_conv_query_result_need_position;
    
    [self.navigationController pushViewController:talkSession animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect _frame = tableView.frame;
    if (_frame.size.width == SCREEN_WIDTH) {
        return;
    }
    
    _frame.size.width = SCREEN_WIDTH;
    _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    tableView.frame = _frame;
    
    [tableView reloadData];
    
}
@end
