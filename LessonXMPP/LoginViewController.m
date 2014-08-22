//
//  LoginViewController.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"

@interface LoginViewController () <XMPPStreamDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userName.delegate = self;
    self.password.delegate = self;
    
    //通过单例得到属性，然后为其添加代理
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)RegisterButton:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"register" sender:nil];
}
- (IBAction)loginButton:(UIButton *)sender {
    
//    //parentViewController:调用视图控制器的父视图控制器
//    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
    if ([self.userName.text isEqualToString:@""] || [self.password.text isEqualToString:@""]) {
        //判断用户名和密码是否为空
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名和密码不能为空！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [alertView show];
    } else {
        //发送登录请求
        [[XMPPManager defaultManager] loginWithUserName:self.userName.text password:self.password.text];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userName) {
        [self.password becomeFirstResponder];
    } else {
        [self.password resignFirstResponder];
        [self loginButton:nil];
    }
    return YES;
}

#pragma mark - 
#pragma mark - XMPPStreamDelegate
//实现XMPPStreamDelegate代理方法

//验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    //保存用户名和密码
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userName.text forKey:@"userName"];
    [userDefaults setObject:self.password.text forKey:@"password"];
    [userDefaults synchronize];
    
    //设置为上线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager defaultManager].stream sendElement:presence];
    
    //把登录界面dismiss掉
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
//验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"%s__%d__| 验证失败%@", __FUNCTION__, __LINE__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"用户名或密码错误！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
