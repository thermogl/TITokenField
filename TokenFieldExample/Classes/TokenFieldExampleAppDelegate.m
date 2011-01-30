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


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	TokenFieldExampleViewController * viewController = [[TokenFieldExampleViewController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    return YES;
}


- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end
