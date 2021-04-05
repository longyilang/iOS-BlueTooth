//
//  BlueToothTransfer.h
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/24.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PeripheralsDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlueToothStateBlock)(CBManagerState);             //本机蓝牙开关状态

typedef void(^ScanStateBlock)(BOOL succsess);                 //外设扫描状态

typedef void(^ConnectStateBlock)(ConnectState state);          //设备连接状态

typedef void(^WriteCharacteristicsBlock)(void);               //指令写入

typedef void(^DidUpdateValueBlock)(NSData *data);             //数据接收


@interface BlueToothTransfer : NSObject

@property (copy, nonatomic) BlueToothStateBlock bluetoothStateHandle;

@property (copy, nonatomic)ScanStateBlock scanStateHandle;

@property (copy, nonatomic)ConnectStateBlock connectStateHandle;

@property (copy, nonatomic)WriteCharacteristicsBlock wrteCharacteristicsHandle;

@property (copy, nonatomic)DidUpdateValueBlock didUpdateValueHandle;

@property (assign, nonatomic)Device device;

- (instancetype)initWithState:(void(^)(CBManagerState state))stateBlock;

- (void)writeValueTocharacteristic:(NSString *)characteristic data:(NSData *)data;

- (void)scanPeripherals:(int)seconds
         scanState:(void(^)(BOOL success))scanBlock
         connectState:(void(^)(ConnectState))connectBlock;

- (void)disConnected;

@end

NS_ASSUME_NONNULL_END
