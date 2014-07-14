//
//  CustomTableViewCell.h
//  Belloh
//
//  Created by Eric Webster on 12/19/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

@class BLPost;

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UITextView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;

- (void)setContent:(BLPost *)content;

@end
