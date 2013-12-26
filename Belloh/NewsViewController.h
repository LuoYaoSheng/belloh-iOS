//
//  MainViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"
#import "CreateViewController.h"
#import "NavigationSearchBar.h"
#import "BLPost.h"

@interface NewsViewController : UIViewController <MapViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,CreateViewControllerDelegate,NavigationSearchBarDelegate> {

    NSMutableArray *_posts;

}

- (void)appendPost:(BLPost *)post;
- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index;
- (void)removeAllPosts;
- (NSArray *)posts;
- (void)BLSendNewPost:(BLPost *)newPost;
- (void)BLInsertPostWithDictionary:(NSDictionary *)postDictionary atIndex:(NSInteger)index;
- (void)BLLoadOlderPosts;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region filter:(NSString *)filter;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter;

@end
