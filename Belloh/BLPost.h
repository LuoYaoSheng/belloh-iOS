//
//  Post.h
//  Belloh
//
//  Created by Eric Webster on 12/20/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

@interface BLPost : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, copy) NSString *id;

- (void)setTimestampWithBSONId:(NSString *)BSONId;

@end
