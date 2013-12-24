//
//  MainViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"

@interface NewsViewController : UIViewController <MapViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>

+ (void)removeShadowImageFromNavBar:(UINavigationBar *)navBar;

@end
