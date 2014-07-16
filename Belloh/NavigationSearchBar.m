//
//  NavigationSearchBar.m
//  Belloh
//
//  Created by Eric Webster on 12/26/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NavigationSearchBar.h"
#import "UIColor+App.h"

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
        
        self.searchBar = [[UISearchBar alloc] init];
        self.searchBar.placeholder = @"Filter posts";
        self.searchBar.delegate = self;
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        
        if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
            // iOS7
            self.searchBar.barTintColor = [UIColor mainColor];
        }
        else {
            // older
            self.searchBar.tintColor = [UIColor mainColor];
        }
        
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
    self.searchBar.frame = CGRectMake(-5.0, 0.0, 320.0, CGRectGetHeight(self.bounds));
    [item.titleView becomeFirstResponder];
    [item setLeftBarButtonItem:self.cancelButton animated:YES];
}

- (void)_searchCancelled
{
    if ([self.myDelegate respondsToSelector:@selector(searchCancelled)]) {
        [self.myDelegate searchCancelled];
    }
    UINavigationItem *item = self.topItem;
    item.rightBarButtonItem = self.rightButton;
    item.titleView = nil;
    [item setLeftBarButtonItem:self.searchButton animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if ([self.myDelegate respondsToSelector:@selector(searchInitiated:)]) {
        [self.myDelegate searchInitiated:searchBar.text];
    }
}

@end
