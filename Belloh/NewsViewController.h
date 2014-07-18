//
//  MainViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"
#import "CreateViewController.h"
#import "NavigationSearchBar.h"

@interface NewsViewController : UITableViewController<CreateViewControllerDelegate,MapViewControllerDelegate,UISearchBarDelegate,BellohDelegate,UITextViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UILabel *postCountLabel;

@end
