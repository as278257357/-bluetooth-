//
//  ViewController.m
//  基于bluetooth实现的对等网络通信
//
//  Created by EaseMob on 16/5/16.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serverType = @"easemob-chattest";
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    
    _btnClick = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnClick.frame = CGRectMake(100, 100, 300, 100);
    _btnClick.backgroundColor = [UIColor blueColor];
    [_btnClick addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btnClick setTitle:@"发送" forState:UIControlStateNormal];
    [self.view addSubview:_btnClick];
    
    _btnConnect = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnConnect.frame = CGRectMake(100, 300, 300, 100);
    [_btnConnect addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    [_btnConnect setTitle:@"搜索" forState:UIControlStateNormal];
    [_btnConnect setBackgroundColor:[UIColor redColor]];
    
    _lblPlayer1.frame = CGRectMake(100, 500, 300, 100);
    _lblPlayer1.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_lblPlayer1];
    
    [self.view addSubview:_btnConnect];
    
    [self createSession];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)createSession {
    //Creat session related functionality
    self.peerID = [[MCPeerID alloc]initWithDisplayName:@"Easemomb_Advertiser"];
    self.session = [[MCSession alloc]initWithPeer:[[MCPeerID alloc]initWithDisplayName:@"Easemomb_Advertiser"] securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
    _advertiserAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:@"easemob-chattest" discoveryInfo:nil session:_session];
    _advertiserAssistant.delegate = self;
    //Start the assistant to begin advertising your peer availability
    [_advertiserAssistant start];
}

//搜索展示附近的设备
- (void)connect:(id)sender {
    MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc]initWithServiceType:self.serverType session:self.session];
    browserViewController.delegate = self;
    browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
    [self presentViewController:browserViewController animated:YES completion:^{
        
    }];
}
//发送数据
- (void)onClick:(id)sender {
    NSError *error = nil;
    NSData *data = [@"easemob" dataUsingEncoding:NSUTF8StringEncoding];
    [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MCAdvertiserAssistantDelegate
-(void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant {
    NSLog(@"advertiserAssistantDidDismissInvitation :  %@",advertiserAssistant);
}
- (void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    NSLog(@"advertiserAssistantWillPresentInvitation : %@",advertiserAssistant);
    
}
#pragma mark - MCBrowserViewControllerDelegate
// Override this method to filter out peers based on application specific needs
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    
    NSLog(@"peerID :%@ withDiscoveryInfo : %@",peerID.displayName,info);
    
    return YES;
}
// Override this to know when the user has pressed the "done" button in the MCBrowserViewController
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Override this to know when the user has pressed the "cancel" button in the MCBrowserViewController
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - MCSessionDelegate -
// Remote peer changed state

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateNotConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not Connected" message:nil delegate:nil cancelButtonTitle :@"我知道了" otherButtonTitles: nil];
            [alert show];
        });
    }
    
}

// MCSession Delegate callback when receiving data from a peer in a given session - Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    // Notify the delegate that we have received a new chunk of data from a peer
    [self receivedTranscript:receivedMessage];
}

// MCSession delegate callback when we start to receive a resource from a peer in a given session
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Start receiving resource [%@] from peer %@ with progress [%@]", resourceName, peerID.displayName, progress);
    [self receivedTranscript:resourceName];
}

// MCSession delegate callback when a incoming resource transfer ends (possibly with error)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    // If error is not nil something went wrong
    if (error)
    {
        NSLog(@"Error [%@] receiving resource from peer %@ ", [error localizedDescription], peerID.displayName);
    }
    else
    {
        // No error so this is a completed transfer.  The resources is located in a temporary location and should be copied to a permenant locatation immediately.
        // Write to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *copyPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], resourceName];
        if (![[NSFileManager defaultManager] copyItemAtPath:[localURL path] toPath:copyPath error:nil])
        {
            NSLog(@"Error copying resource to documents directory");
        }
        else {
            // Get a URL for the path we just copied the resource to
            //            NSURL *imageUrl = [NSURL fileURLWithPath:copyPath];
            
        }
    }
}

// Streaming API not utilized in this sample code- Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Received data over stream with name %@ from peer %@", streamName, peerID.displayName);
}

#pragma mark CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *message;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            message = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateResetting:
            message = @"初始化中，请稍后。。。";
            break;
        case CBCentralManagerStateUnsupported:
            message = @"设备不支持状态，过后请重试";
            break;
        case CBCentralManagerStateUnauthorized:
            message = @"设备未授权状态，过后请重试";
            break;
        case CBCentralManagerStatePoweredOff:
            message = @"尚未打开蓝牙，请在设置中打开...";
            break;
        case CBCentralManagerStatePoweredOn:
            message = @"蓝牙已经成功开启，稍后。。。";
            break;
            
        default:
            break;
    }
    NSLog(@"%@",message);
}

- (void)receivedTranscript:(NSString *)adminMessage
{
    //收到消息更新UI一定要放在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblPlayer1.text = adminMessage;
    });
    
}

@end
