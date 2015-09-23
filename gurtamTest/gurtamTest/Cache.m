//
//  Cache.m
//  gurtamTest
//
//  Created by Hurbo Aliaksei on 9/23/15.
//  Copyright © 2015 Aliaksei Hurbo. All rights reserved.
//

#import "Cache.h"

@implementation Cache

+ (Cache *)sharedInstance
{
    static Cache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Cache alloc] init];
    });
    return instance;
}

- (void)saveCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0]
                           stringByAppendingPathComponent:@"cache.plist"];
    [self.cachedDictionary writeToFile: plistPath atomically:YES];
}

- (void)loadCache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *plistPath = [[paths objectAtIndex:0]
                           stringByAppendingPathComponent:@"cache.plist"];
    self.cachedDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (!self.cachedDictionary) {
        self.cachedDictionary = [NSMutableDictionary new];
        [self.cachedDictionary writeToFile:plistPath atomically:YES];
    }
}

@end
