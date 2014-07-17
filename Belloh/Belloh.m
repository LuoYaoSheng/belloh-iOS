//
//  Belloh.m
//  Belloh
//
//  Created by Eric Webster on 12/31/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import "Belloh.h"
#import "NSObject+Classes.h"

enum {
    // TODO: possible bug with BLNoPostsRemaining etc.. not loading older posts correctly.
    BLNoPostsRemaining = 1,
    BLNoFilteredResultsRemaining = 2
};

static NSString *const BLMessageKeyName = @"message";
static NSString *const BLSignatureKeyName = @"signature";
static NSString *const BLLatitudeKeyName = @"lat";
static NSString *const BLLongitudeKeyName = @"lng";
static NSString *const BLIdentifierKeyName = @"_id";
static NSString *const BLThumbnailKeyName = @"thumb";

@implementation Belloh {

@private
    NSMutableArray *_posts;
    NSMutableArray *_filteredResults;
    int _remainingPosts;
    NSString *_loadUUID;
    
}

static NSString *apiBaseURLString = @"http://www.belloh.com";

- (id)init
{
    if (self = [super init]) {
        self->_posts = [NSMutableArray array];
    }
    return self;
}

- (id)initWithRegion:(MKCoordinateRegion)region
{
    if (self = [self init]) {
        self.region = region;
    }
    return self;
}

- (void)setFilter:(NSString *)filter
{
    if ([filter length] && ![self.filter isEqualToString:filter]) {
        self->_filteredResults = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(message CONTAINS[cd] %@) OR (signature CONTAINS[cd] %@)", filter, filter];
            NSArray *results = [self->_posts filteredArrayUsingPredicate:predicate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                BLLOG(@"results: %@", results);
                if ([results count]) {
                    self->_remainingPosts &= ~BLNoFilteredResultsRemaining;
                    self->_filteredResults = [results mutableCopy];
                    if ([self.delegate respondsToSelector:@selector(loadingPostsFinished)]) {
                        [self.delegate loadingPostsFinished];
                    }
                }
                else {
                    [self _BL_loadPostsForRegion:self.region filter:filter];
                }
            });
        });
    }
    else if ([filter length] == 0) {
        [self->_filteredResults removeAllObjects];
    }
    self->_filter = filter;
}

#pragma mark - Belloh Posts

- (NSMutableArray *)_BL_posts
{
    return [self.filter length] == 0 ? self->_posts : self->_filteredResults;
}

- (BLPost *)BL_postAtIndex:(NSUInteger)index
{
    return self._BL_posts[index];
}

- (BLPost *)BL_lastPost
{
    return [self._BL_posts lastObject];
}

- (void)_BL_appendPost:(BLPost *)post
{
    [self._BL_posts addObject:post];
}

- (void)_BL_insertPost:(BLPost *)post atIndex:(NSUInteger)index
{
    [self._BL_posts insertObject:post atIndex:index];
}

- (void)BL_removeAllPosts
{
    [self._BL_posts removeAllObjects];
}

- (NSUInteger)BL_postCount
{
    return [self._BL_posts count];
}

- (void)removePostAtIndex:(NSUInteger)index
{
    [self._BL_posts removeObjectAtIndex:index];
}

- (void)insertPost:(BLPost *)post atIndex:(NSUInteger)index
{
    [self._BL_posts insertObject:post atIndex:index];
}

