//
//  CustomTableViewCell.h
//  Belloh
//
//  Created by Eric Webster on 12/19/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#define MESSAGE_VIEW_MIN_WIDTH 258.0f
#define MESSAGE_VIEW_MAX_WIDTH 315.0f
#define SIGNATURE_LABEL_HEIGHT 25.0f
#define TABLE_CELL_MIN_HEIGHT 75.0f

#import <Belloh/Belloh.h>

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UITextView *messageView;
@property (nonatomic, weak) IBOutlet UILabel *timestampLabel;

- (void)setContent:(BLPost *)content;

@end
