//
//  RosterTableViewController.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "RosterTableViewController.h"
#import "XMPPManager.h"
#import "ChatTableViewController.h"

@interface RosterTableViewController () <XMPPRosterDelegate>
@property (nonatomic, strong) NSMutableArray *rosters;      //存储好友花名册的可变数组
@end

@implementation RosterTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //为roster添加代理
    [[XMPPManager defaultManager].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //初始化好友花名册数组
    self.rosters = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.rosters count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roster" forIndexPath:indexPath];
    
    //获得数组中的jid
    XMPPJID *JID = self.rosters[indexPath.row];
    //获得jid所包含的用户名：user属性
    cell.textLabel.text = JID.user;
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //获取点击的cell的index
    NSInteger index = [self.tableView indexPathForCell:sender].row;
    //获得对应的jid
    XMPPJID *JID = self.rosters[index];
    //得到聊天界面的对象
    ChatTableViewController *chatTVC = [segue destinationViewController];
    //将jid通过属性传过去
    chatTVC.chatToJID = JID;
}


#pragma mark - 
#pragma mark - XMPPRosterDelegate

//开始检索好友列表
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"%s__%d__| ", __FUNCTION__, __LINE__);
}

//正在检索好友列表（每个好友走一次）
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(DDXMLElement *)item {
    
    //将item节点的jid属性取出来，（item格式：<item jid="kiushuo@lanou" name="kiushuo" subscription="both"><group>Friends</group></item>）
    NSString *JIDStr = [[item attributeForName:@"jid"] stringValue];
    
    //根据获得的jid属性初始化为jid对象
    XMPPJID *JID = [XMPPJID jidWithString:JIDStr resource:kResource];
    
    //将jid添加到可变数组
    [self.rosters addObject:JID];
    
    //刷新数据（逐条刷新）
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.rosters.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
    NSLog(@"%s__%d__| item = %@", __FUNCTION__, __LINE__, item);
}

//结束检索好友列表
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"%s__%d__| ", __FUNCTION__, __LINE__);
}

@end