#pragma mark - Belloh Posts Queries

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region
{
    CGFloat lat = region.center.latitude;
    CGFloat lon = region.center.longitude;
    CGFloat deltaLat = region.span.latitudeDelta/2;
    CGFloat deltaLon = region.span.longitudeDelta/2;
    static NSString *format = @"box%%5B0%%5D%%5B%%5D=%f&box%%5B0%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f&box%%5B1%%5D%%5B%%5D=%f";
    return [NSString stringWithFormat:format,lat-deltaLat,lon-deltaLon,lat+deltaLat,lon+deltaLon];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId
{
    NSString *regionQuery = [Belloh _BL_queryForRegion:region];
    static NSString *format = @"%@&elder_id=%@";
    return [NSString stringWithFormat:format, regionQuery, postId];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region filter:(NSString *)filter
{
    NSString *regionQuery = [Belloh _BL_queryForRegion:region];
    static NSString *format = @"%@&filter=%@";
    return [NSString stringWithFormat:format, regionQuery, filter];
}

+ (NSString *)_BL_queryForRegion:(MKCoordinateRegion)region lastPostId:(NSString *)postId filter:(NSString *)filter
{
    NSString *regionAndLastPostIdQuery = [Belloh _BL_queryForRegion:region lastPostId:postId];
    static NSString *format = @"%@&filter=%@";
    return [NSString stringWithFormat:format, regionAndLastPostIdQuery, filter];
}

- (BOOL)BL_isRemainingPosts
{
    BLLOG(@"%i, %i",self->_remainingPosts,self->_remainingPosts&BLNoPostsRemaining);
    
    if (self->_remainingPosts&BLNoPostsRemaining) {
        return NO;
    }
    else if (self.filter && self->_remainingPosts&BLNoFilteredResultsRemaining) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Belloh Posts Loading

- (void)BL_loadAndAppendOlderPosts
{
    if (![self BL_isRemainingPosts]) {
        return;
    }
    
    BLLOG(@"loading more posts...");
    BLPost *lastPost = [self BL_lastPost];
    NSString *lastPostId = lastPost.identifier;
    
    if (self.filter) {
        [self _BL_loadPostsForRegion:self.region lastPostId:lastPostId filter:self.filter];
    }
    else {
        [self _BL_loadPostsForRegion:self.region lastPostId:lastPostId];
    }
}

- (void)BL_loadPosts
{
    NSString *postFilter = self.filter;
    self.filter = nil;
    // First load posts then load filtered results.
    
    [self _BL_loadPostsForRegion:self.region completion:^(NSArray *posts){
        [self->_posts removeAllObjects];
        for (NSDictionary *dict in posts) {
            [self _BL_insertPostWithDictionary:dict atIndex:-1];
        }
        self.filter = postFilter;
    }];
}

- (void)_BL_loadPostsForRegion:(MKCoordinateRegion)region completion:(void (^)(NSArray *))completion
{
    [self _BL_loadPostsForQuery:[Belloh _BL_queryForRegion:region] completion:completion];
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
    [self _BL_loadPostsForQuery:query completion:^(NSArray *posts){
        for (NSDictionary *dict in posts) {
            [self _BL_insertPostWithDictionary:dict atIndex:-1];
        }
    }];
}

- (void)_BL_loadPostsForQuery:(NSString *)query completion:(void (^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        // Used to make sure only latest query is used.
        NSString *UUID = [[NSUUID UUID] UUIDString];
        self->_loadUUID = UUID;

        NSString *queryURLString = [NSString stringWithFormat:@"posts?%@", query];
        
        if (self.tag) {
            queryURLString = [NSString stringWithFormat:@"%@&tag=%@", queryURLString, self.tag];
        }
        
        NSURL *postsURL = [NSURL URLWithString:queryURLString relativeToURL:[NSURL URLWithString:apiBaseURLString]];
        NSData *postsData = [NSData dataWithContentsOfURL:postsURL];
        
        if (postsData == nil) {
            return BLLOG(@"data for %@ is nil. Check internet connection.", queryURLString);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![UUID isEqualToString:self->_loadUUID]) {
                return;
            }
            
            NSError *error;
            NSArray *postsArray = [NSJSONSerialization JSONObjectWithData:postsData options:0 error:&error];
            
            if (error) {
                return BLLOG(@"%@", error);
            }
            
            int num = (self.filter == nil ? BLNoPostsRemaining : BLNoFilteredResultsRemaining);
            if ([postsArray count] == 0) {
                self->_remainingPosts |= num;
            }
            else {
                self->_remainingPosts &= ~num;
            }
            
            if (completion) {
                completion(postsArray);
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
    post.message = [NSString sanitize:postDictionary[BLMessageKeyName]];
    post.signature = [NSString sanitize:postDictionary[BLSignatureKeyName]];
    post.latitude = [[NSNumber sanitize:postDictionary[BLLatitudeKeyName]] floatValue];
    post.longitude = [[NSNumber sanitize:postDictionary[BLLongitudeKeyName]] floatValue];
    post.hasThumbnail = [[NSNumber sanitize:postDictionary[BLThumbnailKeyName]] boolValue];
    post.identifier = [NSString sanitize:postDictionary[BLIdentifierKeyName]];
    [post setTimestampWithBSONId:post.identifier];
    
    static NSString *thumbnailURLFormat = @"http://s3.amazonaws.com/belloh/thumbs/%@.jpg";
    post.thumbnail = [NSString stringWithFormat:thumbnailURLFormat, post.identifier];
    
    if (signedIndex == -1) {
        [self _BL_appendPost:post];
    }
    else if (signedIndex < -1) {
        NSUInteger i = [self BL_postCount] + signedIndex;
        [self _BL_insertPost:post atIndex:i];
    }
    else {
        [self _BL_insertPost:post atIndex:signedIndex];
    }
}

#pragma mark - Belloh New Post

- (void)BL_sendNewPost:(BLPost *)newPost completion:(void (^)(void))completion
{
    NSURL *newPostURL = [NSURL URLWithString:apiBaseURLString];
    NSMutableURLRequest *newPostRequest = [NSMutableURLRequest requestWithURL:newPostURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    newPostRequest.HTTPMethod = @"POST";
    [newPostRequest setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    NSDictionary *postDictionary = @{BLMessageKeyName: newPost.message, BLSignatureKeyName: newPost.signature, BLLatitudeKeyName: @(newPost.latitude), BLLongitudeKeyName: @(newPost.longitude)};
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
         
         NSError *parseError;
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
         NSString *serverErrors = [dict valueForKey:@"errors"];
         
         if (serverErrors) {
             return BLLOG(@"server error: %@", serverErrors);
         }
         else if (parseError) {
             return BLLOG(@"parse error: %@", parseError);
         }
         
         BLLOG(@"%@",dict);
         
         [self _BL_insertPostWithDictionary:dict atIndex:0];
         
         if (completion) {
             completion();
         }
     }];
}

@end
