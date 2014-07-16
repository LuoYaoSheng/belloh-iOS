//
//  App.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "App.h"

@implementation App

- (BOOL)openURL:(NSURL *)URL
{
    BLLOG(@"%@", URL);
    if ([URL.scheme isEqual:@"http"] || [URL.scheme isEqual:@"https"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openURL" object:nil userInfo:@{@"URL": URL}];
        return NO;
    }
    return YES;
}

@end
