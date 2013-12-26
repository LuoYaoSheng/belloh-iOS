//
//  MainViewController.h
//  Belloh
//
//  Created by Eric Webster on 12/18/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "MapViewController.h"
#import "CreateViewController.h"
#import "BLPost.h"

@interface NewsViewController : UIViewController <MapViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,CreateViewControllerDelegate> {

    NSMutableArray *_posts;

}

- (void)appendPost:(BLPost *)post;
- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index;
- (void)removeAllPosts;
- (NSArray *)posts;

@end
