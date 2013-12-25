//
//  MainViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"
#import "BLPost.h"

@interface NewsViewController : UIViewController <MapViewControllerDelegate,UITableViewDataSource,UITableViewDelegate> {

    NSMutableArray *_posts;

}

+ (void)removeShadowImageFromNavBar:(UINavigationBar *)navBar;
- (void)addPost:(BLPost *)post;
- (void)removeAllPosts;
- (NSArray *)posts;

@end
