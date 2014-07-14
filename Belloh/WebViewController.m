//
//  WebViewController.m
//  Belloh
//
//  Created by Eric Webster on 2014-07-14.
//  Copyright (c) 2014 Eric Webster. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self.url absoluteString];
    self.webView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
}

@end
