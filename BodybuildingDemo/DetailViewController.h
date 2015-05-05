//
//  DetailViewController.h
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/29/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserObject.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) UserObject *userData;
@property (strong, nonatomic) UIImage *userProfilePic;

@end
