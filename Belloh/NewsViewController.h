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

@protocol Belloh <CreateViewControllerDelegate,MapViewControllerDelegate,NavigationSearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@interface NewsViewController : UIViewController <Belloh>

@end
