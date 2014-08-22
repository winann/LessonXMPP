//
//  XMPPManager.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "XMPPManager.h"

/**
 *  连接服务器的目的
 */
typedef NS_ENUM(NSInteger, ConnectServerPurpose) {
    /**
     *  登录
     */
    ConnectServerPurposeLogin,
    /**
     *  注册
     */
    ConnectServerPurposeRegister,
};

//延展
@interface XMPPManager ()
@property (nonatomic, strong) NSString *loginPassword;      //保存登录的密码
@property (nonatomic, strong) NSString *registerPassword;   //保存注册的密码
@property (nonatomic, assign) ConnectServerPurpose connectServerPurpose;        //连接服务器的目的
@end

@implementation XMPPManager

//创建单例
+ (XMPPManager *)defaultManager {
    
    //同步锁，保证线程的安全
    @synchronized(self) {
        static XMPPManager *xmppManager = nil;
        //判断之前是否创建
        if (nil == xmppManager) {
            //开辟空间并且初始化
            xmppManager = [[XMPPManager alloc] init];
        }
        return xmppManager;
    }
}

//重写初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stream = [[XMPPStream alloc] init];
        //为XMPP指定服务器地址
        self.stream.hostName = kHostName;
        //为XMPP指定服务端口，（每个端口对应着一个服务，相当于一个程序）
        self.stream.hostPort = kHostPort;
        
        //设置代理（XMPPStreamDelegate），add可以添加多个代理对象。设置代理队列：主线程队列。
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];

        
        //设置存储花名册为coreData
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        //初始化花名册
        self.roster = [[XMPPRoster alloc] initWithRosterStorage:rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        //激活通信管道，让roster通过stream来获取好友列表
        [self.roster activate:self.stream];
        
        //设置存储聊天信息的coreData
        XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        //初始化信息管理类
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        //获取message coreData托管对象山下文
        self.messageManagedObjectContext = messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        //激活
        [self.messageArchiving activate:self.stream];
        
    }
    return self;
}

//向服务器发送请求（和服务器建立连接）
- (void)connectToServer {
    
    //在建立连接前需要判断是否正在连接或者已经连接
    if ([self.stream isConnecting] || [self.stream isConnected]) {
        //和服务器断开连接
        [self disconnectWithServer];
    }
    
    //建立连接
    
    //建立NSError对象，接受连接时发生的错误信息
    NSError *error = nil;
    [self.stream connectWithTimeout:30.0f error:&error];
    
    //如果error不为nil，则说明出现了错误，将错误信息打印出来
    if (nil != error) {
        NSLog(@"%s__%d__| 连接请求失败：%@", __FUNCTION__, __LINE__, error);
    }
}

//和服务器断开连接
- (void)disconnectWithServer {
    
    //直接和服务器断开连接
    [self.stream disconnect];
}

//登录的方法实现
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password {
    //设置连接服务器目的为登录
    self.connectServerPurpose = ConnectServerPurposeLogin;
    //保存密码
    self.loginPassword = password;
    //与服务器建立链接
    [self connectToServerWithUserName:userName];
}

//注册的方法实现
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password {
    //设置连接服务器目的为注册
    self.connectServerPurpose = ConnectServerPurposeRegister;
    //保存注册密码
    self.registerPassword = password;
    //与服务器建立链接
    [self connectToServerWithUserName:userName];
}

//与服务器建立链接的方法封装
- (void)connectToServerWithUserName:(NSString *)userName {
    //设置JID：用户名、域（服务器名称）、来源（客户端的类型）
    XMPPJID *streamJID = [XMPPJID jidWithUser:userName domain:kDomin resource:kResource];
    
    //把JID赋值给stream的myJID属性
    self.stream.myJID = streamJID;
    
    //调用连接方法，与服务器建立链接
    [self connectToServer];
}

#pragma mark - 
#pragma mark - XMPPStreamDelegate

//实现XMPPStreamDelegate代理方法

//与服务器建立连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"%s__%d__| 与服务器链接成功", __FUNCTION__, __LINE__);
    
    //判断是登录还是注册
    NSError *error = nil;
    switch (self.connectServerPurpose) {
        case ConnectServerPurposeLogin:
            //连接成功，进行登录操作（验证用户名和密码，JID在登录方法中设置）
            [self.stream authenticateWithPassword:self.loginPassword error:&error];
            if (nil != error) {
                NSLog(@"%s__%d__| 验证失败：%@", __FUNCTION__, __LINE__, error);
            }
            break;
        case ConnectServerPurposeRegister:
            //连接成功，进行注册操作
            [self.stream registerWithPassword:self.registerPassword error:&error];
            if (nil != error) {
                NSLog(@"%s__%d__| 注册失败：%@", __FUNCTION__, __LINE__, error);
            }
            break;
        default:
            break;
    }
    
}

//与服务器连接超时（链接失败）
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"%s__%d__| 与服务器链接失败", __FUNCTION__, __LINE__);
}

@end
