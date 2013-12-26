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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    CGRect frame = self.messageView.frame;
    frame.size.height = 140.0f;
    self.messageView.frame = frame;
    
    [self.messageView setScrollEnabled:NO];
    //To make the border look very close to a UITextField
    [self.messageView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.3] CGColor]];
    [self.messageView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.messageView.layer.cornerRadius = 5;
    self.messageView.clipsToBounds = YES;
    
    self.postButton.layer.cornerRadius = 5;
    self.postButton.layer.borderWidth = 1;
    //self.postButton.layer.borderColor = [UIColor blueColor].CGColor;
    
    [self.messageView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)post:(id)sender
{
    
}

@end
