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
    [super layoutSubviews];
    
    if (self.thumbnailImageView.image) {
        self.thumbnailImageView.layer.cornerRadius = 2.0f;
        self.thumbnailImageView.layer.masksToBounds = YES;
    }
}

- (void)setContent:(BLPost *)content;
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.f]};
    NSAttributedString *boldSig = [[NSAttributedString alloc] initWithString:content.signature attributes:attributes];
    NSMutableAttributedString *timestamp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ago by ", content.timestamp]];
    [timestamp appendAttributedString:boldSig];
    self.timestampLabel.attributedText = timestamp;
    
//
// Hack to get around UITextView's link detection bug.
//

    UITextView *theContent = [[UITextView alloc] init];
    [theContent setSelectable:YES];
    [theContent setScrollEnabled:NO];
    [theContent setEditable:NO];
    [theContent setFont:self.messageView.font];
    [theContent setTextColor:self.messageView.textColor];
    [theContent setBackgroundColor:self.messageView.backgroundColor];
    [theContent setTintColor:self.messageView.tintColor];
    [theContent setDataDetectorTypes:UIDataDetectorTypeLink];
    [theContent setText:content.message];
    
    self.messageView.attributedText = theContent.attributedText;
}
@end
