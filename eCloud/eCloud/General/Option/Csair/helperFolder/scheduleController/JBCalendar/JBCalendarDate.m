//
//  JBCalendarDate.m
//  JBCalendar
//
//  Created by YongbinZhang on 7/5/13.
//  Copyright (c) 2013 YongbinZhang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JBCalendarDate.h"
#import "NSDate+Calendar.h"


#ifndef CalendarDateKey
#define CalendarDateKey

#define CalendarDateKeyYear     @"year"
#define CalendarDateKeyMonth    @"month"
#define CalendarDateKeyDay      @"day"

#endif


@interface JBCalendarDate ()

@property (nonatomic, assign, readwrite) NSInteger year;
@property (nonatomic, assign, readwrite) NSInteger month;
@property (nonatomic, assign, readwrite) NSInteger day;

@end


@implementation JBCalendarDate

+ (JBCalendarDate *)dateFromNSDate:(NSDate *)date
{
    
    return [self dateWithYear:date.year Month:date.month Day:date.day];
}

+ (JBCalendarDate *)dateWithYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day
{
    JBCalendarDate *calendarDate = [[JBCalendarDate alloc] init];
    calendarDate.year = year;
    calendarDate.month = month;
    calendarDate.day = day;
    return calendarDate;
}

+ (JBCalendarDate *)dateFromNSDictionary:(NSDictionary *)dictionary
{
    return [[JBCalendarDate alloc] initWithDictionary:dictionary];
}

- (JBCalendarDate *)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        if (dictionary) {
            self.year = ((NSNumber *)[dictionary objectForKey:CalendarDateKeyYear]).integerValue;
            self.month = ((NSNumber *)[dictionary objectForKey:CalendarDateKeyMonth]).integerValue;
            self.day = ((NSNumber *)[dictionary objectForKey:CalendarDateKeyDay]).integerValue;
        }
    }

    return self;
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInteger:self.year], [NSNumber numberWithInteger:self.month], [NSNumber numberWithInteger:self.day], nil] forKeys:[NSArray arrayWithObjects:CalendarDateKeyYear, CalendarDateKeyMonth, CalendarDateKeyDay, nil]];
}

- (NSDate *)nsDate
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = self.year;
    components.month = self.month;
    components.day = self.day;
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSComparisonResult)compare:(JBCalendarDate *)other
{
    if (other) {
        if (self.year == other.year && self.month == other.month && self.day == other.day) {
            return NSOrderedSame;
        } else if (self.year < other.year || self.month < other.month || self.day < other.day) {
            return NSOrderedAscending;
        }
    }
    
    return NSOrderedDescending;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"year:%i, month:%i, day:%i", self.year, self.month, self.day];
}

@end
