//
//  FlipsideViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate

- (void)mapViewControllerDidFinish:(MapViewController *)controller;

@end

@interface MapViewController : UIViewController

@property (weak, nonatomic) id <MapViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic) MKCoordinateRegion region;

- (IBAction)done:(id)sender;

@end
