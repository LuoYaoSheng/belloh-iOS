//
//  CreateViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *messageView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UITextField *signatureField;

- (IBAction)post:(id)sender;

@end
