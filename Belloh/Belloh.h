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

typedef void (^BLCompletionHandler)(void);

@protocol BellohDelegate <NSObject>

@optional
- (void)loadingPostsFinished;

@end

@interface Belloh : NSObject

@property (nonatomic, copy) BLCompletionHandler completionHandler;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, weak) id<BellohDelegate> delegate;

- (id)initWithRegion:(MKCoordinateRegion)region completionHandler:(BLCompletionHandler)completionHandler;
- (NSUInteger)BL_postCount;
- (void)removePostAtIndex:(NSUInteger)index;
- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index;
- (BLPost *)BL_postAtIndex:(NSUInteger)index;
- (BLPost *)BL_lastPost;
- (void)BL_loadAndAppendOlderPosts;
- (void)BL_loadPosts;
- (void)BL_sendNewPost:(BLPost *)newPost;
- (void)BL_removeAllPosts;

@end
