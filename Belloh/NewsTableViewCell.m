//
//  CustomTableViewCell.m
//  Belloh
//
//  Created by Eric Webster on 12/19/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NewsTableViewCell.h"

@implementation NewsTableViewCell

- (void)layoutSubviews
{

    if (self.thumbnailImageView.image) {
        self.thumbnailImageView.layer.cornerRadius = 2.0f;
        self.thumbnailImageView.layer.masksToBounds = YES;
    }
 
    CGRect labelRect = self.timestampLabel.frame;
    labelRect.origin.y = self.messageView.frame.size.height;
    self.timestampLabel.frame = labelRect;    
}

- (void)setContent:(BLPost *)content;
{
    CGRect frameRect = self.messageView.frame;
    frameRect.size.height = self.frame.size.height-SIGNATURE_LABEL_HEIGHT-1;

//
// Adjust the messageView's width based on there being a thumbnail or not
// (not necessarily loaded yet)
//

    if (content.hasThumbnail) {
        frameRect.size.width = MESSAGE_VIEW_MIN_WIDTH;
    }
    else {
        frameRect.size.width = MESSAGE_VIEW_MAX_WIDTH;
    }

    self.thumbnailImageView.image = content.thumbnail;
    
    self.timestampLabel.text = [NSString stringWithFormat:@"%@ ago by %@",content.timestamp,content.signature];
    
//
// Hack to get around UITextView's link detection bug.
// Simply replace messageView with a brand new UITextView.
//

    UITextView *theContent = [[UITextView alloc] initWithFrame:frameRect];
    [theContent setSelectable:YES];
    [theContent setScrollEnabled:NO];
    [theContent setEditable:NO];
    [theContent setFont:self.messageView.font];
    [theContent setTextColor:self.messageView.textColor];
    [theContent setBackgroundColor:self.messageView.backgroundColor];
    [theContent setTintColor:self.messageView.tintColor];
    [theContent setDataDetectorTypes:UIDataDetectorTypeLink];
    
    [self.messageView removeFromSuperview];
    
    self.messageView = theContent;
    [self addSubview:self.messageView];

    self.messageView.text = content.message;
}
@end
