//
//  ChatTableViewController.m
//  LessonXMPP
//
//  Created by lanou3g on 14-8-15.
//  Copyright (c) 2014年 Winann. All rights reserved.
//

#import "ChatTableViewController.h"

@interface ChatTableViewController () <XMPPStreamDelegate>
@property (nonatomic, strong) NSMutableArray *messages;     //存储聊天信息
@end

@implementation ChatTableViewController

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
    
    //初始化信息的数组
    self.messages = [NSMutableArray array];
    
    //设置当前对象为XMPPStreamDelegate的代理
    [[XMPPManager defaultManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = self.chatToJID.user;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //加载聊天信息
    [self reloadMessage];
}

//点击发送消息
- (IBAction)sendMessage:(UIBarButtonItem *)sender {
    
    //发送消息的方法（消息的类型、发送消息的对象）。
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatToJID];
    //添加聊天内容
    [message addBody:@"Hello, world"];
    
    //让stream发送信息
    [[XMPPManager defaultManager].stream sendElement:message];
}

//加载聊天信息
- (void)reloadMessage {
    
    //临时上下文对象
    NSManagedObjectContext *manageObjectContext = [XMPPManager defaultManager].messageManagedObjectContext;
    //(打fetch，回车)
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:manageObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    
    //设置对方和当前用户的jid作为检索条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@", self.chatToJID.bare, [XMPPManager defaultManager].stream.myJID.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    //设置排序的属性
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [manageObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%s__%d__| 聊天记录查询失败：%@", __FUNCTION__, __LINE__, error);
    } else {
        //清空之前的数据
        [self.messages removeAllObjects];
        //将检索的数组添加到消息数组
        [self.messages addObjectsFromArray:fetchedObjects];
        //刷新数据
        [self.tableView reloadData];
    }
    if (self.messages.count > 0) {
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:0 animated:YES];
    }
}

#pragma mark - XMPPStreamDelegate
//消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"%s__%d__| message = %@", __FUNCTION__, __LINE__, message);
    
    //加载聊天信息
    [self reloadMessage];
}
//收到了来自他人发送的信息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"%s__%d__| received message = %@", __FUNCTION__, __LINE__, message);
    
    //加载聊天信息
    [self reloadMessage];
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
    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messages[indexPath.row];
    
    //置空
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    //判断是否是发出去的
    if (message.isOutgoing) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"me:%@", message.body];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", self.chatToJID.user, message.body];
    }
    
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
