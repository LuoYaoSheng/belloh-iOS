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

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) BLMap *map;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation NewsViewController

+ (void)removeShadowImageFromNavBar:(UINavigationBar *)navBar
{
    [navBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];    
    [navBar setShadowImage:[UIImage new]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.posts = [NSMutableArray array];
    self.geocoder = [[CLGeocoder alloc] init];

    [NewsViewController removeShadowImageFromNavBar:self.navBar];
    
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(30.155960086365063,0);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02167,0.03193);
    
    self.map = [BLMap mapWithRegion:MKCoordinateRegionMake(locationCoordinate, span)];
    [self BL_loadPostsForRegion:self.map.region];
    [self BL_setNavBarTitleToLocationName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.posts removeAllObjects];
    [self BL_loadPostsForRegion:region];
    [self BL_setNavBarTitleToLocationName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMap"])
    {
        [[segue destinationViewController] setRegion:self.map.region];
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Helper Methods

+ (NSString *)BL_boxQueryForRegion:(MKCoordinateRegion)region
{
    CGFloat lat = region.center.latitude;
    CGFloat lon = region.center.longitude;
    CGFloat deltaLat = region.span.latitudeDelta/2;
    CGFloat deltaLon = region.span.longitudeDelta/2;
    return [NSString stringWithFormat:@"box%%5B0%%5D%%5B%%5D=%f&box%%5B0%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f",lat-deltaLat,lon-deltaLon,lat+deltaLat,lon+deltaLon];
}

- (void)BL_loadPostsForRegion:(MKCoordinateRegion)region
{
    [self BL_loadPosts:[NewsViewController BL_boxQueryForRegion:region]];
}

- (void)BL_loadPosts:(NSString *)query
{
    static NSString *postsURLString = @"http://www.belloh.com/posts";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *queryURLString = [NSString stringWithFormat:@"%@?%@",postsURLString,query];
        NSURL *postsURL = [NSURL URLWithString:queryURLString];
        NSData *postsData = [NSData dataWithContentsOfURL:postsURL];
        
        if (postsData == nil)
        {
            return NSLog(@"Data for %@ is nil. Check internet connection.",queryURLString);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            NSError *error = nil;
            NSArray *postsArray = [NSJSONSerialization JSONObjectWithData:postsData options:0 error:&error];
            
            if (error)
            {
                return NSLog(@"%@",error);
            }
            
            for (NSDictionary *dict in postsArray)
            {
                BLPost *post = [[BLPost alloc] init];
                
                post.message = [dict valueForKey:@"message"];
                post.signature = [dict valueForKey:@"signature"];
                post.latitude = [[dict objectForKey:@"lat"] floatValue];
                post.longitude = [[dict objectForKey:@"lon"] floatValue];
                                
                NSString *postID = [dict valueForKey:@"_id"];
                
                [post setTimestampWithBSONId:postID];

                id hasThumb = [dict objectForKey:@"thumb"];
                post.hasThumbnail = [hasThumb boolValue];
                
                if (post.hasThumbnail)
                {
                    NSString *URLString = [NSString stringWithFormat:@"http://s3.amazonaws.com/belloh/thumbs/%@.jpg",postID];
                    NSURL *imageURL = [NSURL URLWithString:URLString];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            post.thumbnail = [UIImage imageWithData:imageData];
                            [self.tableView reloadData];
                        });
                    });
                }
                else
                {
                    post.thumbnail = nil;
                }
                
                [self.posts addObject:post];
            }
            [self.tableView reloadData];
        });
    });
}

- (void)BL_setNavBarTitleToLocationName
{
    CLLocationCoordinate2D center = self.map.region.center;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if (error)
        {
            return NSLog(@"Error geocoding: %@",error);
        }
        
        CLPlacemark *placemark = placemarks[0];
        NSString *locationName = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.country];
        UINavigationItem *item = self.navBar.items[0];
        item.title = locationName;
    }];
}

@end
