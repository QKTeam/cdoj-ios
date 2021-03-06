//
//  TrainingRatingUserListViewController.m
//  CDOJ-IOS
//
//  Created by GuessEver on 16/8/14.
//  Copyright © 2016年 UESTCACM QKTeam. All rights reserved.
//

#import "TrainingRatingUserListViewController.h"
#import "String.h"
#import "TrainingRatingUserListTableViewCell.h"

@implementation TrainingRatingUserListViewController

- (instancetype)initWithTrainingId:(NSString*)trainingId {
    if(self = [super init]) {
        [self loadRightNavigationButtons];
        
        self.userVisibility = [[NSMutableArray alloc] init];
        self.data = [[TrainingRatingContentModel alloc] initWithTrainingId:trainingId];
        [self.data fetchUsers];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userListRefreshed) name:NOTIFICATION_TRAINING_USER_REFRESHED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contestsListRefreshed) name:NOTIFICATION_TRAINING_CONTEST_REFRESHED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(graphRefreshed) name:NOTIFICATION_TRAINING_GRAPH_REFRESHED object:nil];
        
        self.graph = [[JBLineChartView alloc] init];
        [self.view addSubview:self.graph];
        [self.graph mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left).offset(10);
            make.width.equalTo(self.view.mas_width).offset(-20);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.5);
        }];
        [self.graph setDelegate:self];
        [self.graph setDataSource:self];
        
        self.tableView = [[UITableView alloc] init];
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.graph.mas_bottom);
            make.left.equalTo(self.view.mas_left);
            make.width.equalTo(self.view.mas_width);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
    }
    return self;
}

- (void)loadRightNavigationButtons {
    if(!self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItems = @[
                                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(showAllUserGraph)],
                                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeUserGraphChooseStatus)]
                                                    ];
    }
    else {
        self.navigationItem.rightBarButtonItems = @[
                                                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(changeUserGraphChooseStatus)]
                                                    ];
    }
}

- (void)changeUserGraphChooseStatus {
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    if(self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        for(NSInteger i = 0; i < self.userVisibility.count; i++) {
            if([self.userVisibility[i] boolValue]) {
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self loadRightNavigationButtons];
}
- (void)changeUserVisibilityAtIndex:(NSInteger)index {
    if(!self.tableView.isEditing) {
        [self changeAllUserVisibilityTo:NO];
    }
    self.userVisibility[index] = [NSNumber numberWithBool:![self.userVisibility[index] boolValue]];
    [self.graph reloadData];
}
- (void)showAllUserGraph {
    [self changeAllUserVisibilityTo:YES];
    [self.graph reloadData];
    [self.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}
- (void)changeAllUserVisibilityTo:(BOOL)visibility {
    self.userVisibility = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < self.data.users.count; i++) {
        [self.userVisibility addObject:[NSNumber numberWithBool:visibility]];
    }
}
- (void)userListRefreshed {
    [self changeAllUserVisibilityTo:YES];
    [self.tableView reloadData];
    [self.data fetchContests];
}
- (void)contestsListRefreshed {
    [self.graph reloadData];
    self.data.ratingSections[0] = [NSNumber numberWithFloat:self.graph.maximumValue + 1];
    [self.data processGraphData];
}
- (void)graphRefreshed {
    [self.graph reloadData];
}

#pragma mark JBLineChartViewDelegate
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    if(lineIndex < self.data.users.count) { // user line
        return [self.data.rating[lineIndex][horizontalIndex] floatValue];
    }
    else { // rating section
        return [self.data.ratingSections[lineIndex - self.data.users.count] floatValue];
    }
}
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex {
    // color of lines
    return [self.data.colorSections lastObject];
}
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex {
    // width of lines
    if(lineIndex < self.data.users.count) { // user line
        return 2 * [self.userVisibility[lineIndex] floatValue];
    }
    else { // rating section
        return 0.3;
    }
}
- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex {
    // show dots on lines
    if(lineIndex < self.data.users.count) { // user line
        return YES;
    }
    else { // rating section
        return NO;
    }
}
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    // radius(size) of dots
    return 4 * [self.userVisibility[lineIndex] floatValue];
}
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    // color of dots
    if(lineIndex < self.data.users.count) { // user line
//        if(lineIndex == 8 && horizontalIndex == 4) {
//            return [UIColor blackColor];
//        }
        return self.data.ratingColor[lineIndex][horizontalIndex];
    }
    else { // rating section
        return self.data.colorSections[lineIndex - self.data.users.count];
    }
}
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView fillColorForLineAtLineIndex:(NSUInteger)lineIndex {
    if(lineIndex < self.data.users.count) { // user line
        return [ColorSchemeModel defaultColorScheme].backgroundColor1;
    }
    else { // rating section
        return [ColorSchemeModel defaultColorScheme].backgroundColor1;
        // return self.colorSections[lineIndex - self.data.users.count];
    }
}

#pragma mark JBLineChartViewDataSource
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView {
    return self.data.users.count + self.data.ratingSections.count;
}
- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex {
    return self.data.contests.count;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TrainingRatingUserListTableViewCell height];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeUserVisibilityAtIndex:indexPath.row];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeUserVisibilityAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.users.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TrainingRatingUserListTableViewCell* cell = [[TrainingRatingUserListTableViewCell alloc] init];
    [cell.name setText:STR([self.data.users[indexPath.row] objectForKey:@"trainingUserName"])];
    [cell.rank setText:STRF(@"Rank %@", [self.data.users[indexPath.row] objectForKey:@"rank"])];
    [cell.currentRating setText:STRF(@"Rating: %.0f", [[self.data.users[indexPath.row] objectForKey:@"currentRating"] doubleValue])];
    [cell.volatility setText:STRF(@"Volatility: %.0f", [[self.data.users[indexPath.row] objectForKey:@"currentVolatility"] doubleValue])];
    return cell;
}

@end
