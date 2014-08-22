//
//  RegisterViewController.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"

@interface RegisterViewController () <XMPPStreamDelegate>
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;

@end

@implementation RegisterViewController

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
    
    //添加代理
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)registerButton:(UIButton *)sender {
    
    //进行注册
    [[XMPPManager defaultManager] registerWithUserName:self.userName.text password:self.password.text];
}
- (IBAction)backToLogin:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        [self registerButton:nil];
    }
    return YES;
}

#pragma mark - 
#pragma mark - XMPPStreamDelegate

//是否注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功，将返回到登录页面。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
    [alertView show];
}
//alertView 的代理方法，用来返回到登录页面
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //返回到登录界面
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"%s__%d__| 注册失败：%@", __FUNCTION__, __LINE__, error);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"注册失败！" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
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
