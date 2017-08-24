//
//  MiLiaoConvListViewController.m
//  eCloud
//
//  Created by shisuping on 17/5/22.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "MiLiaoConvListViewController.h"
#import "Conversation.h"
#import "QueryResultCell.h"
#import "eCloudDAO.h"
#import "PSBackButtonUtil.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"
#import "ConvNotification.h"
#import "talkSessionViewController.h"
#import "contactViewController.h"
#import "NewChooseMemberViewController.h"
#import "OpenCtxDefine.h"
#import "talkSessionUtil2.h"
#import "conn.h"
#import "MiLiaoUtilArc.h"
#import "MiLiaoBeginViewControllerArc.h"
#import "LGRootChooseMemberViewController.h"

@interface MiLiaoConvListViewController () <UITableViewDelegate,UITableViewDataSource,ChooseMemberDelegate,MiLiaoBeginVCProtocol>

@property (nonatomic,retain) NSMutableArray *itemArray;
@property (nonatomic,retain) NSMutableDictionary *itemDic;

@end

@implementation MiLiaoConvListViewController{
    UITableView *tableView;
    UIView *beginView;
}

- (void)dealloc{
    self.itemArray = nil;
    self.itemDic = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processNewConvNotification:) name:NEW_CONVERSATION_NOTIFICATION object:nil];

    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStylePlain];
    
    [UIAdapterUtil setPropertyOfTableView:tableView];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = conv_row_height;
    
    [self.view addSubview:tableView];
    [tableView release];
    
    MiLiaoBeginViewControllerArc *temp = [[[MiLiaoBeginViewControllerArc alloc]initWithNibName:@"MiLiaoBeginViewControllerArc" bundle:nil]autorelease];
    temp.delegate = self;
    temp.view.frame = self.view.frame;
    [self.view addSubview:temp.view];
    [self addChildViewController:temp];
    beginView = temp.view;
    beginView.hidden = YES;
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:tableView];
    [UIAdapterUtil setExtraCellLineHidden:tableView];
    
    [self setLeftBtn];
    
    [self setRightBtn];
    
    self.title = [StringUtil getLocalizableString:@"key_encrypt_chat"];
    
    self.itemArray = [NSMutableArray arrayWithArray:[[eCloudDAO getDatabase]getRecentConversation:miliao_conv_type]];
    self.itemDic = [NSMutableDictionary dictionary];
    for (Conversation *_conv in self.itemArray) {
        [self.itemDic setValue:_conv forKey:_conv.conv_id];
    }
    
    [tableView reloadData];
}


#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    UIButton *backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    [tableView setEditing:NO];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark 添加右边按钮
- (void)setRightBtn
{
     UIButton *addButton = [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addMiLiaoConv)];
    [addButton setImage:[StringUtil getImageByResName:@"add_ios_hl"] forState:UIControlStateHighlighted];
}

- (void)addMiLiaoConv{
    
//    NewChooseMemberViewController *chooseMember = [[[NewChooseMemberViewController alloc]init]autorelease];
//    
//    chooseMember.typeTag = type_add_miliao_conv;
//    chooseMember.isSingleSelect = YES;
//    chooseMember.chooseMemberDelegate = self;
    
    LGRootChooseMemberViewController *vc = [[[LGRootChooseMemberViewController alloc]init]autorelease];
    vc.oldEmpIdArray = [NSArray arrayWithObject:[conn getConn].curUser];
    vc.chooseMemberDelegate = self;
    vc.maxSelectCount = 1;
    vc.isSingleSelect = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.itemArray.count == 0) {
        beginView.hidden = NO;
    }else{
        beginView.hidden = YES;
    }
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
        [cell initSubView];
    }
    cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
    
    Conversation *_conv = [self.itemArray objectAtIndex:indexPath.row];
    _conv.displayTime = NO;
    _conv.displayRcvMsgFlag = NO;
    //    [cell configSearchResultCell:_conv];
    [cell configCell:_conv];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.navigationController.topViewController isKindOfClass:[self class]]) {
        Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
        
        [contactViewController openConversation:conv andVC:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
        [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:conv.conv_id];
        
        [self.itemArray removeObject:conv];
        [self.itemDic removeObjectForKey:conv.conv_id];
        [self reloadData];
    }
}

