//
//  CreateViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PlaceholderTextView.h"

@class BLPost, CreateViewController;

@protocol CreateViewControllerDelegate <NSObject>

@optional
- (void)createViewControllerDidCancel;
- (void)createViewControllerDidPost:(BLPost *)post;
- (void)createViewControllerDidLoad:(CreateViewController *)controller;

@end

@interface CreateViewController : UIViewController

@property (nonatomic, weak) id<CreateViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet PlaceholderTextView *messageView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UITextField *signatureField;
@property (nonatomic, weak) IBOutlet MKMapView *miniMap;

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
