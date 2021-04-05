//
//  PeripheralsDefine.h
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/24.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#ifndef PeripheralsDefine_h
#define PeripheralsDefine_h

//血糖仪
#define BGM_NAME @"BBOX-S320"
#define BGM_Service_Data                        @"ACDCDCD0-0451-9D97-CC4B-F5A1B93E25BA"
#define BGM_Notity_Characteristic_Data          @"ACDCDCD2-0451-9D97-CC4B-F5A1B93E25BA"
#define BGM_Write_Characteristic_Data           @"ACDCDCD1-0451-9D97-CC4B-F5A1B93E25BA"

//血压仪
#define RGKT_Service_Data                        @"FFF0"
#define RGKT_NAME_PREFIX1 @"RBP"
#define RGKT_NAME_PREFIX2 @"BP"

//读写特征
#define RGKT_Notity_Characteristic_Data              @"FFF1"
#define RGKT_Write_Characteristic_Data               @"FFF2"

//血压仪查询设备信息
#define RGKT_GetInfo                                0x04

//血压仪数据包**************************************
//包头
#define RGKT_RequestStart                           0xCC
#define RGKT_RequestSecond                          0x80
#define RGKT_ResponseStart                          0xAA
#define RGKT_ResponseSecond                         0x80

//血压仪测量结果字段
#define HeartAtriumShake                            @"heartAtriumShake"         //房颤
#define HeartRateIrregular                          @"heartRateIrregular"       //心率不齐
#define IsHealth                                    @"isHealth"                 //是否正常
#define HighPressure                                @"highPressure"             //收缩压
#define LowPressure                                 @"lowPressure"              //舒张压
#define DifferencePressure                          @"differencePressure"       //脉压差
#define HeartRate                                   @"heartRate"                //心率

//血压测量操作
#define RGKT_BloodMeasureCommand                    0x01
#define RGKT_ConnectSphygmomanometer                0x01
#define RGKT_StartMeasure                           0x02
#define RGKT_StopMeasure                            0x03
#define RGKT_PowerOff                               0x04
#define RGKT_SendMeasureData                        0x05
#define RGKT_SendMeasureResult                      0x06
#define RGKT_SendWrongMessage                       0x07

//血压记忆操作
#define RGKT_BloodMemoryCommand                     0x02
#define RGKT_StartMemoryQuary                       0x01
#define RGKT_MemoryDelete                           0x02
#define RGKT_SendMemoryData                         0x03
#define RGKT_SendMemoryDataEnd                      0x04

//应答标识************************
#define RGKT_ResponseSucceed                        0x00
#define RGKT_ResponseFailed                         0x01

#endif /* PeripheralsDefine_h */

typedef NS_ENUM(NSInteger, Device){
    bloodsugarmeter,                    //血糖仪
    sphygmomanometer                    //血压仪
};

typedef NS_ENUM(NSInteger, ConnectState){
    success,
    fail,
    disconnect
};

typedef NS_ENUM (NSInteger, DetectionTypes) {
    DetectionTypeXueTang = 0x01, //血糖
    DetectionTypeNiaoSuan  = 0x02, //尿酸
    DetectionTypeDanGuChun = 0x08  //胆固醇
};

typedef NS_ENUM (NSUInteger, BGMStepsTypes) {
    BGMStepsInsertedTestPaper,   //开机并已经插入试纸
    BGMStepsTestPaperInvalid,    //试纸过期
    BGMStepsAlreadyBleeding,   //已经滴血
    BGMStepsBleedingError,    //滴血测量操作 有误
    BGMStepsBleedingSuccess,    //滴血测量反应完成，并出结果
    BGMStepsStandby   //待机:试纸拔出进入待机
};

typedef NS_ENUM(NSInteger,  SPHYStepsTypes)
{
    SPBTScanOverTime ,                      //扫描超时
    SPConnectDeviceSuccess,                 //连接设备成功
    SPConnectDeviceError,                   //连接设备失败
    SPMeasurementError,                     //测量途中发生失败
    SPDeviceReversal,                    //血压计反转
    SPDeviceAirLeak                    //血压计漏气
};
