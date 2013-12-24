//
//  MultilineLabel.m
//  Belloh
//
//  Created by Eric Webster on 12/20/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MultilineLabel.h"

@implementation MultilineLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [self _fitContent];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self _fitContent];
}

- (void)_fitContent
{
    CGFloat width = self.frame.size.width;
    [self sizeToFit];
    CGRect cellFrame = self.frame;
    cellFrame.size.width = width;
    self.frame = cellFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
