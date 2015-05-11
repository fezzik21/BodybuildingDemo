//
//  UserListViewController.m
//  BodybuildingDemo
//
//  Created by Adam Hunter on 4/29/15.
//  Copyright (c) 2015 Adam Hunter. All rights reserved.
//

//To do:
//Name field is too long for content (all of them could have this problem)
//Removing redundant code, change variable names, etc
//More sanity checking on the returned users
//Take a few string constants and turn them into constants
//Improve the layout of the "Sort by" buttons
//Improve visual design of popup note

#import "UserListViewController.h"
#import "NetworkManager.h"
#import "UserListCellTableViewCell.h"
#import "AFNetworking.h"
#import "DetailViewController.h"
#import "NoteDetailViewController.h"

#define LOAD_PER_REQUEST 10

#define SORT_TYPE_NAME 0
#define SORT_TYPE_AGE 1

#define SEGUE_TO_DETAIL_VIEW_ID @"SegueToDetailView"

@interface UserListViewController ()

@property (weak, nonatomic) IBOutlet UIButton *sortByNameButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByAgeButton;
@property (weak, nonatomic) IBOutlet UITableView *userListTableView;

@property (weak, nonatomic) IBOutlet UIView *noteDisplayParentView;
@property (weak, nonatomic) IBOutlet UITextView *noteDisplayTextView;
@property (weak, nonatomic) IBOutlet UIButton *noteDisplayDoneButton;

@property (strong, nonatomic) NSMutableArray *tableData;
@property (assign, nonatomic) int skipValue;
@property (strong, nonatomic) NetworkManager *networkManager;

@property (assign, nonatomic) BOOL dataRequestPending;

@property (assign, nonatomic) int currentSortType;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableData = nil;
    self.skipValue = 0;
    
    self.dataRequestPending = NO;
    self.currentSortType = SORT_TYPE_NAME;
    self.networkManager = [[NetworkManager alloc] init];
    [self loadNewData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userNoteUpdated:) name:@"UserNoteUpdated" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userNoteUpdated:(NSNotification *) notification {
    long userIdUpdated = [[notification.userInfo objectForKey: @"userId"] longValue];
    for(int i = 0; i < [self.tableData count]; ++i) {
        if (((UserObject *)[self.tableData objectAtIndex:i]).userId == userIdUpdated) {
            UserListCellTableViewCell *cell = (UserListCellTableViewCell*)[self.userListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            NSString *currentNote = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, userIdUpdated]];
            if((currentNote == nil) || ([currentNote isEqualToString:@""])) {
                cell.noteButton.hidden = YES;
            } else {
                cell.noteButton.hidden = NO;
            }
        }
    }
}

- (void)loadNewData {
    if(self.tableData == nil) {
        self.tableData = [NSMutableArray arrayWithCapacity:LOAD_PER_REQUEST];
    }
    if (!self.dataRequestPending) {
        self.dataRequestPending = YES;
        __weak typeof(self) weakSelf = self;
        [self.networkManager getMembersSortedBy:(self.currentSortType == SORT_TYPE_NAME ? NM_SORT_REALNAME_ASCENDING : NM_SORT_AGE_ASCENDING)
                                          limit:LOAD_PER_REQUEST
                                           skip:self.skipValue
                                       returnTo:^(NSArray *result, int newSkipValue) {
                                           __typeof(self) strongSelf = weakSelf;
                                           long startCell = [self.tableData count];
                                           if(strongSelf) {
                                               if(result == nil) {
                                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                       message:@"Error Retrieving User List - Check Network Connection"
                                                                                                      delegate:self
                                                                                             cancelButtonTitle:@"Retry"
                                                                                             otherButtonTitles:nil];
                                                   [alertView show];
                                                   strongSelf.dataRequestPending = NO;
                                               } else {
                                                   strongSelf.skipValue = newSkipValue;
                                                   [strongSelf.tableData addObjectsFromArray:result];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[result count]];
                                                       for(int i = 0; i < [result count]; ++i) {
                                                           NSIndexPath *path = [NSIndexPath indexPathForRow:i + startCell inSection:0];
                                                           [paths addObject:path];
                                                       }
                                                       [strongSelf.userListTableView insertRowsAtIndexPaths:paths withRowAnimation:   UITableViewRowAnimationFade];
                                                       strongSelf.dataRequestPending = NO;
                                                       //This call is for the startup case where 10 rows did not fill the screen
                                                       [self performSelector:@selector(checkForScreenFull) withObject:nil afterDelay:0.5f];
                                                   });
                                               }
                                           }
                                       }];
    }
}

