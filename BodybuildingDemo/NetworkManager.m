//
//  NetworkManager.m
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/30/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
#import "UserObject.h"

@implementation NetworkManager

#define HOST_STRING @"http://107.170.231.93/member/?limit=%d&skip=%d&sort=%@"

-(void)getMembersSortedBy:(NSString *)sortType limit:(int)limit skip:(int)skip returnTo:(void (^)(NSArray *, int))inBlock {
    NSString *urlString = [NSString stringWithFormat:HOST_STRING,limit,skip,sortType];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __block int newSkipValue = skip + limit;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __typeof(self) strongSelf = weakSelf;
        int sanitizedRemoveCount = 0;
        NSArray *responseArray = (NSArray *)responseObject;
        NSMutableArray *sanitizedResult = [NSMutableArray arrayWithCapacity:[responseArray count]];
        for(int i = 0; i < [responseArray count]; ++i) {
            NSDictionary *dict = [responseArray objectAtIndex:i];
            UserObject *uo = [[UserObject alloc] initFromDictionary:dict];
            if([uo isValid]) {
                [sanitizedResult addObject:uo];
            } else {
                sanitizedRemoveCount++;
            }
        }
        
        if(sanitizedRemoveCount > 0) {
            if(strongSelf) {
                [strongSelf getMembersSortedBy:sortType limit:sanitizedRemoveCount skip:(skip + limit) returnTo:^(NSArray *result, int skipValueResult) {
                    [sanitizedResult addObjectsFromArray:result];
                    newSkipValue = skipValueResult;
                    inBlock((NSArray *)sanitizedResult, newSkipValue);
                }];
            }
        } else {
            inBlock((NSArray *)sanitizedResult, newSkipValue);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        inBlock(nil, 0);
    }];
    
    [operation start];
}

@end
