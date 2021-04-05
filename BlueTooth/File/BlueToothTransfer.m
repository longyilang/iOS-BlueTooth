//
//  BlueToothTransfer.m
//  MKSmartHome
//
//  Created by MKTech01 on 2021/3/24.
//  Copyright © 2021 MKTECH. All rights reserved.
//

#import "BlueToothTransfer.h"

@interface BlueToothTransfer()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (strong, nonatomic) CBPeripheral *peripheral;

@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;

@property (strong, nonatomic) NSTimer *scanTime;

@end

@implementation BlueToothTransfer

- (instancetype)initWithState:(void(^)(CBManagerState state))stateBlock{
    self = [super init];
    self.bluetoothStateHandle = stateBlock;
    dispatch_queue_t centralQueue = dispatch_queue_create("centralQueue",DISPATCH_QUEUE_SERIAL);
    NSDictionary *dic = @{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:NO]};
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:dic];
    return self;
}

- (void)scanPeripherals:(int)seconds
         scanState:(void(^)(BOOL success))scanBlock
         connectState:(void(^)(ConnectState))connectBlock;{
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        if (self.peripheral) {
            [self connectPeripheral:self.peripheral];
        }
        self.scanStateHandle = scanBlock;
        self.connectStateHandle = connectBlock;
    
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
        [self.centralManager scanForPeripheralsWithServices:nil options:dic];
       self.scanTime = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timingScan) userInfo:nil repeats:NO];
    }else{
        if (self.bluetoothStateHandle) {
            self.bluetoothStateHandle(self.centralManager.state);
        }
    }
}

- (void)timingScan{
    [self stopScan];
    self.scanStateHandle(NO);
}

- (void)stopScan{
    if (self.scanTime) {
        [self.scanTime invalidate];
        self.scanTime = nil;
    }
    [self.centralManager stopScan];
}

- (void)disConnected{
    [self stopScan];
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
    }
}

-(void)connectPeripheral:(CBPeripheral *)peripheral{
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    [self.centralManager connectPeripheral:self.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES, CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES, CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
}

-(void)writeValueTocharacteristic:(NSString *)characteristic data:(NSData *)data{
    self.writeCharacteristic.properties;
    [self.peripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

#pragma mark CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (self.bluetoothStateHandle) {
        self.bluetoothStateHandle(central.state);
    }
}

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
//    NSLog(@"--->蓝牙于后台被杀掉时，重连之后会首先调用此方法，可以获取蓝牙恢复时的各种状态");
//}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    BOOL BGM = [peripheral.name containsString:BGM_NAME];
    BOOL RGKT = [peripheral.name hasPrefix:RGKT_NAME_PREFIX1] || [peripheral.name hasPrefix:RGKT_NAME_PREFIX2];

    if ((BGM && self.device == 0) || (RGKT && self.device == 1)) {
        [self stopScan];
        self.scanStateHandle(YES);
        [self connectPeripheral:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //非断开连接状态再次连接设备会首先进该回调方法 scanning 为yes 需要cancel
    if (self.scanTime) {
        [self stopScan];
    }
    self.connectStateHandle(success);
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    self.connectStateHandle(fail);
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    self.connectStateHandle(disconnect);
}

#pragma mark CBPeripheralDelegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        return;
    }
    for (CBService *s in peripheral.services) {
        if ([s.UUID.UUIDString isEqualToString:BGM_Service_Data]) {
            [peripheral discoverCharacteristics:nil forService:s];
        }
        if ([s.UUID.UUIDString isEqualToString:RGKT_Service_Data]) {
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        return;
    }
    for (CBCharacteristic *c in service.characteristics) {
        //NSLog(@"%@",[NSString stringWithFormat:@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID]);
        if ([c.UUID.UUIDString isEqualToString:BGM_Notity_Characteristic_Data]) {
            //订阅血糖检测器读特征
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        if ([c.UUID.UUIDString isEqualToString:BGM_Write_Characteristic_Data]) {
            //血糖检测器写入特征
            self.writeCharacteristic = c;
            if (self.wrteCharacteristicsHandle) {
                self.wrteCharacteristicsHandle();
            }
        }
        if ([c.UUID.UUIDString isEqualToString:RGKT_Notity_Characteristic_Data]) {
            //订阅血压检测器读特征
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        if ([c.UUID.UUIDString isEqualToString:RGKT_Write_Characteristic_Data]) {
            //血压检测器写入特征
            self.writeCharacteristic = c;
            if (self.wrteCharacteristicsHandle) {
                self.wrteCharacteristicsHandle();
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.didUpdateValueHandle) {
        self.didUpdateValueHandle(characteristic.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //数据写入成功与否的状态回调
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //订阅特征的成功与否的状态回调
}


@end


