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

@interface NewsViewController : UITableViewController<CreateViewControllerDelegate,MapViewControllerDelegate,UISearchBarDelegate,BellohDelegate,UITextViewDelegate,CLLocationManagerDelegate>

@end
