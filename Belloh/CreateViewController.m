//
//  CreateViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //To make the border look very close to a UITextField
    [self.messageView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.3] CGColor]];
    [self.messageView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.messageView.layer.cornerRadius = 5;
    self.messageView.clipsToBounds = YES;    
    self.postButton.layer.cornerRadius = 5;
    
    if ([self.delegate respondsToSelector:@selector(createViewControllerDidLoad:)]) {
        [self.delegate createViewControllerDidLoad:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)post:(id)sender
{
    BLPost *post = [[BLPost alloc] init];
    post.message = self.messageView.text;
    post.signature = self.signatureField.text;

    if ([self.delegate respondsToSelector:@selector(createViewControllerDidPost:)]) {
        [self.delegate createViewControllerDidPost:post];
    }
}

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(createViewControllerDidCancel)]) {
        [self.delegate createViewControllerDidCancel];
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
