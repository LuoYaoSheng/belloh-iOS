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

#pragma mark - Belloh Posts

- (NSArray *)posts
{
    return self->_posts;
}

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

#pragma mark - Map View Controller Delegate

- (void)mapViewControllerDidFinish:(MapViewController *)controller
{
    MKCoordinateRegion region = [controller.mapView region];
    self.map.region = region;
    [self BLLoadPostsForRegion:region];
    [self BL_setNavBarTitleToLocationName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mapViewControllerDidLoad:(MapViewController *)controller
{
    [controller.mapView setRegion:self.map.region animated:NO];
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

- (void)createViewControllerDidPost:(BLPost *)post
{
    CLLocationCoordinate2D location = self.map.region.center;
    post.latitude = location.latitude;
    post.longitude = location.longitude;
    [self BLSendNewPost:post];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createViewControllerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Belloh Posts Queries

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

#pragma mark - Belloh Posts Loading

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
            return BLLOG(@"data for %@ is nil. Check internet connection.", queryURLString);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSError *error = nil;
            NSArray *postsArray = [NSJSONSerialization JSONObjectWithData:postsData options:0 error:&error];
            
            if (error) {
                return BLLOG(@"%@", error);
            }
            else if ([postsArray count] == 0) {
                self->_noRemainingPosts = YES;
            }
            else {
                self->_noRemainingPosts = NO;
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
    if (self->_noRemainingPosts) {
        return;
    }

    BLPost *lastPost = [self.posts lastObject];
    if (!lastPost) {
        return BLLOG(@"no posts loaded");
    }
    BLLOG(@"Load MORE");

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
        return BLLOG(@"data error: %@", error);
    }
    
    newPostRequest.HTTPBody = postData;
    [NSURLConnection sendAsynchronousRequest:newPostRequest queue:[NSOperationQueue mainQueue] completionHandler:
    ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    
        if (connectionError) {
            return BLLOG(@"connection error: %@", connectionError);
        }
        
        NSError *parseError = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        
        NSString *serverErrors = [dict valueForKey:@"errors"];
        if (serverErrors) {
            return BLLOG(@"server error: %@", serverErrors);
        }
        
        BLLOG(@"%@",dict);

        if (parseError) {
            return BLLOG(@"parse error: %@", parseError);
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
            return BLLOG(@"geocoding: %@", error);
        }
        
        CLPlacemark *placemark = placemarks[0];
        NSString *locationName;
        
        if (placemark.locality) {
            locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.country];
        }
        else {
            locationName = [NSString stringWithFormat:@"%@, %@", placemark.name, placemark.country];
        }
        
        UINavigationItem *item = self.navBar.topItem;
        item.title = locationName;
    }];
}

#pragma mark - Navigation Search Bar Delegate

- (void)searchInitiated:(NSString *)searchQuery
{
    self.postsFilter = searchQuery;
    BLLOG(@"Filter: %@", searchQuery);

    [self BLLoadPostsForRegion:self.map.region filter:searchQuery];
}

- (void)searchCancelled
{
    if (self.postsFilter) {
        self.postsFilter = nil;
        [self BLLoadPostsForRegion:self.map.region];
    }
}

@end