#pragma mark === chooseMember Delegate====
- (void)didFinishSelectContacts:(NSArray *)userArray{
    Emp *_emp = nil;
    for (Emp *emp in userArray) {
        if (emp.emp_id != [conn getConn].curUser.emp_id) {
            _emp = emp;
            break;
        }
    }
    if (_emp) {
        
        NSString *convId = [[MiLiaoUtilArc getUtil]getMiLiaoConvIdWithEmpId:_emp.emp_id];
        [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:convId andTitle:_emp.emp_name];
        
        Conversation *conv = [[eCloudDAO getDatabase]getConversationByConvId:convId];
        
        for (Conversation *_conv in self.itemArray) {
            if ([_conv.conv_id isEqualToString:conv.conv_id]) {
                [contactViewController openConversation:_conv andVC:self];
                return;
            }
        }
        [self.itemArray insertObject:conv atIndex:0];
        [tableView reloadData];
        [contactViewController openConversation:conv andVC:self];
    }
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

#pragma mark ====处理会话通知=====

-(void)processNewConvNotification:(NSNotification *)notification
{
    eCloudNotification *_notification = [notification object];
    if(_notification != nil)
    {
        NSDictionary *dic = _notification.info;
        
        NSString *convId = [dic valueForKey:@"conv_id"];
        if (![[MiLiaoUtilArc getUtil]isMiLiaoConv:convId]) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 不是密聊消息不处理",__FUNCTION__]];
            return;
        }
        
        int cmdId = _notification.cmdId;
        switch (cmdId) {
            case other_user_read_encrypt_msg:
            {
//                需要刷新对应的会话
                [self reloadData];
            }
                break;
//            case update_rcv_msg_flag:
//            {
//                NSDictionary *dic = _notification.info;
//                NSString *convId = [dic valueForKey:@"conv_id"];
//                int rcvMsgFlag = [[dic valueForKey:@"rcv_msg_flag"]intValue];
//                Conversation *_conv = [self.itemDic valueForKey:convId];
//                if (_conv) {
//                    _conv.recv_flag = rcvMsgFlag;
//                    int index = [self.itemArray indexOfObject:_conv];
//                    [self reloadDataAtIndex:index];
//                }
//            }
//                break;
//            case user_logo_changed:
//            {
//                //                    需要处理下头像的刷新
//                [self refreshConvListLogo:_notification];
//            }
//                break;
                
            case add_new_conversation:
            case reuse_conversation:
            case add_new_conv_record:
            case delete_one_msg:
            {
//                NSDictionary *dic = _notification.info;
//                NSString *convId = [dic valueForKey:@"conv_id"];
                //                从数据库取出这个会话的信息
                Conversation *_conv = [[eCloudDAO getDatabase] getConversationByConvId:convId];
                
                if (_conv) {
                    
                    Conversation *tempConv = [self.itemDic objectForKey:convId];
                    if (tempConv) {
                        NSInteger _index = [self.itemArray indexOfObject:tempConv];
                        if (_index == NSNotFound) {
                            return;
                        }
                        else
                        {
                            [self.itemArray replaceObjectAtIndex:_index withObject:_conv];
                            [self.itemDic setObject:_conv forKey:convId];
                        }
                    }
                    else
                    {
                        [self.itemArray insertObject:_conv atIndex:0];
                        [self.itemDic setValue:_conv forKey:_conv.conv_id];
                    }
                    [self reloadData];
                }
                
            }
                break;
            case save_draft:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *convDraft= [dic valueForKey:@"conv_draft"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if ([_conv.lastInput_msg isEqualToString:convDraft] == YES) {
                        return;
                    }
                    _conv.lastInput_msg = convDraft;
                }
                else
                {
                    //                从数据库取出这个会话的信息
                    _conv = [[eCloudDAO getDatabase] getConversationByConvId:convId];
                    
                    if (_conv)
                    {
                        [self.itemArray insertObject:_conv atIndex:0];
                        [self.itemDic setObject:_conv forKey:convId];
                    }
                    
                }
                [self reloadData];
            }
                break;
            case save_last_msg_time:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                NSString *lastMsgTime= [dic valueForKey:@"last_msg_time"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    _conv.last_record.msg_time = lastMsgTime;
                    //                    self.itemArray = [NSMutableArray arrayWithArray:[self.itemArray sortedArrayUsingSelector:@selector(compareByLastMsgTime:)]];
                    [self reloadData];
                }
            }
                break;
            case read_one_msg:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.unread > 0) {
                        _conv.unread = _conv.unread - 1;
                        _conv.is_tip_me = NO;
                        [self reloadData];
                    }
                }
            }
                break;
            case read_all_msg:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.unread > 0) {
                        _conv.unread = 0;
                        _conv.is_tip_me = NO;
                        int index = [self.itemArray indexOfObject:_conv];
                        [self reloadDataAtIndex:index];
                    }
                }
            }
                break;
            case update_send_flag:
            {
                NSDictionary *dic = _notification.info;
                NSString *convId = [dic valueForKey:@"conv_id"];
                int sendFlag = [[dic valueForKey:@"send_flag"]intValue];
                int msgId = [[dic valueForKey:@"msg_id"]intValue];
                Conversation *_conv = [self.itemDic valueForKey:convId];
                if (_conv) {
                    if (_conv.last_msg_id == msgId && _conv.last_record.send_flag != sendFlag) {
                        _conv.last_record.send_flag = sendFlag;
                        int index = [self.itemArray indexOfObject:_conv];
                        [self reloadDataAtIndex:index];
                    }
                }
            }
                break;
//            case update_isSet_top:
//            {
//                NSDictionary *dic = _notification.info;
//                NSString *convId = [dic valueForKey:@"conv_id"];
//                int setTopFlag  = [[dic valueForKey:@"setTop_Flag"] integerValue];
//                Conversation *_conv = [self.itemDic valueForKey:convId];
//                _conv.isSetTop = setTopFlag;
//                [self reloadData];
//            }
//                break;
//            case update_broadcast_read_flag:
//            {
//                NSDictionary *dic = _notification.info;
//                NSString *convId = [dic valueForKey:@"conv_id"];
//                Conversation *_conv = [self.itemDic valueForKey:convId];
//                if (_conv) {
//                    _conv.unread = [[dic valueForKey:@"unread_msg_count"]intValue];
//                    int index = [self.itemArray indexOfObject:_conv];
//                    [self reloadDataAtIndex:index];
//                }
//            }
//                break;
            default:
                break;
        }
    }
}

- (void)reloadData{
    [tableView reloadData];
}

- (void)reloadDataAtIndex:(int)index
{
    if (index == NSNotFound) {
        [LogUtil debug:@"没有找到符合条件的行"];
        return;
    }
    if (index >=0 && index < self.itemArray.count) {
        int section = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:section];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self reloadData];
    }
}
#pragma mark =======MiLiaoBegin Protocol=======
- (void)startMiLiao{
    [self addMiLiaoConv];
}
@end
