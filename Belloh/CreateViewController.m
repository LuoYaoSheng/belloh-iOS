//
//  CreateViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "CreateViewController.h"
#import "UIColor+App.h"
#import "UIView+Keyboard.h"

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
    
    self.miniMap.mapType = MKMapTypeHybrid;
    
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(hideKeyboard:)];
    recog.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:recog];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.signatureField.text = [defaults objectForKey:@"signature"];
    
    self.messageView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor;
    self.messageView.layer.borderWidth = 1.0;
    self.signatureField.superview.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor;
    self.signatureField.superview.layer.borderWidth = 1.0;
    
    self.messageView.layer.cornerRadius = 5.f;
    self.signatureField.superview.layer.cornerRadius = 5.f;
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

@end
