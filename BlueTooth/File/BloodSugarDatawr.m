//
//  BloodSugarDatawr.m
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/26.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import "BloodSugarDatawr.h"

@interface BloodSugarDatawr()

@property (assign, nonatomic) BOOL OVERDUE;

@property (assign, nonatomic) NSInteger timing;    //测量时长

@end

@implementation BloodSugarDatawr

- (void)writeDataToTransfer:(BlueToothTransfer *)transfer{
    Byte txDataBytes[3];
    int indx = 0;
    txDataBytes[indx++] = 0x7f;
    txDataBytes[indx++] = 0xf7;
    txDataBytes[indx++] = 0xed;
    NSData *commandData = [NSData dataWithBytes:&txDataBytes length:indx];
    
    dispatch_queue_t write = dispatch_queue_create("BGDwrite",DISPATCH_QUEUE_SERIAL);
    dispatch_async(write, ^{
        [transfer writeValueTocharacteristic:BGM_Write_Characteristic_Data data:commandData];
    });
}
 
- (void)readData:(NSData *)data{
    NSLog(@"接收数据---->%@",data);
    if (self.OVERDUE) {
        self.OVERDUE = NO;
        return;
    }
    
    //测量时间指令
    Byte *byte = (Byte *)[data bytes];
    //判断协议头是否正确
    if (byte[0] != 0x7f && byte[1] != 0xf7){
        return;
    }
    
    if (byte[2] == 0xa1) {
        self.timing = byte[3];
        self.timingHandle(self.timing);
        NSLog(@"传出时间--->%ld",(long)self.timing);
    }

    //测量状态
    switch (byte[3]) {
        case 0x11:
            self.stepStateHandle(0);
            break;
        case 0x19:
            self.stepStateHandle(1);
            self.OVERDUE = YES;
            break;
        case 0x21:
            self.stepStateHandle(2);
            break;
        case 0x29:
            self.stepStateHandle(3);
            break;
        case 0x31:{
            float value = 0.0;
            if (byte[2] == DetectionTypeXueTang) {//血糖
                value = ((int)(byte[5]<<8)+byte[4])*0.1;
            }
            else if (byte[2] == DetectionTypeDanGuChun) {//胆固醇
                value = ((int)(byte[5]<<8)+byte[4])*0.01;
            }
            else if (byte[2] == DetectionTypeNiaoSuan) {//尿酸
                value = ((int)(byte[5]<<8)+byte[4]);
            }
            self.stepStateHandle(4);
            self.reloadDataHandle(value);
            self.timing = 0;
            break;
        }
        case 0x00:
            self.stepStateHandle(5);
            break;
            
        default:
            break;
    }
}

@end
