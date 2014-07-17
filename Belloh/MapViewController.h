//
//  FlipsideViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BookmarksViewController.h"

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

@optional
- (void)mapViewControllerDidLoad:(MapViewController *)controller;
- (void)mapViewControllerDidFinish:(MapViewController *)controller;

@end

@interface MapViewController : UIViewController<CLLocationManagerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,BookmarksViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)findMe:(id)sender;
- (IBAction)addBookmark:(id)sender;

@end
