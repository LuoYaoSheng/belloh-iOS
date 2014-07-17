//
//  NSObject+Classes.h
//  MetricWire
//
//  Created by Eric Webster on 2014-06-17.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Classes)

+ (instancetype)sanitize:(id)object withDefault:(id)aDefault;
+ (instancetype)sanitize:(id)object;

- (BOOL)isKindOfSomeClass:(Class)aClass, ... NS_REQUIRES_NIL_TERMINATION;

@end
