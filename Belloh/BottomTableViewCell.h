//
//  BottomTableViewCell.h
//  Belloh
//
//  Created by Eric Webster on 2014-07-17.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;

@end
