//
//  Belloh.h
//  Belloh
//
//  Created by Eric Webster on 12/31/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "BLPost.h"
#import <MapKit/MKGeometry.h>

// NSLog extension which prints the name of the calling class and method
#define BLLOG(format,...) NSLog([NSString stringWithFormat:@"%%@->%%@ %@",format],NSStringFromClass([self class]),NSStringFromSelector(_cmd),##__VA_ARGS__)

@protocol BellohDelegate <NSObject>

@optional
- (void)loadingPostsSucceeded;
- (void)loadingPostsFailedWithError:(NSError *)error;

@end

@interface Belloh : NSObject

@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, weak) id<BellohDelegate> delegate;

- (id)initWithRegion:(MKCoordinateRegion)region;
- (NSUInteger)postCount;
- (void)removePostAtIndex:(NSUInteger)index;
- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index;
- (BLPost *)postAtIndex:(NSUInteger)index;
- (BLPost *)lastPost;
- (void)loadAndAppendOlderPosts;
- (void)loadPosts;
- (void)sendNewPost:(BLPost *)newPost completion:(void (^)(NSError *))completion;
- (void)removeAllPosts;
- (BOOL)isRemainingPosts;

@end
