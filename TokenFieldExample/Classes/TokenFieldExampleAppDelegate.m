//
//  TokenFieldExampleAppDelegate.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleAppDelegate.h"
#import "TokenFieldExampleViewController.h"
#import "TITokenTableViewController.h"
#import "TokenTableExampleViewController.h"

@implementation TokenFieldExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
//	TokenFieldExampleViewController * viewController = [[TokenFieldExampleViewController alloc] init];
//	UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];



    TokenTableExampleViewController * viewController = [[TokenTableExampleViewController alloc] init];


    viewController.tokenDataSource = viewController;
    viewController.delegate = viewController;

	
    [window setRootViewController:viewController];

	
    [window makeKeyAndVisible];

    return YES;
}

@end