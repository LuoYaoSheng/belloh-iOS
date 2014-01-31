//
//  MainViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"

@interface NewsViewController ()

@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) Belloh *belloh;
@property (nonatomic) UIRefreshControl *refreshControl;

@end

@implementation NewsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self->_geocoder = [[CLGeocoder alloc] init];

        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(30.15596,0);
        MKCoordinateSpan span = MKCoordinateSpanMake(0.02167,0.03193);
        
        __weak __typeof(self)weakSelf = self;
        self->_belloh = [[Belloh alloc] initWithRegion:MKCoordinateRegionMake(locationCoordinate, span) completionHandler:^{
            [weakSelf.tableView reloadData];
        }];
        
        self->_belloh.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.belloh BL_loadPosts];
    [self BL_setNavBarTitleToLocationName];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    
    [self.navigationController.navigationBar setDelegate:self];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMap)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMap)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)showMap
{
    [self performSegueWithIdentifier:@"showMap" sender:self];
}

- (IBAction)switchTag:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"All"]) {
        self.belloh.tag = nil;
    }
    else if ([sender.title isEqualToString:@"Events and Deals"]) {
        self.belloh.tag = @"EnD";
    }
    else {
        self.belloh.tag = sender.title;
    }
    [self.belloh BL_loadPosts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleRefresh
{
    [self.belloh BL_loadPosts];
}

- (void)loadingPostsFinished
{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.belloh BL_postCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    BLPost *post = [self.belloh BL_postAtIndex:indexPath.row];
    [cell setContent:post];
    
    if (indexPath.row >= [self.belloh BL_postCount]-1) {
        [self.belloh BL_loadAndAppendOlderPosts];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLPost *post = [self.belloh BL_postAtIndex:indexPath.row];

    NSString *text = post.message;
    CGFloat width = (post.hasThumbnail ? MESSAGE_VIEW_MIN_WIDTH : MESSAGE_VIEW_MAX_WIDTH) - 10.0f;
    UIFont *font = [UIFont fontWithName:@"American Typewriter" size:14.0f];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
                                               
    CGFloat height = rect.size.height + SIGNATURE_LABEL_HEIGHT + 15.0f;
    if (post.hasThumbnail && height < TABLE_CELL_MIN_HEIGHT) {
        height = TABLE_CELL_MIN_HEIGHT;
    }
    return height;
}

#pragma mark - Map View Controller Delegate

- (void)mapViewControllerDidFinish:(MapViewController *)controller
{
    MKCoordinateRegion region = [controller.mapView region];
    self.belloh.region = region;
    [self.belloh BL_removeAllPosts];
    [self.tableView reloadData];
    [self.belloh BL_loadPosts];
    [self BL_setNavBarTitleToLocationName];
}

- (void)mapViewControllerDidLoad:(MapViewController *)controller
{
    [controller.mapView setRegion:self.belloh.region animated:NO];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = [segue identifier];
    id dest = [segue destinationViewController];
    if ([identifier isEqualToString:@"showMap"]) {
        [dest setDelegate:self];
    }
    else if ([identifier isEqualToString:@"newPost"]) {
        [dest setDelegate:self];
    }
}

#pragma mark - Create View Controller Delegate

- (void)createViewControllerDidLoad:(CreateViewController *)controller
{
    [controller.miniMap setRegion:self.belloh.region animated:NO];
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = self.belloh.region.center;
    [controller.miniMap addAnnotation:point];
}

- (void)createViewControllerDidPost:(BLPost *)post
{
    CLLocationCoordinate2D location = self.belloh.region.center;
    post.latitude = location.latitude;
    post.longitude = location.longitude;
    [self.belloh BL_sendNewPost:post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createViewControllerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Geocoding

- (void)BL_setNavBarTitleToLocationName
{
    CLLocationCoordinate2D center = self.belloh.region.center;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            return BLLOG(@"geocoding: %@", error);
        }
        
        CLPlacemark *placemark = placemarks[0];
        NSString *locationName;
        
        if (placemark.locality) {
            locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.country];
        }
        else if (placemark.country) {
            locationName = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
        }
        else {
            locationName = [NSString stringWithFormat:@"%@", placemark.name];
        }
        
        UINavigationItem *item = self.navigationController.navigationBar.topItem;
        item.title = locationName;
    }];
}

#pragma mark - Navigation Search Bar Delegate

- (void)searchInitiated:(NSString *)searchQuery
{
    self.belloh.filter = searchQuery;
    BLLOG(@"Filter: %@", searchQuery);

    [self.belloh BL_loadPosts];
}

- (void)searchCancelled
{
    if (self.belloh.filter) {
        self.belloh.filter = nil;
        [self.belloh BL_loadPosts];
    }
}

@end
