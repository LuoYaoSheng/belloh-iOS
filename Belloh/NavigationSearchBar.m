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

@end

@implementation NavigationSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        UINavigationItem *item = self.items[0];
        self.searchButton = item.leftBarButtonItem;
        self.searchButton.action = @selector(_displaySearchBar);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Search Bar

- (void)_displaySearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = @"Filter posts";
    searchBar.delegate = self;
    /*
     UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
     searchBarView.autoresizingMask = 0;
     [searchBarView addSubview:searchBar];
     */
    UINavigationItem *item = self.items[0];
    item.titleView = searchBar;
    
    [item.titleView becomeFirstResponder];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(_cancelSearch)];
    
    self.searchButton = item.leftBarButtonItem;
    [item setLeftBarButtonItem:cancelBarButton animated:YES];
    //[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)_cancelSearch
{
    [self.delegate searchCancelled];
    UINavigationItem *item = self.items[0];
    item.titleView = nil;
    [item setLeftBarButtonItem:self.searchButton animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Filter: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self.delegate searchInitiated:searchBar.text];
}

@end
