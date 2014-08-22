//
//  ChatTableViewController.h
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface ChatTableViewController : UITableViewController

@property (nonatomic, strong) XMPPJID *chatToJID;     //存储要聊天的对象

@end
