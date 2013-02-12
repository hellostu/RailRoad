//
//  RRAppDelegate.m
//  RailRoad
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import "RRAppDelegate.h"
#import "RRMainViewController.h"

@implementation RRAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    RRMainViewController *mainViewController = [[RRMainViewController alloc] init];
    self.window.rootViewController = mainViewController;
    [mainViewController release];
    
    return YES;
}

@end
