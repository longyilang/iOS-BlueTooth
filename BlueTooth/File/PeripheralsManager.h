//
//  PeripheralsManager.h
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/25.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PeripheralsDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralsManager : NSObject

- (instancetype)initWithDeveice:(Device)device blueToothState:(void(^)(CBManagerState))stateBlock
                bloodSugarSteps:(void(^)(BGMStepsTypes))stepBlock
                     reloadData:(void(^)(float))reloadBlock
                    time:(void(^)(NSInteger))timingBlock;

- (instancetype)initWithDeveice:(Device)device blueToothState:(void(^)(CBManagerState))stateBlock
             bloodPressureSteps:(void(^)(SPHYStepsTypes))stepBlock
                     reloadData:(void(^)(float))reloadBlock
                         result:(void(^)(NSDictionary *))resultBlock;

- (void)scanPeripherals:(int)seconds
              scanState:(void(^)(BOOL success))scanBlock
           connectState:(void(^)(ConnectState))connectBlock;

//主动断开连接
- (void)disConnected;

//主动停止血压测量
- (void)stopMeasure:(void(^)(BOOL stop))block;

@end


NS_ASSUME_NONNULL_END
