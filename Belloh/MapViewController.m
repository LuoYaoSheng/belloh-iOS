//
//  FlipsideViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapViewController ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSArray *searchResults;
@property (nonatomic) MKLocalSearch *search;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    if ([searchBar respondsToSelector:@selector(barTintColor)]) {
        // iOS7
        searchBar.barTintColor = [UIColor darkTextColor];
        [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    }
    searchBar.tintColor = [UIColor darkTextColor];
    
    self.findMeButton.layer.cornerRadius = 5.f;
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.delegate mapViewControllerDidLoad:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self.delegate mapViewControllerDidFinish:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)findMe:(id)sender
{
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 3141, 3141);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.mapView.showsUserLocation = YES;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

#pragma mark - MWSearchDisplayViewController methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.search cancel];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchText;
    request.region = self.mapView.region;
    self.search = [[MKLocalSearch alloc] initWithRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        self.searchResults = response.mapItems;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

/*
- (void)searchDisplayControllerDidBeginSearch:(MWSearchDisplayViewController *)controller
{
    [self.search cancel];
    
    UITableView *tableView = controller.searchResultsTableView;
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 60)];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor grayColor];
    activityIndicator.center = loadingView.center;
    [activityIndicator startAnimating];
    [loadingView addSubview:activityIndicator];
    tableView.tableFooterView = loadingView;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = controller.searchBar.text;
    request.region = self.mapView.region;
    self.search = [[MKLocalSearch alloc] initWithRequest:request];
    [self.search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        self.searchResults = response.mapItems;
        [controller.searchResultsTableView reloadData];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }];
}

- (void)searchDisplayController:(MWSearchDisplayViewController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView setSeparatorInset:UIEdgeInsetsZero];
}
*/

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.searchResults count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    MKMapItem *mapItem = (MKMapItem *)self.searchResults[indexPath.row];
    
    cell.textLabel.text = mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", mapItem.placemark.locality, mapItem.placemark.country];
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *mapItem = self.searchResults[indexPath.row];
    BLLOG(@"%@, %f", mapItem.placemark, mapItem.placemark.region.radius);
    CLCircularRegion *cLRegion = (CLCircularRegion *)mapItem.placemark.region;
    MKCoordinateRegion region;
    if (cLRegion) {
        region = MKCoordinateRegionMakeWithDistance(cLRegion.center, cLRegion.radius, cLRegion.radius);
    }
    else {
        region = MKCoordinateRegionMakeWithDistance(mapItem.placemark.coordinate, 12000, 12000);
    }
    [self.searchDisplayController setActive:NO animated:YES];
    [self.mapView setRegion:region animated:YES];
}

@end
