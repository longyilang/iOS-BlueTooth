//
//  BloodPressureDatawr.m
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/26.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import "BloodPressureDatawr.h"

@interface BloodPressureDatawr()

@property (assign, nonatomic) SPHYStepsTypes stepTypes;

@property (strong, nonatomic) NSMutableData *responseData;     //启动应答

@end

@implementation BloodPressureDatawr

//写入指令
- (void)writeDataToTransfer{
    [self connectToRGKTSphygmomanometer];
}

//读取指令
- (void)readData:(NSData *)data{
    NSString *str = [data description];
    if ([str hasPrefix:@"<aa80"]||[str containsString:@"aa80"]){
        if (data.length >= 8) {
            //解析
            [self parsingData:data];
            return;
        }
        if (data.length <8 && self.responseData) {
            [self.responseData appendData:data];
            //解析
            [self parsingData:self.responseData];
            self.responseData = nil;
        }else{
            self.responseData = [NSMutableData dataWithData:data];
        }
    }else{
        //解析
    }
}

//解析指令
- (void)parsingData:(NSData *)data{
    NSLog(@"解析数据长度--->%lu",data.length);
    char *pData = (char *)[data bytes];
    int packageStart = (*pData++ + 256) % 256;
    int responseStart = (*pData++ + 256) % 256;
    if (packageStart == RGKT_ResponseStart && responseStart == RGKT_ResponseSecond){
        //蓝牙版本（直接跳过）
        pData++;
        //数据长度
        int length = *pData++;
        //类型标识
        int commandID = *pData++;
        
        switch (commandID)
        {
            case RGKT_BloodMeasureCommand:
            {
                //血压测量操作
                [self parserBloodMeasureWithData:pData DataLength:length Data:data];
                break;
            }
            case RGKT_BloodMemoryCommand:
            {
                //血压记忆操作
                [self parserBloodMemoryWithData:pData DataLength:length];
                break;
            }
            case RGKT_GetInfo:
            {
                //获取设备信息
                [self getPowerWithLength:length Data:pData];
                break;
            }
        }
    }
}

//发送指令
- (void)sendCommandDataLength:(char)length Flag:(char)flag Sflag:(char)sflag Dat:(char )dat
{
    int dataLength = 5 + length;
    unsigned char buffer[dataLength];
    unsigned char *pWrite = buffer;
    
    //前导码 2Byte
    memset(pWrite, RGKT_RequestStart, 1);
    //    pWrite += 2;
    pWrite ++;
    
    //
    memset(pWrite, RGKT_RequestSecond, 1);
    pWrite ++;
    
    //蓝牙版本 1Byte
    memset(pWrite, 0x02, 1);
    pWrite++;
    
    //数据长度 1Byte
    memset(pWrite, length, 1);
    pWrite++;
    
    //类型标识 1Byte
    memset(pWrite, flag, 1);
    pWrite++;
    
    //类型子码 1Byte
    memset(pWrite, sflag, 1);
    pWrite++;
    
    //数据/参数 1Byte
    memset(pWrite, dat, 1);
    pWrite++;
    
    //校验码 1Byte
    //    char fcs = buffer[1] ^ buffer[2];
    unsigned char fcs = 0;
    for (int i = 2; i < dataLength - 1; i++)
    {
        fcs = fcs ^ buffer[i];
    }
    memset(pWrite, fcs, 1);
    pWrite++;
    
    NSData *commandData = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    
    dispatch_queue_t write = dispatch_queue_create("RGTwrite",DISPATCH_QUEUE_SERIAL);
    dispatch_async(write, ^{
        [self.transfer writeValueTocharacteristic:RGKT_Write_Characteristic_Data data:commandData];
    });
}

//建立连接
-(void)connectToRGKTSphygmomanometer{
    char length = 0x03;
    char flag = 0x01;
    char sFlag = 0x01;
    char dat = 0x00;
    [self sendCommandDataLength:length Flag:flag Sflag:sFlag Dat:dat];
}

//开始测量
- (void)startMeasureUsingRGKTSphygmomanometer
{
    char length = 0x03;
    char flag = 0x01;
    char sFlag = 0x02;
    char dat = 0x00;
    [self sendCommandDataLength:length Flag:flag Sflag:sFlag Dat:dat];
}

//血压测量操作
- (void)parserBloodMeasureWithData:(char *)pData DataLength:(int)dataLength Data:(NSData *)data
{
    int subCommandID = *pData++;
    switch (subCommandID)
    {
        case RGKT_ConnectSphygmomanometer:
        {
            //解析连接到血压计数据
            [self parserConnectToRGKTSphygmomanometerWithLength:dataLength Data:pData];
            break;
        }
        case RGKT_StartMeasure:
        {
            //解析判断血压计开始测量状态
            [self parserStartMeasureUsingRGKTSphygmomanometerWithLength:dataLength Data:pData];
            break;
        }
        case RGKT_StopMeasure:
            self.stopMeasureHandl(YES);
            break;
        case RGKT_PowerOff:
            break;
        case RGKT_SendMeasureData:
        {
            //获取实时测量数据
            [self parserRGKTMeasureReceiveDataWithLength:dataLength Data:pData];
            break;
        }
        case RGKT_SendMeasureResult:
        {
            //获取测量结果数据
            if (data.length!=20){
                //[GeneralManager failureAlert:@"测量结果异常，请重新测量"];
                
                return;
            }
            [self parserRGKTMeasureResultWithLength:dataLength Data:pData];
            break;
        }
        case RGKT_SendWrongMessage:
        {
            //测量途中发生错误
            [self getWrongMessageWithLength:dataLength Data:data];
            break;
        }
    }
}

