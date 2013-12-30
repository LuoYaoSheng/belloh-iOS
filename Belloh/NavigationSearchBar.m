//
//  NavigationSearchBar.m
//  Belloh
//
//  Created by Eric Webster on 12/26/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NavigationSearchBar.h"

@interface NavigationSearchBar ()

@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *rightButton;

@end

@implementation NavigationSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        UINavigationItem *item = self.topItem;
        self.searchButton = item.leftBarButtonItem;
        self.searchButton.action = @selector(_displaySearchBar);
        
        self.rightButton = item.rightBarButtonItem;
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
        self.searchBar.placeholder = @"Filter posts";
        self.searchBar.delegate = self;
        
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(_searchCancelled)];
    }
    return self;
}

#pragma mark - Search Bar

- (void)_displaySearchBar
{
    UINavigationItem *item = self.topItem;
    item.rightBarButtonItem = nil;

    item.titleView = self.searchBar;
    [item.titleView becomeFirstResponder];
    [item setLeftBarButtonItem:self.cancelButton animated:YES];
}

- (void)_searchCancelled
{
    [self.delegate searchCancelled];
    UINavigationItem *item = self.topItem;
    item.rightBarButtonItem = self.rightButton;
    item.titleView = nil;
    [item setLeftBarButtonItem:self.searchButton animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.delegate searchInitiated:searchBar.text];
}

@end
