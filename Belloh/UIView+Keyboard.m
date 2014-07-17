//
//  UIView+Keyboard.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-17.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "UIView+Keyboard.h"

@implementation UIView (Keyboard)

- (IBAction)hideKeyboard:(id)sender
{
    [self endEditing:YES];
}

@end
