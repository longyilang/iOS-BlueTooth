//
//  PeripheralsManager.m
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/25.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import "PeripheralsManager.h"

#import "BlueToothTransfer.h"

#import "BloodSugarDatawr.h"

#import "BloodPressureDatawr.h"

@interface PeripheralsManager()

@property (assign, nonatomic) Device device;

@property (strong, nonatomic) BlueToothTransfer *transfer;

@property (strong, nonatomic) BloodSugarDatawr *bdSugarDatawr;

@property (strong, nonatomic) BloodPressureDatawr *bdPressureDatawr;

@end

@implementation PeripheralsManager

- (instancetype)initWithDeveice:(Device)device blueToothState:(void(^)(CBManagerState))stateBlock
                bloodSugarSteps:(void(^)(BGMStepsTypes))stepBlock
                     reloadData:(void(^)(float))reloadBlock
                    time:(void(^)(NSInteger))timingBlock{
    self = [super init];
    _bdSugarDatawr = [[BloodSugarDatawr alloc]init];
    _bdSugarDatawr.stepStateHandle = stepBlock;
    _bdSugarDatawr.reloadDataHandle = reloadBlock;
    _bdSugarDatawr.timingHandle = timingBlock;
    [self initializeState:stateBlock device:device];
    return  self;
}

- (instancetype)initWithDeveice:(Device)device blueToothState:(void(^)(CBManagerState))stateBlock
             bloodPressureSteps:(void(^)(SPHYStepsTypes))stepBlock
                     reloadData:(void(^)(float))reloadBlock
                         result:(void(^)(NSDictionary *))resultBlock;{
    self = [super init];
    _bdPressureDatawr = [[BloodPressureDatawr alloc]init];
    _bdPressureDatawr.stepStateHandle = stepBlock;
    _bdPressureDatawr.reloadDataHandle = reloadBlock;
    _bdPressureDatawr.resultHandle = resultBlock;
    [self initializeState:stateBlock device:device];
    return  self;
}

- (void)scanPeripherals:(int)seconds
              scanState:(void(^)(BOOL success))scanBlock
           connectState:(void(^)(ConnectState))connectBlock{
    [self.transfer scanPeripherals:seconds scanState:scanBlock connectState:connectBlock];
}

- (void)initializeState:(void(^)(CBManagerState))stateBlock device:(Device)dv{
    self.device = dv;
    __weak typeof(self) weakSelf = self;
    _transfer = [[BlueToothTransfer alloc]initWithState:stateBlock];
    _transfer.device = dv;
    self.transfer.wrteCharacteristicsHandle = ^{
        [weakSelf writeData];
    };
    self.transfer.didUpdateValueHandle = ^(NSData *data){
        [weakSelf readData:data];
    };
}

- (void)writeData{
    if (self.device == bloodsugarmeter) {
        [self.bdSugarDatawr writeDataToTransfer:self.transfer];
    }else{
        self.bdPressureDatawr.transfer = self.transfer;
        [self.bdPressureDatawr writeDataToTransfer];
    }
}

- (void)readData:(NSData *)data{
    if (self.device == bloodsugarmeter) {
        [self.bdSugarDatawr readData:data];
    }else{
        [self.bdPressureDatawr readData:data];
    }
}

- (void)stopMeasure:(void(^)(BOOL stop))block{
    self.bdPressureDatawr.stopMeasureHandl = block;
    [self.bdPressureDatawr stopMeasureUsingRGKTSphygmomanometer];
}

- (void)disConnected{
    [self.transfer disConnected];
}

@end
