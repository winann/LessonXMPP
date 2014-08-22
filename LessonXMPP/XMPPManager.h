//
//  XMPPManager.h
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPManager : NSObject <XMPPStreamDelegate>  //遵守XMPPStreamDelegate 协议

@property (nonatomic, strong) XMPPStream *stream;       //通信管道（所有和服务器之间的通信都是通过stream来完成的）
@property (nonatomic, strong) XMPPRoster *roster;       //好友花名册
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;       //信息管理类，用来处理信息
@property (nonatomic, strong) NSManagedObjectContext *messageManagedObjectContext;      //聊天信息托管对象上下文

//创建manager的单例
+ (XMPPManager *)defaultManager;


//登录的方法
/**
 *  brief 登录
 *
 *  @param userName 用户名
 *  @param password 密码
 */
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

//注册的方法
/**
 *  brief 注册
 *
 *  @param userName 用户名
 *  @param password 密码
 */
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password;

@end
