//
//  MainViewController.m
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsTableViewCell.h"
#import "BLMap.h"

@interface NewsViewController ()

@property (nonatomic, strong) BLMap *map;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy) NSString *postsFilter;

@property (nonatomic, weak) IBOutlet NavigationSearchBar *navBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self->_posts = [NSMutableArray array];
    self.geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(30.155960086365063,0);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02167,0.03193);
    
    self.map = [BLMap mapWithRegion:MKCoordinateRegionMake(locationCoordinate, span)];
    [self BLLoadPostsForRegion:self.map.region];
    [self BL_setNavBarTitleToLocationName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Belloh Posts

- (void)appendPost:(BLPost *)post
{
    [self->_posts addObject:post];
}

- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index
{
    [self->_posts insertObject:post atIndex:index];
}

- (void)removeAllPosts
{
    [self->_posts removeAllObjects];
}

- (NSArray *)posts
{
    return self->_posts;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row >= [self.posts count]-1) {
        NSLog(@"Load MORE");
        [self BLLoadOlderPosts];
    }
    
    BLPost *post = self.posts[indexPath.row];
    
    [cell setContent:post];

    return cell;
}


#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLPost *post = self.posts[indexPath.row];

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

#pragma mark - Map View

- (void)mapViewControllerDidFinish:(MapViewController *)controller
{
    MKCoordinateRegion region = [controller.mapView region];
    self.map.region = region;
    [self BLLoadPostsForRegion:region];
    [self BL_setNavBarTitleToLocationName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = [segue identifier];
    if ([identifier isEqualToString:@"showMap"]) {
        [[segue destinationViewController] setBLRegion:self.map.region];
        [[segue destinationViewController] setDelegate:self];
    }
    else if ([identifier isEqualToString:@"newPost"]) {
        [[segue destinationViewController] setBLLocation:self.map.region.center];
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Create View

- (void)createViewControllerDidPost:(BLPost *)post
{
    NSLog(@"Send Post");
    [self BLSendNewPost:post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createViewControllerDidCancel
{
    NSLog(@"Cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Belloh Posts Querying

+ (NSString *)BL_queryForRegion:(MKCoordinateRegion)region
{
    CGFloat lat = region.center.latitude;
    CGFloat lon = region.center.longitude;
    CGFloat deltaLat = region.span.latitudeDelta/2;
    CGFloat deltaLon = region.span.longitudeDelta/2;
    return [NSString stringWithFormat:@"box%%5B0%%5D%%5B%%5D=%f&box%%5B0%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f",lat-deltaLat,lon-deltaLon,lat+deltaLat,lon+deltaLon];
}

+ (NSString *)BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId
{
    NSString *regionQuery = [NewsViewController BL_queryForRegion:region];
    return [NSString stringWithFormat:@"%@&elder_id=%@", regionQuery, postId];
}

+ (NSString *)BL_queryForRegion:(MKCoordinateRegion)region filter:(NSString *)filter
{
    NSString *regionQuery = [NewsViewController BL_queryForRegion:region];
    return [NSString stringWithFormat:@"%@&filter=%@", regionQuery, filter];
}

+ (NSString *)BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter
{
    NSString *regionAndLastPostIdQuery = [NewsViewController BL_queryForRegion:region lastPostId:postId];
    return [NSString stringWithFormat:@"%@&filter=%@", regionAndLastPostIdQuery, filter];
}

- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region
{
    [self removeAllPosts];
    [self BL_loadPosts:[NewsViewController BL_queryForRegion:region]];
}

- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId
{
    [self BL_loadPosts:[NewsViewController BL_queryForRegion:region lastPostId:postId]];
}

- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region filter:(NSString *)filter
{
    [self removeAllPosts];
    [self BL_loadPosts:[NewsViewController BL_queryForRegion:region filter:filter]];
}

- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter
{
    [self BL_loadPosts:[NewsViewController BL_queryForRegion:region lastPostId:postId filter:filter]];
}

- (void)BL_loadPosts:(NSString *)query
{
    static NSString *postsURLString = @"http://www.belloh.com/posts";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *queryURLString = [NSString stringWithFormat:@"%@?%@",postsURLString,query];
        NSURL *postsURL = [NSURL URLWithString:queryURLString];
        NSData *postsData = [NSData dataWithContentsOfURL:postsURL];
        
        if (postsData == nil) {
            return NSLog(@"Data for %@ is nil. Check internet connection.",queryURLString);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSError *error = nil;
            NSArray *postsArray = [NSJSONSerialization JSONObjectWithData:postsData options:0 error:&error];
            
            if (error) {
                return NSLog(@"%@",error);
            }
            else if ([postsArray count] == 0) {
                return;
            }
            
            for (NSDictionary *dict in postsArray) {
                [self BLInsertPostWithDictionary:dict atIndex:-1];
            }
            [self.tableView reloadData];
        });
    });
}

- (void)BLLoadOlderPosts
{
    BLPost *lastPost = [self.posts lastObject];
    NSString *lastPostId = lastPost.id;
    if (self.postsFilter) {
        [self BLLoadPostsForRegion:self.map.region lastPostId:lastPostId filter:self.postsFilter];
    }
    else {
        [self BLLoadPostsForRegion:self.map.region lastPostId:lastPostId];
    }
}

- (void)BLInsertPostWithDictionary:(NSDictionary *)postDictionary atIndex:(NSInteger)index
{
    BLPost *post = [[BLPost alloc] init];
    
    post.message = [postDictionary valueForKey:@"message"];
    post.signature = [postDictionary valueForKey:@"signature"];
    post.latitude = [[postDictionary objectForKey:@"lat"] floatValue];
    post.longitude = [[postDictionary objectForKey:@"lng"] floatValue];
    post.id = [postDictionary valueForKey:@"_id"];
    [post setTimestampWithBSONId:post.id];
    post.hasThumbnail = [[postDictionary objectForKey:@"thumb"] boolValue];
    
    if (post.hasThumbnail) {
        static NSString *thumbnailURLFormat = @"http://s3.amazonaws.com/belloh/thumbs/%@.jpg";
        NSString *URLString = [NSString stringWithFormat:thumbnailURLFormat, post.id];
        NSURL *imageURL = [NSURL URLWithString:URLString];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                post.thumbnail = [UIImage imageWithData:imageData];
                [self.tableView reloadData];
            });
        });
    }
    else {
        post.thumbnail = nil;
    }
    
    if (index < 0) {
        [self appendPost:post];
    }
    else {
        [self insertPost:post atIndex:index];
    }
}

