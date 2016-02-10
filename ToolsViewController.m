
//
//  TestsAndScreeningsViewController.m
//  WhatToExpect
//
//  Created by Andrew McKinley on 6/17/15.
//
// 

#import "ToolsViewController.h"
#import "TestsAndScreeningsListViewController.h"
#import "JournalPageViewController.h"

#define WIDTH_IDENTIFIER @"WIDTH"
#define HEIGHT_IDENTIFIER @"HEIGHT"

#pragma mark - Private Interface
@interface ToolsViewController()

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIButton *journalButton;
@property (nonatomic, strong) UILabel *journalLabel;
@property (nonatomic, strong) UIButton *testsAndScreeningsButton;
@property (nonatomic, strong) UILabel *testsAndScreeningsLabel;

@property (nonatomic, assign) BOOL didClickTests;
@property (nonatomic, assign) BOOL isAnimating;
@end

@implementation ToolsViewController

#pragma mark - View Controller Life cycle

-(id)init{
    self = [super init];
    if (self){
        // tab bar icon always the same. Must be set before view loads
        [self setTabBarItemWithTitle:@"Tools" selectedImage:[UIImage imageNamed:@"tab-bar-tools-on"] unselectedImage:[UIImage imageNamed:@"tab-bar-tools-off"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // set up background
    if (APP_DELEGATE.appMode == kAppModePregnancy){
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolsbg.jpg"]];
    }else if (APP_DELEGATE.appMode == kAppModeBaby){
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolsbg-baby.jpg"]];
    }
    
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundView];
    
    // journal for iPhone only
    if (IS_IPHONE()){
        self.journalLabel = [self createLabelWithText:@"PHOTO JOURNAL"];
        
        self.journalButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.journalButton setBackgroundImage:[UIImage imageNamed:@"icon_bumptracker"] forState:UIControlStateNormal];
        self.journalButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.journalButton addTarget:self action:@selector(didClickJournalButton) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:self.journalButton];
        [self.view addSubview:self.journalLabel];
    }
    
    // tests and screenings for Pregnancy Mode only
    if (APP_DELEGATE.appMode == kAppModePregnancy){
        self.testsAndScreeningsLabel = [self createLabelWithText:@"TESTS & SCREENINGS"];
        [self.view addSubview:self.testsAndScreeningsLabel];
        self.testsAndScreeningsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.testsAndScreeningsButton setBackgroundImage:[UIImage imageNamed:@"icon_testscreenings.png"] forState:UIControlStateNormal];
        [self.testsAndScreeningsButton addTarget:self action:@selector(didClickTestsAndScreeningsButton) forControlEvents:UIControlEventTouchUpInside];
        self.testsAndScreeningsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.testsAndScreeningsButton];
    }
    [self setConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // must undo animations upon retrning to this page
    [self removeAnimation];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // This page has no nav bar
    // remove nav bar after page appears. If user navs to next page and goes back the nav bar cant dissapear
    // until after page fully loads
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    // update background image before page appears
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) || IS_IPHONE()){
        if (APP_DELEGATE.appMode == kAppModePregnancy){
            [self.backgroundView setImage:[UIImage imageNamed:@"toolsbg.jpg"]];
        }else if (APP_DELEGATE.appMode == kAppModeBaby){
            [self.backgroundView setImage:[UIImage imageNamed:@"toolsbg-baby.jpg"]];
        }
    }else{
        [self.backgroundView setImage:[UIImage imageNamed:@"toolsbg-landscape.jpg"]];
    }
}

#pragma mark - Auto Layout Controls

-(void)removeAnimation{
    // reset opacities and remove size constraints
    self.journalButton.alpha = 1;
    self.testsAndScreeningsButton.alpha = 1;
    for (NSLayoutConstraint *constraint in self.view.constraints){
        if ([constraint.identifier isEqualToString:WIDTH_IDENTIFIER] || [constraint.identifier isEqualToString:HEIGHT_IDENTIFIER]){
            [self.view removeConstraint:constraint];
        }
    }
}

-(void)setConstraints{
    // background same size as view
    [self.view removeConstraints:self.view.constraints];
    NSLayoutConstraint *bgWidthConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0f
                                                                          constant:0];
    
    NSLayoutConstraint *bgHeightConstraint = [NSLayoutConstraint constraintWithItem:self.backgroundView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1.0f
                                                                           constant:0];
    [self.view addConstraints:[NSArray arrayWithObjects:bgWidthConstraint,bgHeightConstraint, nil]];
    
    // constrain with one button or two
    if (APP_DELEGATE.appMode == kAppModePregnancy){
        if (IS_IPHONE()){
            [self dualConstrainButton:self.journalButton andLabel:self.journalLabel isTop:YES];
            [self dualConstrainButton:self.testsAndScreeningsButton andLabel:self.testsAndScreeningsLabel isTop:NO];
        }else{
            [self centerConstrainButton:self.testsAndScreeningsButton andLabel:self.testsAndScreeningsLabel];
        }
    }else{
        [self centerConstrainButton:self.journalButton andLabel:self.journalLabel];
    }
}




