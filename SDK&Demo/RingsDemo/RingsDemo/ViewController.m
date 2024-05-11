//
//  ViewController.m
//  RingsDemo
//
//  Created by mac on 2024/3/23.
//

#import "ViewController.h"
#import <ChipletSDK/ChipletSDK.h>
#import "XNProgressHUD.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *arrDevices;
@property (nonatomic, strong) DeviceInfo *connectDevice;

- (IBAction)btnSearch:(UIButton *)sender;
- (IBAction)btnConnectDevice:(UIButton *)sender;
- (IBAction)btnDisConnectDevice:(UIButton *)sender;
- (IBAction)btnReadBatteryLevel:(UIButton *)sender;
- (IBAction)btnReadChargingStatus:(UIButton *)sender;
- (IBAction)btnGetAppVersion:(UIButton *)sender;
- (IBAction)btnGetFirmwareVersion:(UIButton *)sender;
- (IBAction)btnSyncTime:(UIButton *)sender;
- (IBAction)btnReadTime:(UIButton *)sender;
- (IBAction)btnMeasureTemperature:(UIButton *)sender;
- (IBAction)btnMeasureHrv:(UIButton *)sender;
- (IBAction)btnMeasureO2:(UIButton *)sender;
- (IBAction)btnMeasureHeartRate:(UIButton *)sender;
- (IBAction)btnNoUpdateRecords:(UIButton *)sender;
- (IBAction)btnAllRecords:(UIButton *)sender;
- (IBAction)btnCleanRecords:(UIButton *)sender;
- (IBAction)btnAcquisitionCycleSet:(UIButton *)sender;
- (IBAction)btnRestoreFactory:(UIButton *)sender;
- (IBAction)btnGetNewData:(UIButton *)sender;
- (IBAction)btnGetSleepDatas:(UIButton *)sender;
- (IBAction)btnGetDatas:(UIButton *)sender;
- (IBAction)btnDeleteBase:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BleTool.shared.bShowLog = true;
//    BleTool.shared.deviceUUID = 设置这个值，则在搜索的时候，主动去连接
    
    DBTool.shared.bShowLog = true;
    
    BleTool.shared.onConnectionChanged = ^(enum ConnectionState state, DeviceInfo * _Nullable deviceInfo) {
        switch (state) {
            case ConnectionStateConnected: {
                NSLog(@"已连接设备：%@", deviceInfo);
                self->_connectDevice = deviceInfo;
                
                [XNProgressHUD.shared showWithTitle:@"设备已连接"];
            }
                break;
                
            case ConnectionStateDisconnected: {
                NSLog(@"已断开连接");
                self->_connectDevice = nil;
                
                [XNProgressHUD.shared showWithTitle:@"设备已断开"];
            }
                break;
                
            default:
                break;
        }
    };
    
    BleTool.shared.onCommandTimeout = ^{
        [XNProgressHUD.shared showErrorWithTitle:@"指令超时"];
        NSLog(@"指令超时");
    };
    
    BleTool.shared.onDevicesDiscovered = ^(NSArray<DeviceInfo *> * _Nonnull arrDevices) {
        NSLog(@"搜索到的设备：%@", arrDevices);
        self->_arrDevices = arrDevices;
    };
    
    BleTool.shared.onDataReceived = ^(NSDictionary<NSString *,id> * _Nonnull message) {
        NSLog(@"收到消息：%@", message);
        ReturnType type = [message[@"type"] integerValue];
        
        switch (type) {
            case ReturnTypeBattery: {
                // 读取电量  101 代码在充电中
                NSLog(@"当前电量: %ld", [message[@"value"] integerValue]);
                
                [XNProgressHUD.shared showWithTitle:[NSString stringWithFormat:@"当前电量: %ld", [message[@"value"] integerValue]]];
            }
                break;
                
            case ReturnTypeChargingStatus: {
                // 充电状态
                ChargingType cType = [message[@"value"] integerValue];
                switch (cType) {
                    case ChargingTypeTypeUncharged: {
                        NSLog(@"充电状态: 未充电");
                        
                        [XNProgressHUD.shared showWithTitle:@"未充电"];
                    }
                        break;
                        
                    case ChargingTypeTypeCharging: {
                        NSLog(@"充电状态: 充电中");
                        
                        [XNProgressHUD.shared showWithTitle:@"充电中"];
                    }
                        break;
                        
                    case ChargingTypeTypeFull: {
                        NSLog(@"充电状态: 已充满");
                        
                        [XNProgressHUD.shared showWithTitle:@"已充满"];
                    }
                        break;
                        
                    default:
                        NSLog(@"充电状态: 其它");
                        
                        [XNProgressHUD.shared showWithTitle:@"其它"];
                        break;
                }
            }
                break;
                
            case ReturnTypeAppVersion: {
                // 软件版本
                NSLog(@"软件版本: %@", message[@"value"]);
                
                [XNProgressHUD.shared showWithTitle:message[@"value"]];
            }
                break;
                
            case ReturnTypeFirmwareVersion: {
                // 固件版本
                NSLog(@"固件版本: %@", message[@"value"]);
                
                [XNProgressHUD.shared showWithTitle:message[@"value"]];
            }
                break;
                
            case ReturnTypeSyncTime: {
                // 同步时间
                OperationStatus opStatus = [message[@"value"] integerValue];
                NSLog(@"同步时间: %ld", opStatus);
                
                switch (opStatus) {
                    case OperationStatusOperationSuccessful: {
                        
                        [XNProgressHUD.shared showWithTitle:@"同步时间成功"];
                    }
                        break;
                        
                    case OperationStatusOperationFailed: {
                        
                        [XNProgressHUD.shared showWithTitle:@"同步时间失败"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case ReturnTypeReadTime: {
                // 读取时间
                NSLog(@"读取时间: %ld", [message[@"value"] integerValue]);
                
                // 使用NSDate类将时间戳转换为时间
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[message[@"value"] integerValue]/1000];
                
                // 使用NSDateFormatter将NSDate对象格式化为字符串
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *formattedDate = [dateFormatter stringFromDate:date];
                
                [XNProgressHUD.shared showWithTitle:formattedDate];
            }
                break;
                
            case ReturnTypeTemperature: {
                // 测量体温
                NSLog(@"测量体温: %.02f", [message[@"value"] floatValue]);
                
                [XNProgressHUD.shared showWithTitle:[NSString stringWithFormat:@"%@", message[@"value"]]];
            }
                break;
                
            case ReturnTypeProgress: {
                // 测量进度
                NSLog(@"测量进度: %.02f", [message[@"value"] floatValue]);
                
                [XNProgressHUD.shared showProgressWithTitle:@"测量进度" progress:[message[@"value"] floatValue]];
            }
                break;
                
            case ReturnTypeHrv: {
                // 实时心率变异性
                NSLog(@"实时心率变异性: %.02f", [message[@"value"] floatValue]);
                
                [XNProgressHUD.shared showWithTitle:[NSString stringWithFormat:@"%@", message[@"value"]]];
            }
                break;
                
            case ReturnTypeO2: {
                // 血氧
                NSLog(@"血氧: %.02f", [message[@"value"] floatValue]);
                
                [XNProgressHUD.shared showWithTitle:[NSString stringWithFormat:@"%@", message[@"value"]]];
            }
                break;
                
            case ReturnTypeHeartRate: {
                // 实时心率
                NSLog(@"实时心率: %.02f", [message[@"value"] floatValue]);
                
                [XNProgressHUD.shared showWithTitle:[NSString stringWithFormat:@"%@", message[@"value"]]];
            }
                break;
                
            case ReturnTypeBusy: {
                // 设备忙
                RingErrorType errorType = [message[@"value"] integerValue];
                
                switch (errorType) {
                    case RingErrorTypeTypeBusy: {
                        [XNProgressHUD.shared showWithTitle:@"设备忙"];
                    }
                        break;
                        
                    case RingErrorTypeTypeFailed: {
                        [XNProgressHUD.shared showWithTitle:@"测量失败"];
                    }
                        break;
                        
                    case RingErrorTypeTypeCharging: {
                        [XNProgressHUD.shared showWithTitle:@"充电中"];
                    }
                        break;
                        
                    case RingErrorTypeTypeNoWear: {
                        [XNProgressHUD.shared showWithTitle:@"未配戴戒指"];
                    }
                        break;
                        
                    case RingErrorTypeTypeInvalidData: {
                        [XNProgressHUD.shared showWithTitle:@"数据非法"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case ReturnTypeHisData: {
                if ([message[@"value"] isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"同步进度: %.02f", [message[@"value"][@"progress"] floatValue]);
                    [XNProgressHUD.shared showProgressWithTitle:@"同步进度" progress:[message[@"value"][@"progress"] floatValue]];
                }else if ([message[@"value"] isKindOfClass:[NSNumber class]]) {
                    NSInteger opStatus = [message[@"value"] integerValue];
                    
                    switch (opStatus) {
                        case OperationStatusOperationSuccessful: {
                            
                            [XNProgressHUD.shared showSuccessWithTitle:@"同步成功"];
                        }
                            break;
                            
                        case RingErrorTypeTypeNoNewData: {
                            
                            [XNProgressHUD.shared showWithTitle:@"暂无数据"];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }else {
                    NSLog(@"不应该存在这种情况");
                }
            }
                break;
                
            case ReturnTypeNoUploadedData: {
                if ([message[@"value"] isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"同步进度: %.02f", [message[@"value"][@"progress"] floatValue]);
                    [XNProgressHUD.shared showProgressWithTitle:@"同步进度" progress:[message[@"value"][@"progress"] floatValue]];
                }else if ([message[@"value"] isKindOfClass:[NSNumber class]]) {
                    NSInteger opStatus = [message[@"value"] integerValue];
                    
                    switch (opStatus) {
                        case OperationStatusOperationSuccessful: {
                            
                            [XNProgressHUD.shared showSuccessWithTitle:@"同步成功"];
                        }
                            break;
                            
                        case RingErrorTypeTypeNoNewData: {
                            
                            [XNProgressHUD.shared showWithTitle:@"暂无新数据"];
                        }
                            break;
                            
                        default:
                            break;
                    }
                }else {
                    NSLog(@"不应该存在这种情况");
                }
            }
                break;
                
            case ReturnTypeCleanData: {
                OperationStatus opStatus = [message[@"value"] integerValue];
                
                switch (opStatus) {
                    case OperationStatusOperationSuccessful: {
                        
                        [XNProgressHUD.shared showSuccessWithTitle:@"清空成功"];
                    }
                        break;
                        
                    case OperationStatusOperationFailed: {
                        
                        [XNProgressHUD.shared showWithTitle:@"清空失败"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case ReturnTypeAcquisitionCycle: {
                OperationStatus opStatus = [message[@"value"] integerValue];
                
                switch (opStatus) {
                    case OperationStatusOperationSuccessful: {
                        
                        [XNProgressHUD.shared showSuccessWithTitle:@"设置成功"];
                    }
                        break;
                        
                    case OperationStatusOperationFailed: {
                        
                        [XNProgressHUD.shared showWithTitle:@"设置失败"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            case ReturnTypeReset: {
                OperationStatus opStatus = [message[@"value"] integerValue];
                
                switch (opStatus) {
                    case OperationStatusOperationSuccessful: {
                        
                        [XNProgressHUD.shared showSuccessWithTitle:@"恢复出厂设置成功"];
                    }
                        break;
                        
                    case OperationStatusOperationFailed: {
                        [XNProgressHUD.shared showWithTitle:@"恢复出厂设置失败"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
    };
    
    DBTool.shared.onOperationHandler = ^(enum OperateType opType, enum OperationStatus opStatus) {
        switch (opType) {
            case OperateTypeGetLastObject: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"获取成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"获取失败"];
                }
            }
                break;
                
            case OperateTypeGetObjectsFromTimestamp: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"获取成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"获取失败"];
                }
            }
                break;
                
            case OperateTypeGetObjectsOfDate: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"获取成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"获取失败"];
                }
            }
                break;
                
            case OperateTypeGetSleepObjectsOfDate: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"获取成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"获取失败"];
                }
            }
                break;
                
            case OperateTypeDeleteAllBeforeTimestamp: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"删除成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"删除失败"];
                }
            }
                break;
                
            case OperateTypeDeleteAll: {
                if (opStatus == OperationStatusOperationSuccessful) {
                    [XNProgressHUD.shared showSuccessWithTitle:@"删除成功"];
                }else {
                    [XNProgressHUD.shared showErrorWithTitle:@"删除失败"];
                }
            }
                break;
                
            default:
                break;
        }
    };
}

- (IBAction)btnDeleteBase:(UIButton *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:@"2024-02-25 12:00:00"];
    
    // 使用NSDate对象的timeIntervalSince1970方法获取时间戳
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    
    [DBTool.shared deleteAllBeforeTimestampWithTimestamp:timestamp];
    
//    [DBTool.shared deleteAll];//删除全部
}

- (IBAction)btnGetDatas:(UIButton *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:@"2024-01-25 12:00:00"];
    
    // 使用NSDate对象的timeIntervalSince1970方法获取时间戳
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    
    NSArray<LocalDataModel *> *arr = [DBTool.shared getObjectsFrom:timestamp];
    
    NSLog(@"获取这段时间内的 %ld 条数据：%@", arr.count, arr);
}

- (IBAction)btnGetSleepDatas:(UIButton *)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:@"2024-01-25 12:00:00"];
    
    NSArray<LocalDataModel *> *arr = [DBTool.shared getSleepObjectsOf:date];
    
    NSLog(@"获取这段时间内的睡眠时间段的 %ld 条数据：%@", arr.count, arr);
}

- (IBAction)btnGetNewData:(UIButton *)sender {
    LocalDataModel *dataModel = [DBTool.shared getLatestObject];
    
    NSLog(@"最新一条数据：%@", dataModel);
}

- (IBAction)btnRestoreFactory:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared reset];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnAcquisitionCycleSet:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        // 方便输入框直接给值，单位 秒
        [BleTool.shared setAcquisitionCycleWithText:@"60"];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnCleanRecords:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [XNProgressHUD.shared showLoadingWithTitle:@"正在清空本地记录"];
        
        [BleTool.shared cleanHisData];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnAllRecords:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared getAllRecords];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnNoUpdateRecords:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared getNoUpdateRecords];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnMeasureHeartRate:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared measureHeartRate];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnMeasureO2:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared measureO2];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnMeasureHrv:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared measureHrv];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnMeasureTemperature:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared measureTemperature];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnReadTime:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared readTime];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnSyncTime:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared synchronizeTime];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnGetFirmwareVersion:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared getFirmwareVersion];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnGetAppVersion:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared getAppVersion];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnReadChargingStatus:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared obtainChargingStatus];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnReadBatteryLevel:(UIButton *)sender {
    if (BleTool.shared.isAppDisconnect == false) {
        [BleTool.shared readBatteryLevel];
    }else {
        [XNProgressHUD.shared showInfoWithTitle:@"请先连接设备"];
    }
}

- (IBAction)btnDisConnectDevice:(UIButton *)sender {
    if (self.connectDevice) {
        [XNProgressHUD.shared showLoadingWithTitle:@"断开连接中..."];
        
        [BleTool.shared disConnectDevice];
    }
}

- (IBAction)btnConnectDevice:(UIButton *)sender {
    if (!self.arrDevices.count) {
        [[XNProgressHUD shared] showErrorWithTitle:@"没有设备连接"];
        return;
    }
    
    [XNProgressHUD.shared showLoadingWithTitle:@"连接中..."];
    
    [BleTool.shared startConnectWithDevice:((DeviceInfo*)self.arrDevices.firstObject).peripheral];
}

- (IBAction)btnSearch:(UIButton *)sender {
    [BleTool.shared startScan];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
