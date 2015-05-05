//
//  NoteDetailViewController.m
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/30/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

#import "NoteDetailViewController.h"

@interface NoteDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *noteTextView;

@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.noteTextView setText:@"foo!"/*self.noteText*/];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