-(void)centerConstrainButton:(UIButton*)button andLabel:(UILabel*)label{
    //set constraints for single button
    UIImage *buttonImage = button.currentBackgroundImage;
    
    float spacerSize = (self.view.frame.size.height - (buttonImage.size.height *2))/2;
    
    NSLayoutConstraint *labelXConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0];
    
    NSLayoutConstraint *labelYConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.0f
                                                                                constant:spacerSize + buttonImage.size.height];
    
    
    NSLayoutConstraint *labelWidthConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0f
                                                                         constant:0];
    
    NSLayoutConstraint *buttonYConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                                attribute:NSLayoutAttributeCenterY
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1.0f
                                                                                 constant:spacerSize + (buttonImage.size.height/2)];
    
    NSLayoutConstraint *buttonXConstraint =[NSLayoutConstraint constraintWithItem:button
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0];
    
    [self.view addConstraints:[NSArray arrayWithObjects:labelXConstraint,labelYConstraint,labelWidthConstraint,buttonYConstraint,buttonXConstraint, nil]];
}

-(void)dualConstrainButton:(UIButton*)button andLabel:(UILabel*)label isTop:(BOOL)isTop{
    // constrain for two buttons
    UIImage *buttonImage = button.currentBackgroundImage;
    
    float spacerSize = (self.view.frame.size.height - (buttonImage.size.height *2))/3;
    NSLayoutConstraint *labelXConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0];
    
    float labelConstantY = (buttonImage.size.height)/2 + 5;// 5 padding
    NSLayoutConstraint *labelYConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:button
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0f
                                                                         constant:labelConstantY];
    
    NSLayoutConstraint *labelWidthConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0f
                                                                             constant:0];
    
    float buttonConstantY = isTop ? spacerSize : (2*spacerSize) + buttonImage.size.height;
    NSLayoutConstraint *buttonYConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0f
                                                                          constant:buttonConstantY];
    
    NSLayoutConstraint *buttonXConstraint =[NSLayoutConstraint constraintWithItem:button
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0];
    
    [self.view addConstraints:[NSArray arrayWithObjects:labelXConstraint,labelYConstraint,labelWidthConstraint,buttonYConstraint,buttonXConstraint, nil]];
}

#pragma mark - View Creation Methods


-(UILabel*)createLabelWithText:(NSString*)string{
    // labels should be identical.
    // @param string this is text on the label.
    UILabel *label = [[UILabel alloc] init];
    [label setText:string];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithHexString:DARK_PURPLE_COLOR]];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

#pragma mark - Action Methods and Animations

-(void)didClickJournalButton{
    // begin popping next VC before animation is complete
    [self expandFadeView:self.journalButton toScale:2.0f withDuration:0.5f completion:nil];
    [self performSelector:@selector(pushJournalVC) withObject:nil afterDelay:0.2f];
}

-(void)pushJournalVC{
    // use custom fade animation
    JournalPageViewController *journalPageViewController = [[JournalPageViewController alloc] initWithNibName: nil bundle: nil];
    BaseNavigationController *nav = (BaseNavigationController*)self.navigationController;
    [nav pushViewControllerWithFadeAnimation:journalPageViewController andDuration:0.43f];
}

-(void)didClickTestsAndScreeningsButton{
    // begin popping next VC before animation is complete
    [self expandFadeView:self.testsAndScreeningsButton toScale:2.0f withDuration:0.5f completion:nil];
    [self performSelector:@selector(pushTestsAndScreeningVC) withObject:nil afterDelay:0.2f];
}


-(void)pushTestsAndScreeningVC{
    // use custom fade animation
    TestsAndScreeningsListViewController *testsAndScreeningsVC = [[TestsAndScreeningsListViewController alloc] init];
    BaseNavigationController *nav = (BaseNavigationController*)self.navigationController;
    [nav pushViewControllerWithFadeAnimation:testsAndScreeningsVC andDuration:0.43f];
}

/**
 @abstract:
    This method takes any view, expands both the width and height relative to the original size and slowly fades
    it as it grows.
 @param view: Pass the view that needs to expandFade
 @param scale: The new size relative to the view in %. Ex 0.5 is shrink to half size. 2.0 is grow to double size
 @param duration: Time in seconds for the animation to occur
 @param completion: call back for animation completion
 */
-(void)expandFadeView:(UIView*)view toScale:(float)scale withDuration:(float)duration completion:(expandFinished)completion{
     NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:scale * view.frame.size.width];
     widthConstraint.identifier = WIDTH_IDENTIFIER;
     NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:scale * view.frame.size.height];
    heightConstraint.identifier = HEIGHT_IDENTIFIER;
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        view.alpha = 0;
        [self.view addConstraints:[NSArray arrayWithObjects:widthConstraint,heightConstraint, nil]];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if (completion)
        {
            completion(YES);
        }
    }];
}

#pragma mark - Super class Methods

-(NSString*)pageNameForPageView{
    // superclass tracking
    return @"Tools";
}

-(NSString*)channelForPageView{
    // superclass tracking
    return @"Tests And Screenings";
}

@end
