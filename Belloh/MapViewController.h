//
//  FlipsideViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>

- (void)mapViewControllerDidLoad:(MapViewController *)controller;
- (void)mapViewControllerDidFinish:(MapViewController *)controller;

@end

@interface MapViewController : UIViewController

@property (weak, nonatomic) id<MapViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)done:(id)sender;

@end
