//
//  NSData+NSValue.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-15.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "NSData+NSValue.h"

@implementation NSData (NSValue)

+ (instancetype)dataWithValue:(NSValue *)value
{
    NSUInteger size;
    const char *encoding = [value objCType];
    NSGetSizeAndAlignment(encoding, &size, NULL);
    
    void *ptr = malloc(size);
    [value getValue:ptr];
    id data = [self dataWithBytes:ptr length:size];
    free(ptr);
    
    return data;
}

- (NSValue *)valueWithObjCType:(const char *)type
{
    NSUInteger size;
    NSGetSizeAndAlignment(type, &size, NULL);
    
    void *ptr = malloc(size);
    [self getBytes:ptr];
    NSValue *value = [NSValue valueWithBytes:ptr objCType:type];
    free(ptr);
    
    return value;
}

@end
