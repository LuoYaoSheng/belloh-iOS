//
//  BLMap.m
//  Belloh
//
//  Created by Eric Webster on 12/23/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "BLMap.h"

@implementation BLMap

+ (id)mapWithRegion:(MKCoordinateRegion)region
{
    return [[BLMap alloc] initWithRegion:region];
}

- (id)initWithRegion:(MKCoordinateRegion)region
{
    if (self = [super init])
    {
        self.region = region;
    }
    return self;
}

@end
