//
//  DetailViewController.m
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/29/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import "DetailViewController.h"
#import "NetworkManager.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *realnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateAndCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyFatLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.usernameLabel.text = self.userData.userName;
    self.realnameLabel.text = self.userData.realName;
    int age = self.userData.age;
    if (age < 0) {
        self.ageLabel.text = @"--";
    } else {
        self.ageLabel.text = [NSString stringWithFormat:@"%d", age];
    }
    
    NSString *stateString = self.userData.state;
    NSString *countryString = self.userData.country;
    self.stateAndCountryLabel.text = [NSString stringWithFormat:@"%@, %@", stateString, countryString];
    
    self.cityLabel.text = self.userData.city;
    
    int heightInInches  = self.userData.heightInInches;
    self.heightLabel.text = [NSString stringWithFormat:@"%d'%d\"", heightInInches / 12, heightInInches % 12];
    
    int weightInPounds  = self.userData.weightInPounds;
    self.weightLabel.text = [NSString stringWithFormat:@"%d lbs", weightInPounds];

    int bodyFatPercent  = self.userData.bodyFatPercentage;
    self.bodyFatLabel.text = [NSString stringWithFormat:@"%d%%", bodyFatPercent];
    
    if(self.userProfilePic != nil) {
        self.profileImageView.image = self.userProfilePic;
    } else {
        self.profileImageView.image = [UIImage animatedImageNamed:@"spinner_image" duration:1.f];
        NSString *profileURL = self.userData.profilePicUrl;
        if (![profileURL isMemberOfClass:[NSNull class]]) {
            __weak typeof(self) weakSelf = self;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __typeof(self) strongSelf = weakSelf;
                    if(strongSelf) {
                        strongSelf.profileImageView.image = [UIImage imageWithData:data];
                    }
                });
            }];
        }
    }
    NSString *currentNote = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, self.userData.userId]];
    [self.noteTextView setText: currentNote];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveButtonPressed {
    [[NSUserDefaults standardUserDefaults] setObject:self.noteTextView.text forKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, self.userData.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserNoteUpdated" object:self userInfo:@{@"userId" : [NSNumber numberWithLong:self.userData.userId]}];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)clearButtonPressed {
    [self.noteTextView setText:@""];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, self.userData.userId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.noteTextView resignFirstResponder];
}

@end