//获取设备电量
- (void)getPowerWithLength:(int)length Data:(char *)data{
    UInt8 firstPower = *data++;
    UInt8 secondPower = *data++;
    int power = firstPower * 256 + secondPower;
    NSString *powerStr = [NSString stringWithFormat:@"%d",power];
    //待完善
}

//血压记忆
- (void)parserBloodMemoryWithData:(char *)pData DataLength:(int)dataLength{
    int subCommandID = *pData++;
    switch (subCommandID){
        case RGKT_StartMemoryQuary:
            break;
        case RGKT_MemoryDelete:
            break;
        case RGKT_SendMemoryData:
            break;
        case RGKT_SendMemoryDataEnd:
            break;
    }
}

#pragma mark 血压测量操作

- (void)parserConnectToRGKTSphygmomanometerWithLength:(int)length Data:(char *)data{
    int status = *data++;
    if (status == RGKT_ResponseSucceed){
        NSLog(@"\n\n\n==============================连接到RGKT血压计成功\n\n\n");
        [self startMeasureUsingRGKTSphygmomanometer];
        if (self.stepStateHandle) {
            self.stepStateHandle(SPConnectDeviceSuccess);
        }
    }else if (status == RGKT_ResponseFailed){
        NSLog(@"\n\n\n==============================连接到RGKT血压计失败了\n\n\n");
        if (self.stepStateHandle) {
            self.stepStateHandle(SPConnectDeviceError);
        }
    }
}

- (void)parserStartMeasureUsingRGKTSphygmomanometerWithLength:(int)length Data:(char *)data{
    int status = *data++;
    if (status == RGKT_ResponseSucceed){
        NSLog(@"\n\n\n==============================开始测试纯真RGKT血压计成功\n\n\n");
    }else if (status == RGKT_ResponseFailed){
        NSLog(@"\n\n\n==============================开始测量使用RGKT血压计失败了\n\n\n");
    }
}

//实时测量数据
- (void)parserRGKTMeasureReceiveDataWithLength:(int)length Data:(char *)data{
    NSMutableString* hexString = [NSMutableString string];
    
    unsigned char *cdata = (unsigned char*)data;
    
    for (int i=0; i < length; i++)
    {
        [hexString appendFormat:@"%02x", *cdata++];
    }
    
    NSString * strA = [hexString substringWithRange:NSMakeRange(2, 2)];
    NSString * strB = [hexString substringWithRange:NSMakeRange(8, 2)];
    
    unsigned long valueA = strtoul([strA UTF8String],0,16);
    unsigned long valueB = strtoul([strB UTF8String],0,16);
    
    int a =((int)(valueA&0xff))*256 +((int)(valueB&0xff));
    if (self.reloadDataHandle) {
        self.reloadDataHandle(a);
    }
}

//测量结果
- (void)parserRGKTMeasureResultWithLength:(int)length Data:(char *)data{
    //收缩压
    UInt8 firstHighPressure = *data++;
    UInt8 secondHighPressure = *data++;
    int highPressure = firstHighPressure * 16 + secondHighPressure;
    //舒张压
    UInt8 firstLowPressure = *data++;
    UInt8 secondLowPressure = *data++;
    int lowPressure = firstLowPressure * 16 + secondLowPressure;
    //脉搏
    UInt8 firstHeartRate = *data++;
    UInt8 secondHeartRate = *data++;
    int heartRate = firstHeartRate * 16 + secondHeartRate;

    NSDictionary *dic = @{HighPressure:[NSString stringWithFormat:@"%d",highPressure],LowPressure:[NSString stringWithFormat:@"%d",lowPressure],DifferencePressure:[NSString stringWithFormat:@"%d",highPressure - lowPressure],HeartRate:[NSString stringWithFormat:@"%d",heartRate]};

    if (self.resultHandle) {
        self.resultHandle(dic);
    }
}

//血压测量操作失败
- (void)getWrongMessageWithLength:(int)length Data:(NSData *)data{
    Byte *byte = (Byte *)[data bytes];
    
    SPHYStepsTypes step;
    if (byte[6]==0x0b) {
        NSLog(@"\n\n\n==============================测量中途发生错误.血压计反转\n\n\n");
        step = SPDeviceReversal;

    }else if (byte[6]==0x02){
        NSLog(@"\n\n\n==============================测量中途发生错误.血压计漏气\n\n\n");
        step = SPDeviceAirLeak;
    }
    else{
        NSLog(@"\n\n\n==============================测量中途发生错误\n\n\n");
        step = SPMeasurementError;
    }
    if (self.stepStateHandle) {
        self.stepStateHandle(step);
    }
}

//停止测量
- (void)stopMeasureUsingRGKTSphygmomanometer{
    char length = 0x03;
    char flag = 0x01;
    char sFlag = 0x03;
    char dat = 0x00;
    [self sendCommandDataLength:length Flag:flag Sflag:sFlag Dat:dat];
}

@end
