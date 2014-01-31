//
//  NavigationSearchBar.h
//  Belloh
//
//  Created by Eric Webster on 12/26/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

@protocol NavigationSearchBarDelegate <NSObject>

@optional
- (void)searchInitiated:(NSString *)searchQuery;
- (void)searchCancelled;

@end

@interface NavigationSearchBar : UINavigationBar<UISearchBarDelegate>

@property (weak, nonatomic) id<NavigationSearchBarDelegate> delegate;

@end
