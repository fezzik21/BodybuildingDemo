//
//  NetworkManager.h
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/30/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NM_SORT_REALNAME_ASCENDING @"realName%20ASC"
#define NM_SORT_AGE_ASCENDING @"birthday%20DESC"

#define NM_USER_DEFAULTS_NOTE_KEY @"BBDemo_Note_%ld"

@interface NetworkManager : NSObject

-(void)getMembersSortedBy:(NSString *)sortType limit:(int)limit skip:(int)skip returnTo:(void (^)(NSArray *, int))inBlock;

@end
