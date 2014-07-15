//
//  Post.h
//  Belloh
//
//  Created by Eric Webster on 12/20/2013.
//  Copyright (c) 2013 Eric Webster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface BLPost : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, copy) NSString *id;

- (void)setTimestampWithBSONId:(NSString *)BSONId;

@end
