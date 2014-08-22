//
//  ANNAppDelegate.h
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

//因为XMPPStreamDelegate添加代理的方法为id类型的，所以也可以不服从协议，直接是实现方法
@interface ANNAppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
