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

// NSLog extension which prints the name of the calling class and method
#define BLLOG(format,...) NSLog([NSString stringWithFormat:@"%%@->%%@ %@",format],self.class,NSStringFromSelector(_cmd),##__VA_ARGS__)

@protocol Belloh <CreateViewControllerDelegate,MapViewControllerDelegate,NavigationSearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@interface NewsViewController : UIViewController<Belloh> {

@private
    NSMutableArray *_posts;
    BOOL _noRemainingPosts;

}

- (void)appendPost:(BLPost *)post;
- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index;
- (NSArray *)posts;
- (void)removeAllPosts;
- (void)BLInsertPostWithDictionary:(NSDictionary *)postDictionary atIndex:(NSInteger)index;
- (void)BLLoadOlderPosts;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region filter:(NSString *)filter;
- (void)BLLoadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter;
- (void)BLSendNewPost:(BLPost *)newPost;

@end
