//
//  ViewController.m
//  BlueTooth
//
//  Created by 龙一郎 on 2021/4/5.
//

#import "ViewController.h"

#import "PeripheralsManager.h"

@interface ViewController ()

@property (strong, nonatomic)PeripheralsManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _manager = [[PeripheralsManager alloc]initWithDeveice:0 blueToothState:^(CBManagerState state){
        if (state != CBManagerStatePoweredOn) {
            NSLog(@"本机蓝牙状态是没有开启");
        }
    } bloodSugarSteps:^(BGMStepsTypes step){
        NSLog(@"与外接设备交互步骤,根据外接设备协议指定");
    } reloadData:^(float value){
        NSLog(@"获得外接设备返回值根据业务逻辑而定");
    } time:^(NSInteger value){
        NSLog(@"获得外接设备返回值根据业务逻辑而定");
    }];
    
    //主动交互链接 第一个参数设定扫描时间
    [_manager scanPeripherals:10 scanState:^(BOOL success){
        NSLog(@"是否有扫描到外接设备");
    } connectState:^(ConnectState state){
        if (state == success) {
            NSLog(@"外接设备链接成功");
        }else if (state == fail){
            NSLog(@"外接设备链接是不");
        }else{
            NSLog(@"已断开链接");
        }
    }];
}


@end
