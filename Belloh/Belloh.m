//
//  Belloh.m
//  Belloh
//
//  Created by Eric Webster on 12/31/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "Belloh.h"

@implementation Belloh {
    
@private
    NSMutableArray *_posts;
    BOOL _noRemainingPosts;
    
}

- (id)init
{
    if (self = [super init]) {
        self->_posts = [NSMutableArray array];
    }
    return self;
}

- (id)initWithRegion:(MKCoordinateRegion)region completionHandler:(BLCompletionHandler)completionHandler
{
    if (self = [self init]) {
        self.completionHandler = completionHandler;
        self.region = region;
    }
    return self;
}

#pragma mark - Belloh Posts

- (BLPost *)BL_postAtIndex:(NSUInteger)index
{
    return self->_posts[index];
}

- (BLPost *)BL_lastPost
{
    return [self->_posts lastObject];
}

- (void)_BL_appendPost:(BLPost *)post
{
    [self->_posts addObject:post];
}

- (void)_BL_insertPost:(BLPost *)post atIndex:(NSUInteger)index
{
    [self->_posts insertObject:post atIndex:index];
}

- (void)BL_removeAllPosts
{
    [self->_posts removeAllObjects];
}

- (NSUInteger)BL_postCount
{
    return [self->_posts count];
}

#pragma mark - Belloh Posts Queries

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region
{
    CGFloat lat = region.center.latitude;
    CGFloat lon = region.center.longitude;
    CGFloat deltaLat = region.span.latitudeDelta/2;
    CGFloat deltaLon = region.span.longitudeDelta/2;
    return [NSString stringWithFormat:@"box%%5B0%%5D%%5B%%5D=%f&box%%5B0%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f",lat-deltaLat,lon-deltaLon,lat+deltaLat,lon+deltaLon];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId
{
    NSString *regionQuery = [Belloh _BL_queryForRegion:region];
    return [NSString stringWithFormat:@"%@&elder_id=%@", regionQuery, postId];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region filter:(NSString *)filter
{
    NSString *regionQuery = [Belloh _BL_queryForRegion:region];
    return [NSString stringWithFormat:@"%@&filter=%@", regionQuery, filter];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter
{
    NSString *regionAndLastPostIdQuery = [Belloh _BL_queryForRegion:region lastPostId:postId];
    return [NSString stringWithFormat:@"%@&filter=%@", regionAndLastPostIdQuery, filter];
}

#pragma mark - Belloh Posts Loading

- (void)BL_loadAndAppendOlderPosts
{
    if (self->_noRemainingPosts) {
        return;
    }
    
    BLPost *lastPost = [self BL_lastPost];
    
    NSString *lastPostId = lastPost.id;
    NSString *postFilter = self.filter;
    if (postFilter) {
        [self _BL_loadPostsForRegion:self.region lastPostId:lastPostId filter:postFilter];
    }
    else {
        [self _BL_loadPostsForRegion:self.region lastPostId:lastPostId];
    }
}

- (void)BL_loadPosts
{
    [self BL_removeAllPosts];
    NSString *postFilter = self.filter;
    if (postFilter) {
        [self _BL_loadPostsForRegion:self.region filter:postFilter];
    }
    else {
        [self _BL_loadPostsForRegion:self.region];
    }
}

- (void)_BL_loadPostsForRegion:(MKCoordinateRegion)region
{
    [self _BL_loadPostsForQuery:[Belloh _BL_queryForRegion:region]];
}

- (void)_BL_loadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId
{
    [self _BL_loadPostsForQuery:[Belloh _BL_queryForRegion:region lastPostId:postId]];
}

- (void)_BL_loadPostsForRegion:(MKCoordinateRegion)region filter:(NSString *)filter
{
    [self _BL_loadPostsForQuery:[Belloh _BL_queryForRegion:region filter:filter]];
}

- (void)_BL_loadPostsForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter
{
    [self _BL_loadPostsForQuery:[Belloh _BL_queryForRegion:region lastPostId:postId filter:filter]];
}

- (void)_BL_loadPostsForQuery:(NSString *)query
{
    static NSString *postsURLString = @"http://www.belloh.com/posts";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *queryURLString = [NSString stringWithFormat:@"%@?%@",postsURLString,query];
        
        if (self.tag) {
            queryURLString = [NSString stringWithFormat:@"%@&tag=%@",queryURLString,self.tag];
        }
        
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
                [self _BL_insertPostWithDictionary:dict atIndex:-1];
            }
            
            if ([self.delegate respondsToSelector:@selector(loadingPostsFinished)]) {
                [self.delegate loadingPostsFinished];
            }
        });
    });
}

- (void)_BL_insertPostWithDictionary:(NSDictionary *)postDictionary atIndex:(NSInteger)signedIndex
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
                self.completionHandler();
            });
        });
    }
    else {
        post.thumbnail = nil;
    }
    
    if (signedIndex == -1) {
        [self _BL_appendPost:post];
    }
    else if (signedIndex < -1) {
        NSUInteger i = [self BL_postCount]+signedIndex;
        [self _BL_insertPost:post atIndex:i];
    }
    else {
        [self _BL_insertPost:post atIndex:signedIndex];
    }
}

#pragma mark - Belloh New Post

- (void)BL_sendNewPost:(BLPost *)newPost
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
         
         [self _BL_insertPostWithDictionary:dict atIndex:0];
         self.completionHandler();
     }];
}

@end
