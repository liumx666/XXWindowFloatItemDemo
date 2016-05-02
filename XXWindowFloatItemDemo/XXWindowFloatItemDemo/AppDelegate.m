//
//  AppDelegate.m
//  XXWindowFloatItemDemo
//
//  Created by lmx on 16/5/2.
//  Copyright © 2016年 lmx. All rights reserved.
//

#import "AppDelegate.h"
#import "XXPopViewController.h"
#import "XXFirstViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 创建window
    self.window = [[XXWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 创建window的根控制器，并赋值
    XXFirstViewController * firstViewController = [[XXFirstViewController alloc] init];
    
    UINavigationController * navViewController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    
    self.window.rootViewController = navViewController;
    
    // 创建window的popViewController并赋值
    XXPopViewController * popViewController = [[XXPopViewController alloc] init];
    
    self.window.popViewController = popViewController;
    
    // 让window成为keyWindow并可见
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
