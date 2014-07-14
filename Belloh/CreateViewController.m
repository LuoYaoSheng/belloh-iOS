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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    recog.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:recog];
    
    [[UITextField appearance] setTintColor:[UIColor darkTextColor]];
    self.signatureField.tintColor = [UIColor darkTextColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.signatureField.text = [defaults objectForKey:@"signature"];
    
    //To make the border look very close to a UITextField
    [self.messageView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.3] CGColor]];
    [self.messageView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.messageView.layer.cornerRadius = 5;
    self.messageView.clipsToBounds = YES;
    self.messageView.placeholder = @"Say something...";
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
    NSString *msg = self.messageView.text;
    if ([msg length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Post can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        BLPost *post = [[BLPost alloc] init];
        post.message = msg;
        NSString *sig = self.signatureField.text;
        post.signature = sig;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:sig forKey:@"signature"];
        [defaults synchronize];
        
        if ([self.delegate respondsToSelector:@selector(createViewControllerDidPost:)]) {
            [self.delegate createViewControllerDidPost:post];
        }
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
