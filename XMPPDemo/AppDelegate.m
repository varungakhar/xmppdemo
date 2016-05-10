//
//  AppDelegate.m
//  XMPPDemo
//
//  Created by KindleBit on 15/04/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *view=[[ViewController alloc]init];
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:view];
    
    self.window.rootViewController=nav;
    
    
    [[XMPP sharedxmpp]setupStream];
    
    
    
    
    [self.window makeKeyAndVisible];
    
    
    
    
  
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