- (void)checkForScreenFull {
    [self scrollViewDidEndDragging:(UIScrollView*)self.userListTableView willDecelerate:NO];
}

- (IBAction)sortByNameButtonTapped {
    if(self.currentSortType != SORT_TYPE_NAME) {
        self.currentSortType = SORT_TYPE_NAME;
        self.tableData = nil;
        self.skipValue = 0;
        [self.userListTableView reloadData];
        [self loadNewData];
    }
}

- (IBAction)sortByAgeButtonTapped {
    if(self.currentSortType != SORT_TYPE_AGE) {
        self.currentSortType = SORT_TYPE_AGE;
        self.tableData = nil;
        self.skipValue = 0;
        [self.userListTableView reloadData];
        [self loadNewData];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.tableData == nil) {
        return 0;
    } else {
        return [self.tableData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"UserListCell";
    
    UserListCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:nil] forCellReuseIdentifier:simpleTableIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    
    cell.usernameLabel.text = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).realName;
    int age = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).age;
    if (age < 0) {
        cell.ageLabel.text = @"--";
    } else {
        cell.ageLabel.text = [NSString stringWithFormat:@"%d", age];
    }
    
    NSString *stateString = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).state;
    NSString *countryString = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).country;
    cell.stateAndCountryLabel.text = [NSString stringWithFormat:@"%@, %@", stateString, countryString];
    
    cell.cityLabel.text = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).city;

    NSString *profileURL = ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).profilePicUrl;
    if (![profileURL isMemberOfClass:[NSNull class]]) {
        cell.profileImageView.image = [UIImage animatedImageNamed:@"spinner_image" duration:1.f];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:profileURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.profileImageView.image = [UIImage imageWithData:data];
            });
        }];
    }
    
    [cell.noteButton addTarget:self action:@selector(noteButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noteButton setTag:indexPath.row];
    
    
    NSString *currentNote = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, ((UserObject *)[self.tableData objectAtIndex:indexPath.row]).userId]];
    if((currentNote == nil) || ([currentNote isEqualToString:@""])) {
        cell.noteButton.hidden = YES;
    }
    return cell;
}

- (void)noteButtonPushed:(id)sender {
    long row = ((UIButton *)sender).tag;
    long userId = ((UserObject *)[self.tableData objectAtIndex:row]).userId;
    NSString *currentNote = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:NM_USER_DEFAULTS_NOTE_KEY, userId]];
    
    self.noteDisplayParentView.alpha = 0.f;
    self.noteDisplayParentView.hidden = NO;
    [self.noteDisplayTextView setText: currentNote];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.noteDisplayParentView.alpha = 1.0f;
    }];
}

- (IBAction)noteDisplayDoneButtonPushed {
    [UIView animateWithDuration:0.2f animations:^{
        self.noteDisplayParentView.alpha = 0.0f;
    } completion:^(BOOL completed){
        self.noteDisplayParentView.hidden = YES;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *pic = ((UserListCellTableViewCell *)[self.userListTableView cellForRowAtIndexPath:indexPath]).profileImageView.image;
    NSArray *detailData =[NSArray arrayWithObjects: [self.tableData objectAtIndex:indexPath.row], pic, nil];
    [self performSegueWithIdentifier:SEGUE_TO_DETAIL_VIEW_ID sender:detailData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        [self loadNewData];
    }
}

#pragma mark - Segues


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"NoteDetailSegue"]) {
        ((NoteDetailViewController *)[segue destinationViewController]).noteText = sender;
    } else if([[segue identifier] isEqualToString:SEGUE_TO_DETAIL_VIEW_ID]) {
        ((DetailViewController *)[segue destinationViewController]).userData = [sender objectAtIndex: 0];
        ((DetailViewController *)[segue destinationViewController]).userProfilePic = [sender objectAtIndex: 1];
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self loadNewData];
}

@end
