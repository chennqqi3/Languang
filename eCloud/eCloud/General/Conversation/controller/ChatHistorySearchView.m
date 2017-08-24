
//
//  ViewController.m
//  eCloud
//
//  Created by SH on 14-12-30.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "ChatHistorySearchView.h"
#import "chatMessageViewController.h"
#import "UIAdapterUtil.h"
#import "VideoMsgCell.h"
#import "Conversation.h"

#ifdef _XINHUA_FLAG_
#import "SystemMsgModelArc.h"
#import "RobotDisplayUtil.h"
#import "NewsCellARC.h"
#endif

#import "chathistoryView.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "ConvRecord.h"
#import "talkSessionUtil.h"
#import "talkSessionUtil2.h"
#import "LinkTextMsgCell.h"
#import "FaceTextMsgCell.h"
#import "AudioMsgCell.h"
#import "PicMsgCell.h"
#import "NewFileMsgCell.h"
#import "GroupInfoMsgCell.h"
#import "NormalTextMsgCell.h"
#import "LCLLoadingView.h"
#import "ConvRecord.h"
#import "chatRecordCell.h"
#import "QueryDAO.h"
#import "LastRecordView.h"
#import "UserTipsUtil.h"
#ifdef _LANGUANG_FLAG_

#import "RedpacketConfig.h"
#import "JSONKit.h"
#import "LGNewsCellARC.h"
#import "WXReplyToOneMsgCellTableViewCellArc.h"
#import "LocationMsgCell.h"
#endif

@class talkSessionViewController;

@interface ChatHistorySearchView () 
{
    UITableView *chatHistoryTable;
    eCloudDAO *_ecloud ;
    QueryDAO *query;
    int totalCount;
    int limit;
    int offset;
    int tableRowOffset;
    bool isLoading;
    int loadCount;
    CGSize tempCellSize;
    CGSize cellSize;
    
    UIActivityIndicatorView *loadingIndic;
    
    UISearchBar *_searchBar;
    
    UITextField *searchTextView;
    
    UISearchDisplayController *searchDisplayController;
    
}

@property(nonatomic,retain) NSMutableArray *convRecordArray;
@property(nonatomic,retain) NSMutableArray *searchResults;
@property(nonatomic,retain) UIView *hideView;

@property (nonatomic,retain) NSString *searchStr;
@end


@implementation ChatHistorySearchView

@synthesize searchStr;

-(void)dealloc
{
    self.searchStr = nil;
    
    self.convId = nil;
    searchDisplayController = nil;
    
    [self.convRecordArray removeAllObjects];
    self.convRecordArray = nil;
    
    self.searchResults = nil;
    
    self.hideView = nil;

    searchDisplayController = nil;
    
    [super dealloc];
    NSLog(@"chatHistorySearch dealloc");
}

-(void)initBackground
{
    
    UIImageView *chatHistoryBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height)];
    chatHistoryBackground.clipsToBounds = YES;
    chatHistoryBackground.contentMode = UIViewContentModeScaleAspectFill;
    
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    BOOL is_change=[accountDefaults objectForKey:@"is_chat_backgroud_change"];
    if (is_change) {
//        [accountDefaults setBool:NO forKey:@"is_chat_backgroud_change"];
        //存入本地
        NSString *one_chat_imagename=[NSString stringWithFormat:@"%@.jpg",self.convId];
        NSString *picpath_1 = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:one_chat_imagename];
        NSData *data=[NSData dataWithContentsOfFile:picpath_1];
        UIImage* backgroud_image;
        if (data==nil) {
            picpath_1 = [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:@"ChatBackground_1.jpg"];
            
            data=[NSData dataWithContentsOfFile:picpath_1];
            if (data==nil) {
                backgroud_image =[UIImage imageNamed:@"ChatBackground_2.jpg"];
            }else{
                backgroud_image=[UIImage imageWithData:data];
            }
        }else{
            backgroud_image=[UIImage imageWithData:data];
        }
        
        chatHistoryBackground.image =  backgroud_image;
    }
    
    [self.view addSubview:chatHistoryBackground];
    [chatHistoryBackground release];
    
}

