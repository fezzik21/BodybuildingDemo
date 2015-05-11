//
//  UserObject.h
//  BodybuildingDemo
//
//  Created by Adam Hunter on 5/1/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject

@property (strong, nonatomic) NSString *realName;
@property (strong, nonatomic) NSString *userName;
@property (assign, nonatomic) int age;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) int heightInInches;
@property (assign, nonatomic) int weightInPounds;
@property (assign, nonatomic) int bodyFatPercentage;
@property (strong, nonatomic) NSString *profilePicUrl;
@property (assign, nonatomic) long userId;

-(UserObject *)initFromDictionary:(NSDictionary *)inDictionary;
-(BOOL)isValid;

@end
