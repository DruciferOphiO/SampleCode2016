//
//  TestAndScreeningsListViewController.m
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
//

#import "TestsAndScreeningsListViewController.h"
#import "TestsAndScreeningsObjectModel.h"
#import "TestsAndScreeningsDetailViewController.h"
#import "HelperUtility.h"

@implementation TestsAndScreeningsListViewController

#pragma mark - View Controller Life cycle
-(id)init{
    self = [super init];
    if (IS_IPAD()){
        [self setTabBarItemWithTitle:@"Tools" selectedImage:[UIImage imageNamed:@"tab-bar-tools-on"] unselectedImage:[UIImage imageNamed:@"tab-bar-tools-off"]];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // instantiate all objects
    backgroundView = [[UIView alloc] init];
    [backgroundView setBackgroundColor:[UIColor colorWithHexString:@"E0E0E0"]];
    [self.view addSubview:backgroundView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
    productFacade = [[TestsAndScreeningsFacade alloc] init];
    
    allData = [NSArray arrayWithObjects:[productFacade getObjectsForTrimester:kTestsAndScreeningsFirstTrimester],[productFacade getObjectsForTrimester:kTestsAndScreeningsSecondTrimester],[productFacade getObjectsForTrimester:kTestsAndScreeningsThirdTrimester], nil];
    
    banner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"testscreenings_banner.jpg"]];
    [self.view addSubview:banner];
    
    testsTable = [[UITableView alloc] initWithFrame:CGRectZero];
    [testsTable setDelegate:self];
    [testsTable setDataSource:self];
    [testsTable setBackgroundColor:[UIColor clearColor]];
    [testsTable setSeparatorColor:[UIColor clearColor]];
    [testsTable setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:testsTable];
    
    firstTrimesterHeaderImage = [[UIImageView alloc] init];
    secondTrimesterHeaderImage = [[UIImageView alloc] init];
    thirdTrimesterHeaderImage = [[UIImageView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // previous view hides navbar
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // once view sizes had been
    float backgroundY = 0 - self.navigationController.navigationBar.frame.size.height;
    float backgroundHeight = self.view.frame.size.height + self.navigationController.navigationBar.frame.size.height;
    backgroundView.frame = CGRectMake(0, backgroundY, self.view.frame.size.width, backgroundHeight);
    int headerPadding = IS_IPAD() ? 30 : 10;
    int width;

    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) || IS_IPHONE()){
        [banner setImage:[UIImage imageNamed:@"testscreenings_banner.jpg"]];
        [firstTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_firsttrimester"]];
        [secondTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_secondtrimester"]];
        [thirdTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_thirdtrimester"]];
        width = IS_IPAD() ? 708 : [UIImage imageNamed:@"testscreenings_thirdtrimester"].size.width;
        
    }else{
        [banner setImage:[UIImage imageNamed:@"testscreenings_banner-landscape.jpg"]];
        [firstTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_firsttrimester-landscape"]];
        [secondTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_secondtrimester-landscape"]];
        [thirdTrimesterHeaderImage setImage:[UIImage imageNamed:@"testscreenings_thirdtrimester-landscape"]];
        width = IS_IPAD() ? 964 : [UIImage imageNamed:@"testscreenings_thirdtrimester"].size.width;
        
    }

    firstTrimesterHeaderImage.frame = CGRectMake(headerPadding, banner.frame.size.height + 15, width , firstTrimesterHeaderImage.image.size.height);
    secondTrimesterHeaderImage.frame = CGRectMake(headerPadding, 15, width, secondTrimesterHeaderImage.image.size.height);
    thirdTrimesterHeaderImage.frame = CGRectMake(headerPadding, 15, width, thirdTrimesterHeaderImage.image.size.height);
    testsTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [testsTable setContentOffset:CGPointMake(0, 0)];
    banner.frame = CGRectMake(0, 0, self.view.frame.size.width, banner.image.size.height);
}

#pragma mark - UITableView delegate methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return allData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section <= allData.count-1){
        NSArray *data = (NSArray*)[allData objectAtIndex:section];
        return data.count;
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section <= allData.count-1){
        NSArray *data = (NSArray*)[allData objectAtIndex:indexPath.section];
        TestsAndScreeningsObjectModel * model = (TestsAndScreeningsObjectModel*)[data objectAtIndex:indexPath.row];
        return [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:model];
    }else{
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TestsAndScreeningsObjectModel * model;
    if (indexPath.section <= allData.count-1){
        NSArray *data = (NSArray*)[allData objectAtIndex:indexPath.section];
        model = (TestsAndScreeningsObjectModel*)[data objectAtIndex:indexPath.row];
    }
    
    static NSString *reusableIdentifier = @"CellIdentifier";
    TestsAndScreeningsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableIdentifier];
    if (!cell){
        cell = [[TestsAndScreeningsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reusableIdentifier];
    }
    
    [cell updateLayoutWithModel:model];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TestsAndScreeningsObjectModel * model;
    if (indexPath.section <= allData.count-1){
        NSArray *data = (NSArray*)[allData objectAtIndex:indexPath.section];
        model = (TestsAndScreeningsObjectModel*)[data objectAtIndex:indexPath.row];
    }


    TestsAndScreeningsTableViewCell *cell = (TestsAndScreeningsTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    float oldX = [self.view convertPoint:CGPointZero fromView:cell.expandableView].x;
    float oldY = [self.view convertPoint:CGPointZero fromView:cell.expandableView].y;

    TestsAndScreeningsDetailViewController *vc = [[TestsAndScreeningsDetailViewController alloc] initWithModel:model withViewAtRect:CGRectMake(oldX, oldY, cell.expandableView.frame.size.width, [TestsAndScreeningsTableViewCell getHeightOfCellWithModel:nil])];

    BaseNavigationController *nav = (BaseNavigationController*)self.navigationController;
    [nav pushViewControllerWithFadeAnimation:vc andDuration:0.29f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section){
        case 0:
            return banner.frame.size.height + firstTrimesterHeaderImage.image.size.height + 15;
            break;
        case 1:
            return secondTrimesterHeaderImage.image.size.height + 15;
            break;
        case 2:
            return thirdTrimesterHeaderImage.image.size.height + 15;
            break;
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    switch (section){
        case 0:
            {
                
                UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, testsTable.frame.size.width, banner.frame.size.height + firstTrimesterHeaderImage.image.size.height)];
                [header addSubview:banner];
                [header addSubview:firstTrimesterHeaderImage];
                return header;
            }
            
            break;
        case 1:
            {
                UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, testsTable.frame.size.width, secondTrimesterHeaderImage.image.size.height + 5)];
                [header addSubview:secondTrimesterHeaderImage];
                return header;
            }
            
            break;
        case 2:
            {
                
                UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, testsTable.frame.size.width, thirdTrimesterHeaderImage.image.size.height + 5)];
                [header addSubview:thirdTrimesterHeaderImage];
                return header;
            }
            
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - Action Methods
-(void)sharePressed{
    NSString *bodyStr = @"Here's your go-to guide for prenatal tests and screenings to ensure a healthier pregnancy and delivery: http://www.whattoexpect.com/pregnancy/screenings-and-tests-during-pregnancy.aspx";
    //add share text before link
    bodyStr = [NSString stringWithFormat:@"%@ \n\n %@", bodyStr, NSLocalizedString(@"COMMUNITY_SHARE_APP_LINK_TEXT", nil)];
    
    NSArray *postArr = [NSArray arrayWithObjects:bodyStr, [NSURL URLWithString:ITUNES_APP_STORE_TRACKING_URL], nil];
    
    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:postArr applicationActivities:nil];
    
    [act setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
        if(completed){
            [EHTracking logShareActionWithNetwork:activityType andOptions:nil];
        }
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        if ([act.popoverPresentationController respondsToSelector:@selector(setSourceView:)]) {
            act.excludedActivityTypes = @[UIActivityTypeAirDrop];
            act.popoverPresentationController.sourceView = self.navigationController.navigationBar;
            act.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width - 90,-50, 100, 100);
            act.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            act.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"0D56FE"];
        }
        [act.view setTintColor:[UIColor colorWithHexString:@"0D56FE"]];
    }
    [self presentViewController:act animated:YES completion:nil];
}

#pragma mark - Super class Methods

-(NSString*)pageNameForPageView{
    return @"List";
}

-(NSString*)channelForPageView{
    
    return @"Tests And Screenings ";
}

@end