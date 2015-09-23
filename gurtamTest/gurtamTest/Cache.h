//
//  Cache.h
//  gurtamTest
//
//  Created by Hurbo Aliaksei on 9/23/15.
//  Copyright © 2015 Aliaksei Hurbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

@property (strong, nonatomic) NSMutableDictionary *cachedDictionary;

+ (Cache *)sharedInstance;
- (void)loadCache;
- (void)saveCache;

@end