#pragma mark - Belloh New Post

- (void)BLSendNewPost:(BLPost *)newPost
{
    NSURL *newPostURL = [NSURL URLWithString:@"http://www.belloh.com/"];
    NSMutableURLRequest *newPostRequest = [NSMutableURLRequest requestWithURL:newPostURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    newPostRequest.HTTPMethod = @"POST";
    [newPostRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];

    NSDictionary *postDictionary = @{@"message": newPost.message, @"signature": newPost.signature, @"lat": @(newPost.latitude), @"lng": @(newPost.longitude)};
    NSError *error = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDictionary options:0 error:&error];

    if (error) {
        return NSLog(@"BL_sendNewPost data error: %@",error);
    }
    
    newPostRequest.HTTPBody = postData;
    [NSURLConnection sendAsynchronousRequest:newPostRequest queue:[NSOperationQueue mainQueue] completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
        if (connectionError) {
            return NSLog(@"BL_sendNewPost connection error: %@",connectionError);
        }
        
        NSError *parseError = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        NSString *serverErrors = [dict valueForKey:@"errors"];
        if (serverErrors) {
            return NSLog(@"BL_sendNewPost server error: %@",serverErrors);
        }
        
        NSLog(@"%@",dict);

        if (parseError) {
            return NSLog(@"BL_sendNewPost parse error: %@",parseError);
        }
        
        [self BLInsertPostWithDictionary:dict atIndex:0];
        [self.tableView reloadData];
    }];
}

#pragma mark - Geocoding

- (void)BL_setNavBarTitleToLocationName
{
    CLLocationCoordinate2D center = self.map.region.center;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            return NSLog(@"Error geocoding: %@", error);
        }
        
        CLPlacemark *placemark = placemarks[0];
        NSString *locationName;
        
        if (placemark.locality) {
            locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.country];
        }
        else {
            locationName = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
        }
        
        UINavigationItem *item = self.navBar.items[0];
        item.title = locationName;
    }];
}

#pragma mark - Navigation Search Bar

- (void)searchInitiated:(NSString *)searchQuery
{
    self.postsFilter = searchQuery;
    [self BLLoadPostsForRegion:self.map.region filter:self.postsFilter];
}

- (void)searchCancelled
{
    if (self.postsFilter) {
        self.postsFilter = nil;
        [self BLLoadPostsForRegion:self.map.region];
    }
}

/*
- (void)BL_navigationBarSetSearchBar:(UINavigationBar *)navBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.placeholder = @"Filter posts";
    searchBar.delegate = self;

//    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
//    searchBarView.autoresizingMask = 0;
//    [searchBarView addSubview:searchBar];

    UINavigationItem *item = navBar.items[0];
    item.titleView = searchBar;

    [item.titleView becomeFirstResponder];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearch)];

    self.searchButton = item.leftBarButtonItem;
    [item setLeftBarButtonItem:cancelBarButton animated:YES];
    //[searchBar setShowsCancelButton:YES animated:YES];
}

- (IBAction)displaySearchBar:(id)sender
{
    [self BL_navigationBarSetSearchBar:self.navBar];
}

- (void)cancelSearch
{
    if (self.postsFilter) {
        self.postsFilter = nil;
        [self BL_loadPostsForRegion:self.map.region];
    }
    UINavigationItem *item = self.navBar.items[0];
    item.titleView = nil;
    [item setLeftBarButtonItem:self.searchButton animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Filter: %@",searchBar.text);
    self.postsFilter = searchBar.text;
    [self BL_loadPostsForRegion:self.map.region filter:self.postsFilter];
    [searchBar resignFirstResponder];
}
*/
@end
