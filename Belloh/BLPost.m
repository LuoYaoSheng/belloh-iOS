//
//  Post.m
//  Belloh
//
//  Created by Eric Webster on 12/20/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "BLPost.h"

@interface NSString (extras)

+ (NSString *)stringWithInterval:(unsigned int)intervalInSeconds;

@end

@implementation NSString (extras)

+ (NSString *)stringWithInterval:(unsigned int)intervalInSeconds
{
    if (intervalInSeconds >= 60) {
        unsigned int minutes = round(intervalInSeconds/60);
        if (minutes >= 60) {
            unsigned int hours = round(minutes/60);
            if (hours >= 24) {
                unsigned int days = round(hours/24);
                if (days >= 365) {
                    unsigned int years = round(days/365);
                    return [NSString stringWithFormat:@"%dy", years];
                }
                else if (days >= 7) {
                    unsigned int weeks = round(days/7);
                    return [NSString stringWithFormat:@"%dw", weeks];
                }
                return [NSString stringWithFormat:@"%dd", days];
            }
            return [NSString stringWithFormat:@"%dh", hours];
        }
        return [NSString stringWithFormat:@"%dm", minutes];
    }
    return [NSString stringWithFormat:@"%ds", intervalInSeconds];
}

@end

@implementation BLPost

- (void)setTimestampWithBSONId:(NSString *)BSONId
{
    NSString *BSONTimestamp = [BSONId substringToIndex:8];
    unsigned int BSONDateInSeconds = 0;
    NSScanner *scanner = [NSScanner scannerWithString:BSONTimestamp];
    
    [scanner scanHexInt:&BSONDateInSeconds];
    
    unsigned int currentDateInSeconds = [[NSDate date] timeIntervalSince1970];
    unsigned int intervalInSeconds = currentDateInSeconds-BSONDateInSeconds;
    self.timestamp = [NSString stringWithInterval:intervalInSeconds];
}

@end
