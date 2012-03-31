//
//  TokenFieldExampleAppDelegate.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleAppDelegate.h"
#import "TokenFieldExampleViewController.h"

@implementation TokenFieldExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	TokenFieldExampleViewController * viewController = [[TokenFieldExampleViewController alloc] init];
	UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	
    [window setRootViewController:navigationController];
	[navigationController release];
	
    [window makeKeyAndVisible];

    return YES;
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end