- (void)initTitle
{
    self.navigationItem.titleView = nil;
    //add by ly 2014-02-11 群组显示在线人数，总人数
    if (self.talkType == mutiableType) {
        int all_num= [_ecloud getAllConvEmpNumByConvId:self.convId];
        
        
        UIColor *_color = [UIColor colorWithRed:40/255.0 green:83/255.0 blue:142/255.0 alpha:1];
        
        UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(-13, 0, 160, 44)];
        
        NSString *tempString = [NSString stringWithFormat:@"%@(%d)",self.convName,all_num];
        
        NSUInteger len = [self lenghtWithString:self.convName];
        
        int finalLocation = 0;
        if (len>8)
        {
            int tempInter = 0;
            
            for (int i =0; i<tempString.length; i++)
            {
                NSString *tempChar = [tempString substringWithRange:NSMakeRange(i, 1)];
                int tempLen = [self lenghtWithString:tempChar];
                tempInter = tempInter +tempLen;
                if (tempInter >8) {
                    finalLocation = i;
                    break;
                }
            }
        }
        
        if(finalLocation>3)
        {
            tempString = [NSString stringWithFormat:@"%@...(%d)",[tempString substringToIndex:finalLocation],all_num];
        }
        
        strLabel.text = tempString;
        strLabel.textColor = [UIColor whiteColor];
        strLabel.font = [UIFont boldSystemFontOfSize:20.0];
        strLabel.textAlignment = UITextAlignmentCenter;
        strLabel.backgroundColor = _color;
        
        UIView *groupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0 , 0, 120,44)];
        [groupTitleView addSubview:strLabel];
        [strLabel release];
        
        self.navigationItem.titleView = groupTitleView;
        
        [groupTitleView release];
        
    }
    else
    {
        self.title=self.convName;
    }
}

-(NSUInteger) lenghtWithString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString * pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    //    NSLog(@"%s,%d",__FUNCTION__,numMatch);
    //字符算一个 汉字算两个
    return len +   numMatch;
}

-(void)initNavigationButton{
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getAppLocalizableString:@"main_chats"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    NSString * rightBtnImageName = nil;
    if (self.talkType == singleType) {
        rightBtnImageName = @"SingleMember";
    }else
    {
        rightBtnImageName = @"GroupMember";
    }
    [UIAdapterUtil setRightButtonItemWithImageName:rightBtnImageName andTarget:self andSelector:@selector(rightButtonPress:)];
}
-(void)initSearchBar
{
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    
    _searchBar.delegate = self;
    [UIAdapterUtil removeBorderOfSearchBar:_searchBar];
    [self.view addSubview:_searchBar];
    [_searchBar release];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    [UIAdapterUtil setExtraCellLineHidden:searchDisplayController.searchResultsTableView];
    [UIAdapterUtil setPropertyOfTableView:searchDisplayController.searchResultsTableView];
    self.searchResults = [NSMutableArray array];
    [searchDisplayController setActive:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ecloud = [eCloudDAO getDatabase];
    query = [QueryDAO getDatabase];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [self initBackground];
    
    [self initTitle];
    
    [self initNavigationButton];
    
    chatHistoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-95.0) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:chatHistoryTable];
    
    chatHistoryTable.backgroundView = nil;
    chatHistoryTable.backgroundColor = [UIColor clearColor];
    chatHistoryTable.dataSource = self;
    chatHistoryTable.delegate = self;
    [self.view addSubview:chatHistoryTable];
    [chatHistoryTable release];
    
    
