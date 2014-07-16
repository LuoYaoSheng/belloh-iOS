//
//  MainViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "WebViewController.h"

#import "UIImageView+AFNetworking.h"
#import "NSValue+MKCoordinateRegion.h"
#import "NSData+NSValue.h"

@interface NewsViewController ()

@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) Belloh *belloh;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) NSURL *selectedURL;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSIndexPath *previousVisibleIndexPath;

@end

@implementation NewsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.geocoder = [[CLGeocoder alloc] init];

        self.belloh = [[Belloh alloc] init];
        self.belloh.delegate = self;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:@"region"];
        
        if (data) {
            NSValue *region = [data valueWithObjCType:@encode(MKCoordinateRegion)];
            self.belloh.region = [region MKCoordinateRegionValue];
            [self.belloh BL_loadPosts];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [self BL_setNavBarTitleToLocationName];
        }
        else {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *location = [locations lastObject];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02167,0.03193);
    self.belloh.region = MKCoordinateRegionMake(location.coordinate, span);
    [self.belloh BL_loadPosts];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self BL_setNavBarTitleToLocationName];
    manager.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];

    [self.tableView layoutIfNeeded];
    self.tableView.editing = YES;
    self.tableView.estimatedRowHeight = 75.f;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
    
    [(NavigationSearchBar *)self.navigationController.navigationBar setMyDelegate:self];
    
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

- (void)updateEllipsis:(NSTimer *)timer
{
    NSString *title = self.navigationItem.title;
    if ([title length] >= 5) {
        self.navigationItem.title = nil;
    }
    else if ([title length] == 0) {
        self.navigationItem.title = @".";
    }
    else {
        self.navigationItem.title = [title stringByAppendingString:@" ."];
    }
}

- (void)loadingPostsFinished
{
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([URL.scheme isEqual:@"http"] || [URL.scheme isEqual:@"https"]) {
        self.selectedURL = URL;
        [self performSegueWithIdentifier:@"showLink" sender:nil];
        return NO;
    }
    return YES;
}

#pragma mark - UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.belloh BL_postCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ThumbCellIdentifier = @"ThumbCell";
    static NSString *NoThumbCellIdentifier = @"NoThumbCell";
    
    BLPost *post = [self.belloh BL_postAtIndex:indexPath.row];
    
    NewsTableViewCell *cell;
    
    if (post.hasThumbnail) {
        cell = [tableView dequeueReusableCellWithIdentifier:ThumbCellIdentifier forIndexPath:indexPath];
        
        NSURL *imageURL = [NSURL URLWithString:post.thumbnail];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0];
        [cell.thumbnailImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
            if (response) {
            // TODO: might need better way to do this.
                NewsTableViewCell *currentCell = (NewsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                currentCell.thumbnailImageView.image = image;
            }
            else {
                cell.thumbnailImageView.image = image;
            }
        } failure:nil];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:NoThumbCellIdentifier forIndexPath:indexPath];
    }
    
    //cell.messageView.backgroundColor = [UIColor blueColor];
    cell.messageView.delegate = self;
    [cell setContent:post];
    
    if (indexPath.row >= [self.belloh BL_postCount]-1) {
        [self.belloh BL_loadAndAppendOlderPosts];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    BLPost *post = [self.belloh BL_postAtIndex:sourceIndexPath.row];
    @try {
        [self.belloh removePostAtIndex:sourceIndexPath.row];
        [self.belloh insertPost:post atIndex:destinationIndexPath.row];
    }
    @catch (NSException *exception) {
        BLLOG(@"%@", exception);
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLPost *post = [self.belloh BL_postAtIndex:indexPath.row];
    NSString *text = post.message;
    CGFloat width = CGRectGetWidth(tableView.bounds) - 40.f;
    if (post.hasThumbnail) {
        width -= 60.0f;
    }
    
    UIFont *font = [UIFont fontWithName:@"Thonburi" size:18.f];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width - 10.f, CGFLOAT_MAX}
                                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                    context:nil];
    CGFloat height = 50.f;
    
    if ([attributedText length]) {
        height += floorf(rect.size.height);
    }
    else {
        height += floorf(rect.size.height + font.lineHeight);
    }
    
    if (post.hasThumbnail && height < 75.f) {
        height = 75.f;
    }
    return height;
}

#pragma mark - Map View Controller Delegate

- (void)mapViewControllerDidFinish:(MapViewController *)controller
{
    MKCoordinateRegion region = [controller.mapView region];
    
    if (MKCoordinateRegionEqualToRegion(region, self.belloh.region)) {
        BLLOG(@"same");
        return;
    }
    
    self.belloh.region = region;
    
    // Save the region
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSValue *value = [NSValue valueWithMKCoordinateRegion:region];
    NSData *data = [NSData dataWithValue:value];
    [defaults setObject:data forKey:@"region"];
    [defaults synchronize];
    
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
        [(MapViewController *)dest setDelegate:self];
    }
    else if ([identifier isEqualToString:@"newPost"]) {
        [(CreateViewController *)dest setDelegate:self];
    }
    else if ([identifier isEqualToString:@"showLink"]) {
        [(WebViewController *)dest setUrl:self.selectedURL];
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
    __weak __typeof(self)weakSelf = self;
    [self.belloh BL_sendNewPost:post completion:^{
        [weakSelf.tableView reloadData];
    }];
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
    
    self.navigationItem.title = nil;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateEllipsis:) userInfo:nil repeats:YES];

    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [self.timer invalidate];
        
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
        
        self.navigationItem.title = locationName;
    }];
}

#pragma mark - Navigation Search Bar Delegate

- (void)searchInitiated:(NSString *)searchQuery
{
    self.previousVisibleIndexPath = [[self.tableView indexPathsForVisibleRows] firstObject];
    self.belloh.filter = searchQuery;
    BLLOG(@"Filter: %@", searchQuery);
}

- (void)searchCancelled
{
    if (self.belloh.filter) {
        self.belloh.filter = nil;
        [self.tableView reloadData];
        NSUInteger rows = [self tableView:self.tableView numberOfRowsInSection:self.previousVisibleIndexPath.section];
        if (self.previousVisibleIndexPath.row < rows) {
            [self.tableView scrollToRowAtIndexPath:self.previousVisibleIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else {
            [self.tableView setContentOffset:CGPointZero animated:NO];
            self.previousVisibleIndexPath = nil;
        }
    }
}

@end
