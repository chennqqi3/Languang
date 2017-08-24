//
//  NewDeptCell.m
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import "NewDeptCell.h"
#import "Dept.h"
#import "StringUtil.h"
#import "UserDataDAO.h"
#import "DAOverlayView.h"
#import "OrgSizeUtil.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"


#define default_name_width  280 //(280 * 0.75)
#define default_emp_count_width (280 * 0.25)

@interface NewDeptCell(){
    UserDataDAO *userDataDao;
}

@property (retain, nonatomic) UIView *contextMenuView;
@property (assign, nonatomic) BOOL shouldDisplayContextMenuView;
@property (assign, nonatomic) CGFloat initialTouchPositionX;

@end
@implementation NewDeptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        
        self.cellView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))]autorelease];
        self.cellView.backgroundColor = [UIColor whiteColor];
        self.cellView.tag = 1234567;
        [self.contentView addSubview:self.cellView];
        
        
        CGRect rect = self.frame;
        rect.origin.x += [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent];
        rect.size.width = [UIAdapterUtil getTableCellContentWidth] - rect.origin.x - RIGHT_ROW_SIZE;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
        nameLabel.numberOfLines = 2;
        nameLabel.tag = dept_name_tag;
        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:name_font_size];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.cellView addSubview:nameLabel];
//        [self.contentView addSubview:nameLabel];
        [nameLabel release];
        
//        nameLabel.backgroundColor = [UIColor redColor];
        
        self.contextMenuView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,CGRectGetHeight(self.frame))]autorelease];
        self.contextMenuView.backgroundColor = self.cellView.backgroundColor;
        [self.contentView insertSubview:self.contextMenuView belowSubview:self.cellView];
        
        self.contextMenuHidden = self.contextMenuView.hidden = YES;
        self.shouldDisplayContextMenuView = NO;
        self.editable = YES;
        self.menuOptionButtonTitlePadding = 0.;
        self.menuOptionsAnimationDuration = 0.08;
        self.bounceValue = 20.0;
    }
    return self;
}
-(void)dealloc
{
    
//    self.deleteButtonTitle = nil;
//    self.moreOptionsButtonTitle = nil;
//    self.deleteButton = nil;
//    self.moreOptionsButton = nil;

    self.cellView = nil;
    self.contextMenuView = nil;
    
    [super dealloc];
    
//    NSLog(@"%s",__FUNCTION__);
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)configCell:(Dept *)dept{
    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:dept_name_tag];
    nameLabel.text = dept.dept_name;
}

- (void)configSearchResultCell:(Dept *)dept{
    UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag:dept_name_tag];
    nameLabel.text = dept.dept_name;
    CGRect _frame = nameLabel.frame;
    _frame.origin.x = 10;
    nameLabel.frame = _frame;
}

#pragma mark 把需要显示的view增加到cell中，因为要和带选择功能的cell共用，所以增加了这个接口
+ (void)addCommonView:(UITableViewCell *)cell
{
    CGRect rect = cell.frame;
    rect.origin.x += 40;
    rect.size.width -= 70;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:rect];
    nameLabel.numberOfLines = 2;
    nameLabel.tag = dept_name_tag;
    nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:name_font_size];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [cell.contentView addSubview:nameLabel];
    [nameLabel release];
}

-(void)configContextMenuView
{
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self addGestureRecognizer:panRecognizer];
    [panRecognizer release];
    //    [self setNeedsLayout];
}



- (CGFloat)contextMenuWidth
{
//    return CGRectGetWidth(self.deleteButton.frame) + CGRectGetWidth(self.moreOptionsButton.frame);
    return CGRectGetWidth(self.deleteButton.frame);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //    self.contextMenuView.frame = self.cellView.bounds;
    //    self.contextMenuView.backgroundColor = [UIColor redColor];
    //    [self.contentView sendSubviewToBack:self.contextMenuView];
    //    [self.contentView bringSubviewToFront:self.cellView];
    //    [self.contentView insertSubview:self.contextMenuView atIndex:0];
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat menuOptionButtonWidth = 114;
    self.deleteButton.frame = CGRectMake(width - menuOptionButtonWidth, 0., menuOptionButtonWidth, height);
//    self.moreOptionsButton.frame = CGRectMake(width - menuOptionButtonWidth - CGRectGetWidth(self.deleteButton.frame), 0., menuOptionButtonWidth, height);
}


