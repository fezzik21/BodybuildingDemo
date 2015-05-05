//
//  UserObject.m
//  BodybuildingDemo
//
//  Created by Adam Hunter on 5/1/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import "UserObject.h"

#define UO_KEY_REALNAME @"realName"
#define UO_KEY_USERNAME @"userName"
#define UO_KEY_BIRTHDAY @"birthday"
#define UO_KEY_STATE @"state"
#define UO_KEY_COUNTRY @"country"
#define UO_KEY_CITY @"city"
#define UO_KEY_HEIGHT @"height"
#define UO_KEY_WEIGHT @"weight"
#define UO_KEY_BODYFAT @"bodyfat"
#define UO_KEY_PROFILEPICURL @"profilePicUrl"
#define UO_KEY_USERID @"userId"

@implementation UserObject


-(UserObject *)initFromDictionary:(NSDictionary *)inDictionary {
    self = [super init];
    if (self) {
        self.realName = [inDictionary valueForKey:UO_KEY_REALNAME];
        if(self.realName != nil) {
            
            NSString *birthdayString =[inDictionary valueForKey:UO_KEY_BIRTHDAY];
            if ([birthdayString isMemberOfClass:[NSNull class]]) {
                self.age = -1;
            } else {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *birthday = [dateFormatter dateFromString:birthdayString];
                
                NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthday toDate:[NSDate date] options:0];
                self.age = (int)[ageComponents year];
            }
            
            self.state = [inDictionary valueForKey:UO_KEY_STATE];
            self.country = [inDictionary valueForKey:UO_KEY_COUNTRY];
            self.city = [inDictionary valueForKey:UO_KEY_CITY];
            self.profilePicUrl = [inDictionary valueForKey:UO_KEY_PROFILEPICURL];
            self.heightInInches = [[inDictionary valueForKey:UO_KEY_HEIGHT] intValue];
            self.weightInPounds = [[inDictionary valueForKey:UO_KEY_WEIGHT] intValue];
            self.bodyFatPercentage = [[inDictionary valueForKey:UO_KEY_BODYFAT] intValue];
        }
    }
    return self;
}

-(BOOL)isValid {
    return (self.realName != nil);
}

@end
