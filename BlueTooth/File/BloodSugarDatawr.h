//
//  BloodSugarDatawr.h
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/26.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BlueToothTransfer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BGMStepStateBlock)(BGMStepsTypes);

typedef void(^BGMReloadDataBlock)(float);

typedef void(^BGMtimingBlock)(NSInteger);

@interface BloodSugarDatawr : NSObject

@property (copy, nonatomic) BGMStepStateBlock stepStateHandle;

@property (copy, nonatomic) BGMReloadDataBlock reloadDataHandle;

@property (copy, nonatomic) BGMtimingBlock timingHandle;

- (void)writeDataToTransfer:(BlueToothTransfer *)transfer;

- (void)readData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