- (void)setDeleteButtonTitle:(NSString *)deleteButtonTitle
{
    if (deleteButtonTitle) {
        _deleteButtonTitle = deleteButtonTitle;
        [self.deleteButton setTitle:deleteButtonTitle forState:UIControlStateNormal];

    }
    //    [self setNeedsLayout];
}


- (void)setEditable:(BOOL)editable
{
    if (_editable != editable) {
        _editable = editable;
        //        [self setNeedsLayout];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)setMenuOptionsViewHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void (^)(void))completionHandler
{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    CGRect frame = CGRectMake((hidden) ? 0 : -[self contextMenuWidth], 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    [DAOverlayView animateWithDuration:(animated) ? self.menuOptionsAnimationDuration : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cellView.frame = frame;
    } completion:^(BOOL finished) {
        self.contextMenuHidden = hidden;
        self.shouldDisplayContextMenuView = !hidden;
        if (!hidden) {
            [self.delegate contextMenuDidShowInCell:self];
        } else {
            [self.delegate contextMenuDidHideInCell:self];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.contextMenuHidden) {
        self.contextMenuView.hidden = YES;
        [super setSelected:selected animated:animated];
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGPoint currentTouchPoint = [panRecognizer locationInView:self.contentView];
        CGFloat currentTouchPositionX = currentTouchPoint.x;
        CGPoint velocity = [recognizer velocityInView:self.contentView];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.initialTouchPositionX = currentTouchPositionX;
            if (velocity.x > 0) {
                [self.delegate contextMenuWillHideInCell:self];
            } else {
                [self.delegate contextMenuDidShowInCell:self];
            }
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if (!self.contextMenuHidden || (velocity.x > 0. || [self.delegate shouldShowMenuOptionsViewInCell:self])) {
                if (self.selected) {
                    [self setSelected:NO animated:NO];
                }
                self.contextMenuView.hidden = NO;
                CGFloat panAmount = currentTouchPositionX - self.initialTouchPositionX;
                self.initialTouchPositionX = currentTouchPositionX;
                CGFloat minOriginX = -[self contextMenuWidth] - self.bounceValue;
                CGFloat maxOriginX = 0.;
                CGFloat originX = CGRectGetMinX(self.cellView.frame) + panAmount;
                originX = MIN(maxOriginX, originX);
                originX = MAX(minOriginX, originX);
                
                
                if ((originX < -0.5 * [self contextMenuWidth] && velocity.x < 0.) || velocity.x < -100) {
                    self.shouldDisplayContextMenuView = YES;
                } else if ((originX > -0.3 * [self contextMenuWidth] && velocity.x > 0.) || velocity.x > 100) {
                    self.shouldDisplayContextMenuView = NO;
                }
                self.cellView.frame = CGRectMake(originX, 0., CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            }
        } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            [self setMenuOptionsViewHidden:!self.shouldDisplayContextMenuView animated:YES completionHandler:nil];
        }
    }
}

- (void)deleteButtonTapped
{
    if ([self.delegate respondsToSelector:@selector(contextMenuCellDidSelectDeleteOption:)]) {
        [self.delegate contextMenuCellDidSelectDeleteOption:self];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}

#pragma mark * Lazy getters

- (UIButton *)deleteButton
{
    if (self.editable) {
        if (!_deleteButton) {
            CGRect frame = CGRectMake(0., 0., 128., CGRectGetHeight(self.cellView.frame));
            _deleteButton = [[UIButton alloc] initWithFrame:frame];
            _deleteButton.backgroundColor = [UIColor colorWithRed:246/255.0 green:245/255.0 blue:250/255.0 alpha:1];
            [_deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
            [self.contextMenuView addSubview:_deleteButton];
            [_deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            [_deleteButton release];
        }
        return _deleteButton;
    }
    return nil;
}

#pragma mark * UIPanGestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

@end
