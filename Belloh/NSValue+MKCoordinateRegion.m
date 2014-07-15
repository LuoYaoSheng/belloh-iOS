//
//  NSValue+MKCoordinateRegion.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-15.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "NSValue+MKCoordinateRegion.h"

@implementation NSValue (MKCoordinateRegion)

+ (instancetype)valueWithMKCoordinateRegion:(MKCoordinateRegion)region
{
    return [self valueWithBytes:&region objCType:@encode(MKCoordinateRegion)];
}

- (MKCoordinateRegion)MKCoordinateRegionValue
{
    MKCoordinateRegion region;
    [self getValue:&region];
    return region;
}

@end
