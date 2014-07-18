//
//  NavigationSearchBar.h
//  Belloh
//
//  Created by Eric Webster on 12/26/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

@interface NavigationSearchBar : UINavigationBar

@property (nonatomic, assign) BOOL leftSide;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic, readonly) BOOL active;

- (IBAction)hideSearchBar:(id)sender;

@end
