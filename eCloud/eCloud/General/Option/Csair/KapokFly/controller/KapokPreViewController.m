//
//  HelpViewController.m
//  GrooveStik
//
//  Created by  lyong on 12-8-18.
//
//

#import "KapokPreViewController.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
@interface KapokPreViewController ()

@end

@implementation KapokPreViewController
@synthesize scrollview;
@synthesize navBar;
@synthesize  closebutton;
@synthesize dataArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"图片查看";
    if (IOS7_OR_LATER) {
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    // Do any additional setup after loading the view from its nib.
    scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//     if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
//        
//         scrollview.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//     }
    
    [self.view addSubview:scrollview];
    [self showScrollview];
 //   self.navBar.topItem.title=NSLocalizedString(@"Help", @"");
//    [self.closebutton setTitle:NSLocalizedString(@"关闭", @"") forState:UIControlStateNormal];
}
-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)showScrollview
{
  
    scrollview.delegate=self;
  //  scrollview.contentSize=CGSizeMake(320*allpage, 390);
	scrollview.pagingEnabled=YES;
	scrollview.showsHorizontalScrollIndicator=NO;
    scrollview.showsVerticalScrollIndicator=NO;
    // add by toxicanty 0807
    scrollview.bounces = NO;
    UIImageView* cardview;
    int count=[self.dataArray count];
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
	for(int i=0;i<count;i++)
	{
		NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
        NSString *pic_path=[self.dataArray objectAtIndex:i];
        NSData* data=[NSData dataWithContentsOfFile:pic_path];
       
	    cardview=[[UIImageView alloc]initWithFrame:CGRectMake(screenW*i,0, screenW,self.view.frame.size.height)];
        //[cardview setContentMode:UIViewContentModeScaleToFill];
        cardview.clipsToBounds = YES;
        cardview.contentMode = UIViewContentModeScaleAspectFill;
        cardview.image=[UIImage imageWithData:data];
        [scrollview addSubview:cardview];
        [cardview release];
		[pool drain];
	}
    scrollview.contentSize=CGSizeMake(screenW*count, self.view.frame.size.height-64);
	pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-70, 280, 20)];
	[self.view addSubview:pageControl];
	[pageControl release];
	pageControl.currentPage=0;
	pageControl.numberOfPages=count;
	
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControl.currentPage=scrollView.contentOffset.x/self.view.frame.size.width;
    
}

-(IBAction)closeAction:(id)sender
{
 [self.view removeFromSuperview];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
