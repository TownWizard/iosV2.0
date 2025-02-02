//
//  NSDate+Formatting.m
//  CommandCenter-iPad
//
//  Created by Evgeniy Kirpichenko on 8/1/12.
//  Copyright (c) 2012 Evgeniy Kirpichenko. All rights reserved.
//

#import "NSDate+Formatting.h"
#import "NSDate+Helpers.h"
#import "NSDateFormatter+Extensions.h"

@implementation NSDate (Formatting)

+ (BOOL)isDate:(NSDate *)date inPeriodWithStart:(NSDate *)start end:(NSDate *)end
{
    NSDate *dayStart = [NSDate dateAtBeginningOfDayForDate:start];
    NSDate *dayEnd = end;
    NSDate *earlier = [dayStart earlierDate:date];
    NSDate *later = [dayEnd laterDate:date];
    
    if(earlier == dayStart && later == dayEnd)
    {
        return YES;
    }
    return NO;
    
}

+ (NSString *)stringFromPeriod:(NSDate *)start end:(NSDate *)end
{
    if([[start dateStringWithFormat:@"LLL dd"] isEqualToString:[[NSDate date] dateStringWithFormat:@"LLL dd"]] && [[end dateStringWithFormat:@"LLL dd"] isEqualToString:[[NSDate date] dateStringWithFormat:@"LLL dd"]])
    {
        return @"TODAY";
    }
    else
    {
        NSString *newDatePeriod = [NSString stringWithFormat:@"%@ - %@"
                                   , [start dateStringWithFormat:@"LLL dd"]
                                   , [end dateStringWithFormat:@"LLL dd"]];
        return newDatePeriod;
    }
};

+ (NSDate *) dateFromString:(NSString *) dateString dateFormat:(NSString *) dateFormat {
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithDateFormat:dateFormat];
    return [formatter dateFromString:dateString];
}

+ (NSDate *) dateFromUTCString:(NSString *) dateString dateFormat:(NSString *) dateFormat {
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithDateFormat:dateFormat
                                                                     timezone:utcTimeZone];
    return [formatter dateFromString:dateString];
}

+ (NSString *) stringFromDate:(NSDate *) date dateFormat:(NSString *) dateFormat {
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithDateFormat:dateFormat];    
    return [formatter stringFromDate:date];
}

+ (NSString *) utcStringFromDate:(NSDate *) date dateFormat:(NSString *) dateFormat
{
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithDateFormat:dateFormat
                                                                     timezone:utcTimeZone];
    return [formatter stringFromDate:date];
}

+ (NSString *) stringFromDate:(NSDate *) date
                   dateFormat:(NSString *) dateFormat
             localeIdentifier:(NSString *) localeIdentifier;
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithDateFormat:dateFormat];
    [formatter setLocale:locale];
    [locale release];
    return [formatter stringFromDate:date]; 
}


+ (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

+ (NSDate *)dateAtEndingOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:23];
    [dateComps setMinute:59];
    [dateComps setSecond:59];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}



@end
