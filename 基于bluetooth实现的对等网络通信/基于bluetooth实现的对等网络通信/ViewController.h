//
//  ViewController.h
//  基于bluetooth实现的对等网络通信
//
//  Created by EaseMob on 16/5/16.
//  Copyright © 2016年 EaseMob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define GAMING 0 //游戏进行中
#define GAMED 1  //游戏结束

@interface ViewController : UIViewController<CBCentralManagerDelegate,MCBrowserViewControllerDelegate,MCSessionDelegate,MCAdvertiserAssistantDelegate>

{
    NSTimer *timer;
    
}
@property (strong , nonatomic) UILabel *lblTimer;
//@property (strong , nonatomic) UILabel *lblPlayer2;
@property (strong , nonatomic) UILabel *lblPlayer1;
@property (strong , nonatomic) UIButton *btnConnect;
@property (strong , nonatomic) UIButton *btnClick;
/**
 iOS7之前用GKPeerPickerController这个类，iOS之后使用MCBrowserViewController
 */
//@property (strong , nonatomic) MCBrowserViewController *picker;
/**
 iOS7之前用GKSession这个类，iOS之后使用MCSession
 */
@property (strong , nonatomic) MCSession *session;

@property (strong , nonatomic) CBCentralManager *centralManager;
@property (strong , nonatomic) MCPeerID *peerID;

@property (strong , nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@property (strong , nonatomic) NSString *serverType;
/**
 清除UI画面上的数据
 */
- (void) clearUI;
/**
 更新计时器
 */
- (void) updateTimer;


@end

