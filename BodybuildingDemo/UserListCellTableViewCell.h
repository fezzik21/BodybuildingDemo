//
//  UserListCellTableViewCell.h
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/30/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateAndCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *noteButton;


@end
