//
//  CreateViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/25/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BLPost.h"

@class CreateViewController;

@protocol CreateViewControllerDelegate

- (void)createViewControllerDidCancel;
- (void)createViewControllerDidPost:(BLPost *)post;

@end

@interface CreateViewController : UIViewController

@property (nonatomic, weak) id<CreateViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextView *messageView;
@property (nonatomic, weak) IBOutlet UIButton *postButton;
@property (nonatomic, weak) IBOutlet UITextField *signatureField;
@property (nonatomic, assign) CLLocationCoordinate2D BLLocation;

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
