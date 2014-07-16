//
//  UIColor+App.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-16.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "UIColor+App.h"

@implementation UIColor (App)

+ (UIColor *)mainColor
{
    static UIColor *color;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       color = [UIColor colorWithRed:209.0/255.0 green:156.0/255.0 blue:48.0/255.0 alpha:1.0];
    });
    return color;
}

@end
