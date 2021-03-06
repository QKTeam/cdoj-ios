//
//  UserSettingViewController.m
//  CDOJ-IOS
//
//  Created by GuessEver on 16/8/9.
//  Copyright © 2016年 UESTCACM QKTeam. All rights reserved.
//

#import "UserSettingViewController.h"
#import "ColorSchemeModel.h"
#import "Notification.h"
#import "DefaultNavigationController.h"

#import "UserBlogListViewController.h"
#import "UserMessageListViewController.h"
#import "UserInfoEditViewController.h"

#import "RecentContestListViewController.h"
#import "FAQViewController.h"
#import "StepByStepViewController.h"

#import "TeamHornorViewController.h"
#import "TrainingRatingListViewController.h"

#import "AccountManageViewController.h"
#import "ThemeSwitchViewController.h"

#import "AboutCDOJViewController.h"

@implementation UserSettingViewController

- (instancetype)init {
    if(self = [super initWithStyle:UITableViewStyleGrouped]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignin) name:NOTIFICATION_USER_SIGN_IN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSignout) name:NOTIFICATION_USER_SIGN_OUT object:nil];
        [self setTitle:@"用户中心"];
        self.noUserLogin = 1; // set the offset to hide "我**" options when not login
        self.titleOfSections = @[@"我", @"ACM", @"集训队", @"设置", @"关于"];
        self.data = @[
                      @[@"我的博客", @"我的消息", @"个人信息"],
                      @[@"最近比赛", @"F.A.Q", @"Step By Step"],
                      @[@"队内荣誉", @"训练Rating"],
                      @[@"账号管理", @"主题切换"],
                      @[@"关于CDOJ"]
                      ];
        self.classType = @[
                           @[ // Me
                               [UserBlogListViewController class],
                               [UserMessageListViewController class],
                               [UserInfoEditViewController class]
                               ],
                           @[ // ACM
                               [RecentContestListViewController class],
                               [FAQViewController class],
                               [StepByStepViewController class]
                               ],
                           @[ // Team
                               [TeamHornorViewController class],
                               [TrainingRatingListViewController class]
                               ],
                           @[ // Setting
                               [AccountManageViewController class],
                               [ThemeSwitchViewController class]
                               ],
                           @[ // About
                               [AboutCDOJViewController class]
                               ]
                           ];
    }
    return self;
}
- (void)userSignin {
    self.noUserLogin = 0;
    [self.tableView reloadData];
}
- (void)userSignout {
    self.noUserLogin = 1;
    [self.tableView reloadData];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section + self.noUserLogin;
    NSInteger row = indexPath.row;
    __kindof UIViewController* root = [[self.classType[section][row] alloc] init];
    DefaultNavigationController* nav = [[DefaultNavigationController alloc] initWithRootViewController:root];
    [self.splitViewController showDetailViewController:nav sender:nil];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.titleOfSections count] - self.noUserLogin;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.titleOfSections[section + self.noUserLogin];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data[section + self.noUserLogin] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setText:self.data[indexPath.section + self.noUserLogin][indexPath.row]];
    return cell;
}
@end
