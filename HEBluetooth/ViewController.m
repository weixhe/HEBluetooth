//
//  ViewController.m
//  HEBluetooth
//
//  Created by weixhe on 2017/4/18.
//  Copyright © 2017年 com.fumubang. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEBluetoothDefine.h"

#import "HEBluetooth.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *peripheralDataArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    peripheralDataArray = [[NSMutableArray alloc]init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    

    
    NSArray <CBUUID *> *scanForPeripheralsWithServices = nil;   // @[];
    NSDictionary <NSString *, id> *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary <NSString *, id> *connectPeripheralWithOptions = nil; //@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES};
    NSArray <CBUUID *> *discoverWithServices = nil; // @[];
    NSArray <CBUUID *> *discoverWithCharacteristics = nil;  // @[];
    
    [self bluetoothDelegate];
    [[HEBluetooth shareBluetooth] setOptionsWithScanForPeripheralsWithServices:scanForPeripheralsWithServices
                                                 scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                                                  connectPeripheralWithOptions:connectPeripheralWithOptions
                                                          discoverWithServices:discoverWithServices
                                                   discoverWithCharacteristics:discoverWithCharacteristics];
    
    
    // 1. 第一步：打开蓝牙后扫描周围设备
    [[HEBluetooth shareBluetooth] scanPeripherals];
    
}

- (void)bluetoothDelegate {
    __weak typeof(self) weakSelf = self;
    
    [[HEBluetooth shareBluetooth] setBlockOnCentralManagerDidUpdateState:^(HEBluetoothState bluetoothState) {
        NSLog(@"0000-中心设备状态修改");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnScanPeripherals:^(CBCentralManager *central, NSInteger timeInsterval, BOOL *stop) {
        NSLog(@"%ld", timeInsterval);
        
        if (timeInsterval == 60) {
            *stop = YES;
        }
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnCancelScan:^(CBCentralManager *centralManager) {
        NSLog(@"结束扫描");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"1111-发现设备");
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI];
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"2222-连接设备");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"3333-连接设备失败");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"4444-连接设备断开");
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"5555-发现设备的服务");
    }];
    
    
    [[HEBluetooth shareBluetooth] setBlockOnDidDiscoverIncludedServicesForService:^(CBService *service, NSError *error) {
        NSLog(@"121212-发现服务中的自服务");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"161616-发现设备的特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"6666-阅读特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidWriteValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"7777-写入特征");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"8888-发现设备特征的描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"9999-阅读特征的描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidWriteValueForDescriptor:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"101010-写入特征描述");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"111111-更新特征通知");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"131313-信号强度阅读、更新");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidUpdateName:^(CBPeripheral *peripheral) {
        NSLog(@"141414-设备名称改变");
    }];
    
    [[HEBluetooth shareBluetooth] setBlockOnDidModifyServices:^(CBPeripheral *peripheral, NSArray *invalidatedServices) {
        NSLog(@"151515-外设服务变化");
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSArray *peripherals = [peripheralDataArray valueForKey:@"peripheral"];
    
    if(![peripherals containsObject:peripheral]) {
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [peripheralDataArray addObject:item];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return peripheralDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *item = [peripheralDataArray objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
    NSNumber *RSSI = [item objectForKey:@"RSSI"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
    NSString *peripheralName;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        
        peripheralName = peripheral.name;
        
    }else{
        peripheralName = [peripheral.identifier UUIDString];
    }
    
    cell.textLabel.text = peripheralName;
    //信号和服务
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[HEBluetooth shareBluetooth] cancelScan];
    
}

@end
