//
//  ANNAppDelegate.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "ANNAppDelegate.h"

@implementation ANNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
        
        //用户名为空，还未登录过，模态出登录界面
        [self.window makeKeyAndVisible];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [self.window.rootViewController presentViewController:viewController animated:NO completion:nil];
    } else {
        //添加代理，处理登录失败的情况
        [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //直接用保存的用户名和密码登录
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        [[XMPPManager defaultManager] loginWithUserName:userName password:password];
    }
    return YES;
}

#pragma mark - XMPPStreamDelegate
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    //登录失败，需要模态出登录界面重新登录
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请重新登录！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alertView show];
    NSLog(@"%s__%d__| 登录失败：%@", __FUNCTION__, __LINE__, error);
}
//登录失败之后如果用户选择重新登录，则重新模态出登录界面
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

//验证成功，
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    //设置为上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager defaultManager].stream sendElement:presence];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