//    [self getRecordsByConvId];
    
    self.hideView =  [[UIView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.hideView.backgroundColor = [UIColor clearColor];
    
    [self initSearchBar];
    
    //	update by shisp 加载历史记录提示框放到表格的第一行
    loadingIndic =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingIndic.frame=CGRectMake(145,5, 30.0f,30.0f);
    
    loadingIndic.hidden = YES;
    isLoading = false;
    
}




-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    return self.convRecordArray.count+1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        NSString *text = [self.searchResults [indexPath.row] valueForKey:@"msg_body"];
//        [self configCellSize:text];
//        return tempCellSize.height;
        return row_height;
    }
    else{
        //	//	update by shisp	  第一行显示加载提示框
        if(indexPath.row == 0)
            return 40;
        
        int row = [indexPath row] - 1;
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:row];
        
        float cellHeight = [talkSessionUtil getMsgBodyHeight:_convRecord];
        
        //    if(tableRowOffset > 0 && row < tableRowOffset)
        //    {
        //        tableContentOffset += cellHeight;
        //    }
        
        //    如果下一条消息需要显示时间，那么就增加多一些，否则少一些
        if (row == (self.convRecordArray.count - 1)) {
            cellHeight = cellHeight + msg_to_msg_space_of_same_time;
        }else{
            _convRecord = self.convRecordArray[row + 1];
            if (_convRecord.isTimeDisplay) {
                cellHeight = cellHeight + msg_to_msg_space_of_diff_time;
            }else{
                cellHeight = cellHeight + msg_to_msg_space_of_same_time;
            }
        }
        
        return cellHeight ;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"%s, section is %d , row is %d , count is %d ",__FUNCTION__,indexPath.section,indexPath.row,self.convRecordArray.count);
    //    update by shisp
        //    因为和普通的聊天界面同用一个类，所以如果是普通的聊天界面，则不显示背景，也不需要添加定制其他的背景
   
    [self removeBackground:cell];
    
}

