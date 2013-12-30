//
//  BLMap.h
//  Belloh
//
//  Created by Eric Webster on 12/23/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BLMap : NSObject

@property (nonatomic, assign) MKCoordinateRegion region;

+ (id)mapWithRegion:(MKCoordinateRegion)region;
- (id)initWithRegion:(MKCoordinateRegion)region;

@end
