//
//  Belloh.h
//  Belloh
//
//  Created by Eric Webster on 12/31/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <Belloh/BLPost.h>
#import <MapKit/MKGeometry.h>

// NSLog extension which prints the name of the calling class and method
#define BLLOG(format,...) NSLog([NSString stringWithFormat:@"%%@->%%@ %@",format],NSStringFromClass([self class]),NSStringFromSelector(_cmd),##__VA_ARGS__)

typedef void (^BLCompletionHandler)(void);

@interface Belloh : NSObject

@property (nonatomic, copy) BLCompletionHandler completionHandler;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, copy) NSString *filter;

- (id)initWithRegion:(MKCoordinateRegion)region completionHandler:(BLCompletionHandler)completionHandler;
- (NSUInteger)BL_postCount;
- (BLPost *)BL_postAtIndex:(NSUInteger)index;
- (BLPost *)BL_lastPost;
- (void)BL_loadAndAppendOlderPosts;
- (void)BL_loadPosts;
- (void)BL_sendNewPost:(BLPost *)newPost;

@end
