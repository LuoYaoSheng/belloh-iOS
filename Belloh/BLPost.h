//
//  Post.h
//  Belloh
//
//  Created by Eric Webster on 12/20/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLPost : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *signature;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

//@property (nonatomic, strong) NSString *id;

- (void)setTimestampWithBSONId:(NSString *)BSONId;

@end
