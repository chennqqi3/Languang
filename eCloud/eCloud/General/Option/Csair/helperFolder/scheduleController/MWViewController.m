//
//  MWViewController.m
//  MWDatePicker
//
//  Created by Marcus on 08.05.13.
//  Copyright (c) 2013 mwermuth.com. All rights reserved.
//

#import "MWViewController.h"

@interface MWViewController ()


@end

@implementation MWViewController
@synthesize selectedDate;
@synthesize datePicker;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.datePicker = [[MWDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    [self.datePicker setDelegate:self];
    [self.datePicker setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    [self.datePicker setFontColor:[UIColor blackColor]];
    [self.datePicker update];
    
    [self.datePicker setDate:self.selectedDate animated:YES];
    
    [self.view addSubview:self.datePicker];

  
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MWPickerDelegate

- (UIColor *) backgroundColorForDatePicker:(MWDatePicker *)picker
{
    return [UIColor whiteColor];
}


- (UIColor *) datePicker:(MWDatePicker *)picker backgroundColorForComponent:(NSInteger)component
{
    
    switch (component) {
        case 0:
            return [UIColor whiteColor];
        case 1:
            return [UIColor whiteColor];
        case 2:
            return [UIColor whiteColor];
        default:
            return 0; // never
    }
}


- (UIColor *) viewColorForDatePickerSelector:(MWDatePicker *)picker
{
    return [UIColor grayColor];
}

-(void)datePicker:(MWDatePicker *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"%@",[picker getDate]);
    [[NSNotificationCenter defaultCenter ]postNotificationName:@"chooseDateNotice" object:[picker getDate] userInfo:nil];
}

@end
