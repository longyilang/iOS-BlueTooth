//
//  BloodPressureDatawr.h
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/26.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BlueToothTransfer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SPHYStepStateBlock)(SPHYStepsTypes);

typedef void(^SPHYReloadDataBlock)(float);

typedef void(^SPHYResultBlock)(NSDictionary *);

typedef void(^SPHYStopMeasureBlock)(BOOL);

@interface BloodPressureDatawr : NSObject

@property (strong, nonatomic) BlueToothTransfer *transfer;

@property (copy, nonatomic) SPHYStepStateBlock stepStateHandle;

@property (copy, nonatomic) SPHYReloadDataBlock reloadDataHandle;

@property (copy, nonatomic) SPHYResultBlock resultHandle;

@property (copy, nonatomic) SPHYStopMeasureBlock stopMeasureHandl;

- (void)writeDataToTransfer;

- (void)readData:(NSData *)data;

- (void)stopMeasureUsingRGKTSphygmomanometer;

@end

NS_ASSUME_NONNULL_END