//不显示默认的背景
- (void)removeBackground:(UITableViewCell *)cell
{
    [UIAdapterUtil removeBackground:cell];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        static NSString *searchChatCellID = @"searchDeptCellID";
        
        chatRecordCell *recordCell = [tableView dequeueReusableCellWithIdentifier:searchChatCellID];
        if(recordCell == nil)
        {
            recordCell = [[[chatRecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchChatCellID]autorelease ];
        }
        
        LastRecordView *tempView = [recordCell viewWithTag:text_tag];
        tempView.specialStr = _searchBar.text;
        [recordCell configCellWithConvRecord:self.searchResults[indexPath.row]];
        
        [recordCell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        [UIAdapterUtil alignHeadIconAndCellSeperateLine:tableView];
        return  recordCell;

    }
    else{
     tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //		add by shisp第一行显示为加载提示框
    if( indexPath.row == 0)
    {
        UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
        [cell addSubview:loadingIndic];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    {
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:indexPath.row - 1];
        UITableViewCell *cell = [self getMsgCell:tableView andRecord:_convRecord];// nil;
#ifdef _LANGUANG_FLAG_
    
        if (_convRecord.redPacketModel){
            
            static NSString *redPacketCellID = @"redPacketMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:redPacketCellID];
            if (cell == nil) {
                
                NSData* jsonData = [_convRecord.msg_body dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *resultDict = [jsonData objectFromJSONData];
                cell = [[RedpacketConfig sharedConfig] cellForRedpacketMessageDict:resultDict];
                
            }
        }else if (_convRecord.newsModel){
            
            static NSString *newMsgCellID = @"newMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:newMsgCellID];
            if (cell == nil) {
                LGNewsCellARC *NewCell = [[[LGNewsCellARC alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newMsgCellID]autorelease];
                
                [NewCell configCellWithDataModel:_convRecord.newsModel];
                cell = NewCell;
            
            }
        }
        else if (_convRecord.replyOneMsgModel){
            static NSString *replyToOneMsgCellID = @"replyToOneMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:replyToOneMsgCellID];
            if (cell == nil) {
                cell = [[[WXReplyToOneMsgCellTableViewCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyToOneMsgCellID]autorelease];
            
            }
        }
        else if (_convRecord.locationModel) {
            //                证明是位置信息
            LocationMsgCell *locationCell = [[[LocationMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
//            [self addCommonGesture:locationCell];
            cell = locationCell;
        }
        
#endif
        [talkSessionUtil configureCell:cell andConvRecord:_convRecord];
        
        //	状态按钮
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
        UIImageView *failButton = (UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
        
        //		如果是发送的消息，并且发送状态是上传成功后发送中或上传中，那么显示正在发送
        if(_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading))
        {
            spinner.hidden = NO;
            [spinner startAnimating];
        }
        else
        {
            [spinner stopAnimating];
        }
        
        //		如果是发送的消息，并且发送状态是上传失败，那么显示发送失败按钮，点击后可以重新发送
        if(_convRecord.msg_flag == send_msg && _convRecord.send_flag == send_upload_fail)
        {
            //			发送失败
            failButton.hidden=NO;
        }
        else
        {
            failButton.hidden = YES;
        }
        
        //	消息内容
        switch(_convRecord.msg_type)
        {
            case type_file:
            {
                if(!_convRecord.isFileExists)
                {
                    //下载文件
                    if(_convRecord.isDownLoading)
                    {
                        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                        if(_convRecord.downloadRequest)
                        {
                            [_convRecord.downloadRequest setDownloadProgressDelegate:_progressView];
                        }
                    }
                }
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        UIProgressView *_progressView = [cell.contentView  viewWithTag:file_progressview_tag];
                        [talkSessionUtil displayProgressView:_progressView];
                    }
                }
                
                [talkSessionUtil configureFileDownOrUpLoadSateLabelCell:cell convRecord:_convRecord];
            }
                break;
            case type_pic:
            {
                if(!_convRecord.isBigPicExist)
                {
                    if(!_convRecord.isSmallPicExist)
                    {
                        if(!_convRecord.isDownLoading)
                        {
                            _convRecord.isDownLoading = true;
//                            [self autoDownloadSmallPic:cell andConvRecord:_convRecord];
                        }
                        else
                        {
                            [spinner startAnimating];
                        }
                    }
                    else
                    {
                        UIProgressView *progressview=(UIProgressView *)[cell.contentView viewWithTag:pic_progress_tag];
                        if(_convRecord.isDownLoading)
                        {
                            [talkSessionUtil displayProgressView:progressview];
                            if(_convRecord.downloadRequest)
                            {
                                [_convRecord.downloadRequest setDownloadProgressDelegate:progressview];
                            }
                        }
                    }
                }
                else{
                    if (_convRecord.msg_flag == send_msg && (_convRecord.send_flag == sending || _convRecord.send_flag == send_uploading)) {
                        UILabel *_progressView = [cell.contentView  viewWithTag:pic_progress_Label_tag];
                        _progressView.hidden = NO;
                    }
                }
            }
                break;
            case type_record:
            {
                if(_convRecord.isAudioExist)
                {
                    //					[self addPlayAudioToCell:cell];
                    //	如果是收到的消息，如果已经下载，并且还未读，那么显示红点，未读标志
                    if(_convRecord.msg_flag == rcv_msg && _convRecord.is_set_redstate == 1 )
                    {
                        UIImageView *readImage=(UIImageView *)[cell.contentView viewWithTag:status_audio_tag];
                        readImage.hidden = NO;
                    }
                }
                else
                {
                    if(_convRecord.send_flag == -1)
                    {
                        //					如果文件不存在，那么就不再下载
                    }
                    else
                    {
                        if(_convRecord.isDownLoading)
                        {
                            [spinner startAnimating];
                        }
                        else
                        {
                            _convRecord.isDownLoading = true;
//                            [self downloadFile:_convRecord.msgId andCell:cell];
                        }
                    }
                }
            }
                break;
            case type_long_msg:
            {
                if(!_convRecord.isLongMsgExist)
                {
                    if(_convRecord.send_flag == -1)
                    {
                        //					如果文件不存在，那么就不再下载
                    }
                    else
                    {
                        if(_convRecord.isDownLoading)
                        {
                            [spinner startAnimating];
                        }
                        else
                        {
                            _convRecord.isDownLoading = true;
//                            [self downloadFile:_convRecord.msgId andCell:cell];
                        }
                    }
                }
                else
                {
                    [talkSessionUtil sendReadNotice:_convRecord];
                }
            }
                break;
            case type_text:
            {
                [talkSessionUtil sendReadNotice:_convRecord];
            }
                break;
        }
        /*
        //	如果是自己发送的一呼百应可以查看已读情况统计
        UIImageView *receiptView = (UIImageView*)[cell.contentView viewWithTag:receipt_tag];
        if(_convRecord.msg_flag == send_msg && _convRecord.isReceiptMsg)
        {
            if(self.talkType == mutiableType)
            {
                receiptView.userInteractionEnabled = YES;
            }
            else if(self.talkType == singleType)
            {
                receiptView.userInteractionEnabled = NO;			
            }
        }
        else
        {
            receiptView.userInteractionEnabled = NO;		
        }
        */
        return cell;
    }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ChatHistoryView *chatHistoryView = [ChatHistoryView getTalkSession];
        NSDictionary *dic  = self.searchResults[indexPath.row];
        
        Conversation *_conv = [[Conversation alloc]init];
        _conv.conv_id = self.convId;
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        _convRecord.msgId = [[dic valueForKey:@"last_msg_id"] intValue];
        _conv.last_record = _convRecord;
        [_convRecord release];
        
        
        chatHistoryView.convId = self.convId;
        chatHistoryView.convName = self.convName;
        chatHistoryView.talkType = self.talkType;
        chatHistoryView.fromType = talksession_from_conv_query_result_need_position;
        chatHistoryView.fromConv = _conv;
        chatHistoryView.needUpdateTag = 1;
        [_conv release];
        [self.navigationController pushViewController:chatHistoryView animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _searchBar.placeholder = [StringUtil getLocalizableString:@"search_tips"];
    [self getRecordsByConvId];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [searchTextView resignFirstResponder];
}

-(void) backButtonPressed:(id) sender{
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *subViewController in array) {
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
        if ([subViewController isKindOfClass:[chatMessageViewController class]]) {
            [self.navigationController popToViewController:subViewController animated:YES];
        }
#else
        if ([subViewController isKindOfClass:[talkSessionViewController class]]) {
            [self.navigationController popToViewController:subViewController animated:YES];
        }
#endif
    }
}

-(void)rightButtonPress:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 获取该会话的聊天记录
-(void)getRecordsByConvId
{
    totalCount = [_ecloud getConvRecordCountBy:self.convId];
    if(totalCount > num_convrecord)
    {
        limit = num_convrecord;
        offset = totalCount - num_convrecord;
    }
    else {
        limit = totalCount;
        offset = 0;
    }
    self.convRecordArray = [NSMutableArray array];
    NSArray *recordList= [self getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    [self.convRecordArray addObjectsFromArray:recordList];
    for(int i=0;i<self.convRecordArray.count;i++)
    {
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:i];
    }
    int count=[recordList count];
    
    [chatHistoryTable reloadData];
    
    //    每屏显示记录数
    int recordCountOfPage = 5;
    
    if (count>0)
    {
        //		默认是最下面
        int _index = [self.convRecordArray count] ;
        
        [chatHistoryTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]
                                      atScrollPosition: UITableViewScrollPositionBottom
                                              animated:NO];			
        
        
    }
    
}

-(NSArray*)getConvRecordBy:(NSString*)convId andLimit:(int)_limit andOffset:(int)_offset
{
    NSArray *recordList;
    
//    if(self.isVirGroup)
//    {
//        recordList=[_ecloud getConvRecordByVirGroup:self.convId andLimit:limit andOffset:offset];
//    }
//    else
//    {
        recordList=[_ecloud getConvRecordBy:convId andLimit:_limit andOffset:offset];
//    }
    
    return recordList;
}

#pragma mark 确定本条记录是否显示时间
-(void)setTimeDisplay:(ConvRecord*)_convRecord  andIndex:(int)_index
{
    if(_convRecord.recordType == mass_conv_record_type && _convRecord.msg_type == type_group_info)
    {
        _convRecord.isTimeDisplay = false;
        return;
    }
    
    if(_index == 0)
    {
        _convRecord.isTimeDisplay = true;
        return;
    }
    
    bool isDisplay = true;
    
    int lastDisplayMsgIndex = [self getLastDisplayTimeMsg:_index];
    
    if(lastDisplayMsgIndex < 0)
    {
        _convRecord.isTimeDisplay = true;
        return;
    }
    
    ConvRecord *tempConvRecord = [self.convRecordArray objectAtIndex:lastDisplayMsgIndex];
    //			如果当前的时间和第一条的时间在3分钟之内，那么就不用显示,有两种情况，一个是小于msg_time_sec,一个是小于0，防止下面消息的显示时间比上面消息的显示时间早的情况 fabs(
    NSTimeInterval _diff = _convRecord.msg_time.intValue - tempConvRecord.msg_time.intValue;
    if(_diff < 0 || (_diff >= 0 && _diff <= msg_time_sec))
    {
        isDisplay = false;
    }
    _convRecord.isTimeDisplay = isDisplay;
}

#pragma mark 找到最近的一条显示时间的消息，从_index开始向前找
-(int)getLastDisplayTimeMsg:(int)_index
{
    for(int i= _index;i>=0;i--)
    {
        ConvRecord *_convRecord = [self.convRecordArray objectAtIndex:i];
        if(_convRecord.isTimeDisplay)
            return i;
    }
    return -1;
}

#pragma mark -----消息cell优化------
- (UITableViewCell *)getMsgCell:(UITableView *)tableView andRecord:(ConvRecord *)_convRecord
{
    UITableViewCell *cell = nil;
    
    int msgType = _convRecord.msg_type;
    
    switch (msgType) {
        case type_text:
        {
            if (_convRecord.isLinkText) {
                static NSString *linkTextCellID = @"linkTextCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:linkTextCellID];
                if (cell == nil) {
                    cell = [[[LinkTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:linkTextCellID]autorelease];
//                    [self addCommonGesture:cell];
                }
            }
#ifdef _XINHUA_FLAG_
            else if (_convRecord.systemMsgModel)
            {
                SystemMsgModelArc *model = _convRecord.systemMsgModel;
                if ([model.msgType isEqualToString:TYPE_NEWS])
                {
                    static NSString *newImgTxtCellID = @"NEWSCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:newImgTxtCellID];
                    if (cell == nil) {
                        cell = [[[NewsCellARC alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newImgTxtCellID]autorelease];
                        [[RobotDisplayUtil getUtil] addImgTxtViewGesture:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else if ([model.msgType isEqualToString:TYPE_VIDEO])
                {
                    static NSString *videoMsgCellID = @"videoMsgCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:videoMsgCellID];
                    if (cell == nil) {
                        cell = [[[VideoMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoMsgCellID]autorelease];
                        //                增加图片消息点击事件
//                        [self addSingleTapToVideoOfCell:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else if ([model.msgType isEqualToString:TYPE_PIC])
                {
                    cell = [[RobotDisplayUtil getUtil]getPicMsgCell];
                }
                else if ([model.msgType isEqualToString:TYPE_VOICE])
                {
                    static NSString *audioMsgCellID = @"xinhuaAudioMsgCellID";
                    cell = [tableView dequeueReusableCellWithIdentifier:audioMsgCellID];
                    if (cell == nil) {
                        cell = [[[AudioMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioMsgCellID]autorelease];
                        //                增加录音消息点击事件
//                        [self addPlayAudioToCell:cell];
                        [self addCommonGesture:cell];
                    }
                }
                else
                {
                    cell = [self getNormalTextCell:tableView andRecord:_convRecord];
                }
            }
#endif
            else if(_convRecord.isTextPic)
            {
                static NSString *faceTextCellID = @"faceTextCellID";
                cell = [tableView dequeueReusableCellWithIdentifier:faceTextCellID];
                if (cell == nil) {
                    cell = [[[FaceTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:faceTextCellID]autorelease];
//                    [self addCommonGesture:cell];
                }
            }
            else
            {
                cell = [self getNormalTextCell:tableView andRecord:_convRecord];
            }
        }
            break;
        case type_long_msg:
        {
            //                长消息和普通的文本消息使用同一个cell
            cell = [self getNormalTextCell:tableView andRecord:_convRecord];
        }
            break;
        case type_record:
        {
            static NSString *audioMsgCellID = @"audioMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:audioMsgCellID];
            if (cell == nil) {
                cell = [[[AudioMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:audioMsgCellID]autorelease];
                //                增加录音消息点击事件
//                [self addPlayAudioToCell:cell];
//                [self addCommonGesture:cell];
            }
        }
            break;
        case type_pic:
        {
            static NSString *picMsgCellID = @"picMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:picMsgCellID];
            if (cell == nil) {
                cell = [[[PicMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:picMsgCellID]autorelease];
                //                增加图片消息点击事件
//                [self addSingleTapToPicViewOfCell:cell];
//                [self addCommonGesture:cell];
            }
        }
            break;
        case type_video:
        {
            static NSString *videoMsgCellID = @"videoMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:videoMsgCellID];
            if (cell == nil) {
                cell = [[[VideoMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:videoMsgCellID]autorelease];
                //                增加图片消息点击事件
//                [self addSingleTapToVideoOfCell:cell];
//                [self addCommonGesture:cell];
            }
        }
            break;
        case type_file:
        {
            static NSString *fileMsgCellID = @"fileMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:fileMsgCellID];
            if (cell == nil) {
                cell = [[[NewFileMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileMsgCellID]autorelease];
                //                增加文件消息点击事件
//                [self addGestureToFile:cell];
//                [self addCommonGesture:cell];
            }
        }
            break;
        case type_group_info:
        {
            static NSString *groupInfoMsgCellID = @"groupInfoMsgCellID";
            cell = [tableView dequeueReusableCellWithIdentifier:groupInfoMsgCellID];
            if(cell == nil)
            {
                cell = [[[GroupInfoMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupInfoMsgCellID]autorelease];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)getNormalTextCell:(UITableView *)tableView andRecord:(ConvRecord *)_convRecord
{
    static NSString *normalTextCellID = @"normalTextCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalTextCellID];
    if (cell == nil) {
        cell = [[[NormalTextMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalTextCellID]autorelease];
//        [self addCommonGesture:cell];
    }
    return cell;
}

- (void)addCommonGesture:(UITableViewCell *)cell
{
    //	头像
    [self processHeadImage:cell];
//    [self addGestureToReceipt:cell];
//    [self addGestureToFailButtonView:cell];
}

#pragma mark 点击头像查看用户资料
-(void)processHeadImage:(UITableViewCell*)cell
{
    
}

#pragma mark 下拉加载历史记录
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {//顶部下拉
    
    //    如果已经加载的记录和总记录数相同，则返回
    if(self.convRecordArray.count >= totalCount)
    {
        return;
    }
    //offset为0，表示已经没有历史记录，那么不处理;
    //	NSLog(@"%s,offset is %d",__FUNCTION__,offset);
    if(offset == 0) {
        return;
    }
    //	NSLog(@"%.0f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y<0 && !isLoading ) {
        isLoading = true;
        loadingIndic.hidden = NO;
        [loadingIndic startAnimating];
        [self performSelector:@selector(getHistoryRecord) withObject:nil afterDelay:0.5];
    }
}

-(void)hideLoadingCell
{
    loadingIndic.hidden = YES;
    [loadingIndic stopAnimating];
    isLoading = false;
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{//底部上拖
//    pageControl.currentPage=scrollView.contentOffset.x/320;
//    
//}

- (void)getHistoryRecord
{
    //	总数量
    totalCount =  [self getConvRecordCountBy:self.convId];
    //已经加载数量
    loadCount = self.convRecordArray.count;
    
    if(totalCount > (loadCount + num_convrecord))
    {
        limit = num_convrecord;
        offset = totalCount - (loadCount + num_convrecord);
    }
    else
    {
        limit =totalCount - loadCount;
        offset = 0;
    }
    //	NSLog(@"%s,totalCount is %d,loadCount is %d",__FUNCTION__,totalCount,loadCount);
    //	NSLog(@"get history record limit is %d,offset is %d",limit,offset);
    
    NSArray *recordList = [_ecloud getConvRecordBy:self.convId andLimit:limit andOffset:offset];
    
    
    
    int count=[recordList count];
    
    for (int i=count-1; i>=0; i--)
    {
        ConvRecord *record =[recordList objectAtIndex:i];
        [self.convRecordArray insertObject:record atIndex:0];
    }
    for(int i = 0;i<recordList.count;i++)
    {
        ConvRecord *_convRecord = [recordList objectAtIndex:i];
        [talkSessionUtil setPropertyOfConvRecord:_convRecord];
        [[talkSessionUtil2 getTalkSessionUtil] setDownloadPropertyOfRecord:_convRecord];
        [self setTimeDisplay:_convRecord andIndex:i];
    }
    
    float oldh = chatHistoryTable.contentSize.height;
    
    [chatHistoryTable reloadData];
    
    [self hideLoadingCell];
    float newh=chatHistoryTable.contentSize.height;
    chatHistoryTable.contentOffset=CGPointMake(0, newh-oldh-20);
}

-(int)getConvRecordCountBy:(NSString*)convId
{
    return [_ecloud getConvRecordCountBy:convId];
}

-(void)searchChatHistory
{
    dispatch_queue_t queue = dispatch_queue_create("search chatHistory", NULL);
    
    dispatch_async(queue, ^{
        NSString *_searchStr = [NSString stringWithString:self.searchStr];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
            
        self.searchResults = [NSMutableArray arrayWithArray:[query searchConvRecordsInConv:self.convId withSearchStr:_searchStr withConvType:self.talkType]];
        
        [pool release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchDisplayController.searchResultsTableView reloadData];
            if (![self.searchResults count]) {
                [self setSearchResultsTitle:[NSString stringWithFormat:[StringUtil getLocalizableString:@"no_search_result"],self.searchStr]];
            }
            
            [[LCLLoadingView currentIndicator] hiddenForcibly:true];
        });
    });
    dispatch_release(queue);
}


#pragma mark -------UISearchDisplay  delegate--------

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchDisplayController setActive:NO];
    [self backButtonPressed:nil];
}

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [UIAdapterUtil customCancelButton:self];
    searchTextView =  [UIAdapterUtil getSearchBarTextField:self];
    [searchTextView becomeFirstResponder];
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
   
    [self.view addSubview:self.hideView];

}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    [[LCLLoadingView currentIndicator] setIgnoreKeyboardEvent:NO];
    [self.searchResults removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [self setSearchResultsTitle:@""];
    for (UIView *subView in [self.view subviews]) {
        if (subView == self.hideView) {
            [subView removeFromSuperview];
        }
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchStr length] < [eCloudConfig getConfig].searchTextMinLen.intValue) {
        [UserTipsUtil showSearchTip];
        return;
    }
    
    [searchBar resignFirstResponder];
//    backgroudButton.hidden=YES;
    
    //搜索提示
    [[LCLLoadingView currentIndicator] setCenterMessage:[StringUtil getLocalizableString:@"searching"]];
    [[LCLLoadingView currentIndicator] show];
    
    [self searchChatHistory];
//}
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [self.view addSubview:self.hideView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchStr = [StringUtil trimString:searchBar.text];
    if(self.searchStr.length == 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        
    }
}


#pragma mark - 搜索提示
- (void)setSearchResultsTitle:(NSString *)title{
    for(UIView *subview in self.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

-(NSArray*)getChatHistoryBySearch:(NSString *)searchString
{
//    NSString *sql = [NSString stringWithFormat:@"select msg_time,msg_body,emp_id from %@ where msg_type = %d and conv_id = %@ and msg_body like '%%%@%%' group by msg_time",table_conv_records,type_text,self.convId,searchString];
   
    
    NSString *sql = [NSString stringWithFormat:@"select conv_records.id as last_msg_id,conv_records.msg_time,conv_records.msg_body,conv_records.emp_id,employee.emp_name,employee.emp_sex,emp_dept.permission from %@,%@,%@ where conv_records.msg_type = %d and conv_records.conv_id = %@ and conv_records.msg_body like '%%%@%%' and conv_records.emp_id=employee.emp_id and conv_records.emp_id=emp_dept.emp_id order by msg_time desc",table_conv_records,table_employee,table_emp_dept,type_text,self.convId,searchString];
    
    NSMutableArray *queryResult = [query querySql:sql];
    
    return queryResult;
    
}
/*
-(CGSize)configCellSize:(NSString*)contentStr
{
    if (contentStr.length > 0) {
        tempCellSize = [contentStr sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(text_Width,MAXFLOAT)lineBreakMode:UILineBreakModeWordWrap];
        if (tempCellSize.height < text_height) {
            tempCellSize.height = row_height;
        }
        else
        {
            tempCellSize.height = tempCellSize.height + 35;
        }
    }
    else
    {
        tempCellSize = CGSizeMake(text_Width, row_height);
    }
    return tempCellSize;
}
*/
@end
