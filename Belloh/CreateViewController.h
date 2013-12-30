//
//  CreateViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "BLPost.h"

@protocol CreateViewControllerDelegate

- (void)createViewControllerDidCancel;
- (void)createViewControllerDidPost:(BLPost *)post;

@end

@interface CreateViewController : UIViewController

@property (nonatomic, weak) id<CreateViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextView *messageView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UITextField *signatureField;

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
