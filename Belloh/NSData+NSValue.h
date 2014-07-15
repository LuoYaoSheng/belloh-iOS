//
//  NSData+NSValue.h
//  Belloh
//
//  Created by Eric Webster on 2014-07-15.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSValue)

+ (instancetype)dataWithValue:(NSValue *)value;
- (NSValue *)valueWithObjCType:(const char *)type;

@end
