# ChipletRing APP SDK说明书 IOS

## 一、	文档简介

### 1、	文档目的

为方便IOS端APP与戒指通讯进行二次开发 ，特对通讯协议进行封装 ，以达到简洁明了 ，让开发者不需要关注与戒指通讯层 ，专注业务逻辑交互层面开发。

### 2、	适用范围

支持 iOS 版本：iOS 13.0+
支持的语言版本：Swift 5.0+
开发工具: xcode 15+

### 3、	简介说明

这是智能戒指的蓝牙通信SDK，主要提供与戒指通信相关的API管理类RingManager，以及相关的数据存储管理类RingDBManager，同时也提供部分复杂算法的实现，例如睡眠相关算法。
**注：由于sdk需要用到蓝牙，仅支持真机调试，且注意在你项目的info中添加蓝牙权限说明**

### 4、	功能介绍

<table>
<thead>
<tr>
<th align="left">功能模块</th>
<th align="left">说明</th>
<th align="left">相关文档</th>
</tr>
</thead>
<tbody><tr>
<th align="left" rowspan="3" nowrap="nowrap">蓝牙基础模块</th>
<td align="left">蓝牙的开关操作</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">蓝牙的搜索链接操作</td>
<td align="left"></td>
</tr>
</tr>
<tr>
<td align="left">蓝牙的数据写入监听操作</td>
<td align="left"></td>
</tr>
<tr>
</tbody>
<th align="left" rowspan="13" nowrap="nowrap">通讯协议模块</th>
<td align="left">时间管理</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">版本管理</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">电量管理</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">步数管理</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">系统设置</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">采集周期设置</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">心率测量</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">血氧测量</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">心率变异性测量</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">历史记录管理</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">血压测量</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">蓝牙名称设置</td>
<td align="left"></td>
</tr>
<tr>
<td align="left">语音录制</td>
<td align="left"></td>
</table>

## 二、	快速使用

### 手动集成

1、分别将SDK&Demo/Rings-SDK/Example/frameworks 目录下的amOtaApi.framework、RingsSDK.framework集成到工程项目中。

2、确保在项目的Target->General->Frameworks,Libraries,and Embedded Content中添加amOtaApi.framework、RingsSDK.framework。

3、确保在项目的info.plist文件中添加蓝牙权限说明、网络权限。

4、在需要使用的地方引入SDK：

在使用的地方引入SDK即可：

```swift
import RingsSDK
```

**注：目前版本pod方法存在问题，静待更新**

## 三、	API功能说明

### 1、	设备连接相关

#### 1.1 搜索蓝牙

接口功能： 搜索附近的蓝牙设备，开始搜索后可通过回调获取搜索到的设备列表，也可通过 RingManager.shared.devices属性获取当前搜索到的设备
接口声明：

```swift
	RingManager.shared.startScan { devices in
	        print("搜索到的设备列表 =========>\(String(describing: devices))")
	}
```

注意事项：无
参数说明：无
返回值：devices是返回的附近符合要求的蓝牙设备

#### 1.2 停止搜索

接口功能：停止搜索附近的蓝牙设备，停止搜索不会清空已搜索到的设备列表，即不会清空RingManager.shared.devices
接口声明：

```swift
	RingManager.shared.stopScan()
```

注意事项：无
参数说明：无
返回值：无

#### 1.3 连接指定蓝牙

接口说明：通过设备的uuid来连接指定设备，uuid由搜索到的设备模型DeviceInfo中获取
接口声明：

```swift
	RingManager.shared.startConnect(deviceUUID: "uuidString", resultBlock: { res in
	            switch res {
	            case .success(let deviceInfo):
	                print("已连接设备 =========\(String(describing: deviceInfo.peripheralName))")
	            case .failure(let error):
	                print("连接失败 ========> \(error)")
	            }
	        })
```

注意事项：无
参数说明：无
返回值：无

#### 1.4 通过MAC连接戒指的示例

接口说明：通过设备的mac地址来连接指定设备
接口声明：

```swift
	 if sender.isSelected {
	            RingManager.shared.startScan { [self] devices in
	                BDLogger.info("设备列表 =========>\(String(describing: devices))")
	                if let devices = devices{
	                    let macTarget="B0:02:30:00:03:E1"
	                    for device in devices{
	                        var macString = ""
	                        if let macData = device.advertisementData["kCBAdvDataManufacturerData"] as? Data,macData.count >= 8 {
	                            macString = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", macData[7],macData[6],macData[5],macData[4],macData[3],macData[2])
	//                                print("扫描到的蓝牙mac:\(macString)")
	                        }
	                        if macString == macTarget{
	                            self.connectDevice(device: device)
	                            self.uuidS = device.uuidString
	                            print("公版连接指定mac,连接状态\(self.isDidConnect)")
	                        }
	                    }
	                }
	            }
	        } else {
	            RingManager.shared.stopScan()
	        }
```

注意事项：无
参数说明：无
返回值：无

#### 1.5 断开蓝牙

接口说明：断开当前设备的连接
接口声明：

```swift
	RingManager.shared.disconnect()
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 1.6 当前连接蓝牙

接口说明：获取当前已连接的设备
接口声明：

```swift
	let currentDevice = RingManager.shared.currentDevice
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 1.7 蓝牙连接状态

接口说明：获取设备连接状态
接口声明：

```swift
	let isDidConnect = RingManager.shared.isDidConnect
```

注意事项：无
参数说明：无
返回值：无

#### 1.8 监听连接状态

接口说明：设备连接状态变化监听
接口声明：

```swift
	RingManager.shared.connectStateChangeBlock = { isConnected in
	            print("是否已连接 ========\(isConnected)")
	        
	        }
```

注意事项：无
参数说明：无
返回值：无

### 2、	指令功能

#### 2.1 同步时间

接口说明：
接口声明：

```swift
	RingManager.shared.syncTime(date: Date()) { res in
	                  switch res {
	                  case .success(let isSuccess):
	                      print("同步时间结果======\(isSuccess)")
	                  case .failure(let error):
	                      print("同步失败======\(error)")
	             }
	         }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.2 读取时间

接口说明：
接口声明：

```swift
	RingManager.shared.readTime { res in
	              switch res {
	              case .success(let value):
	                  print("成功=====>\(value)毫秒")
	              case .failure(let error):
	                  print("失败=====>\(error)")
	              }
	          }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.3 读取软件版本号

接口说明：
接口声明：

```swift
	RingManager.shared.readAppVersion { res in
	                switch res {
	                case .success(let version):
	                    print("软件版本号=====>\(version)")
	                case .failure(let failure):
	                    print("失败=====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.4 读取硬件版本号

接口说明：
接口声明：

```swift
	RingManager.shared.readHardWareVersion { res in
	                switch res {
	                case .success(let version):
	                    print("硬件版本号=====>\(version)")
	                case .failure(let failure):
	                    print("失败=====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.5 读取电池电量

接口说明： 若返回的电池电量为101，则表示正在充电中
接口声明：

```swift
	RingManager.shared.readBattery { res in
	                switch res {
	                case .success(let value):
	                    print("电量=====>\(value)")
	                case .failure(let failure):
	                    print("失败=====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.6 读取电池充电状态

接口说明： 读取电池充电状态，返回结果为ChargeStatus枚举类型，值有:

* full：充满
* charging：充电中
* normal：正常未充电状态
  接口声明：

```swift
	RingManager.shared.readChargeStatus { res in
	                switch res {
	                case .success(let state):
	                    print("状态=====>\(state)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.7 实时测量心率值

接口说明： 输出实时测量心率值，单位BPM
接口声明：

```swift
	RingManager.shared.readHeartRate(progressBlock: { progress in
	                print(" 测量进度 =====>\(progress)")
	            }) { res in
	                switch res {
	                case .success(let value):
	                    print("心率=====>\(value)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.8 心率变异性

接口说明： 输出心率变异性，单位毫秒(ms)
接口声明：

```swift
	RingManager.shared.readHRV(progressBlock: { progress in
	                print(" 测量进度 =====>\(progress)")
	            }) { res in
	                switch res {
	                case .success(let value):
	                    print("心率变异性=====>\(value)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无
追加：返回值的第5-10字节含义（1-4字节可以视为头文件，不需要解析）
[5]:佩戴状态 0未佩戴，1佩戴，2充电中，3采集中，4繁忙
[6]:
[7]:心率变异性 0无效，单位ms
[8]:
[9:10]:
例，取最后一个上报的10字节数据0x00093100035c4c061c0e，第7个字节就是心率变异性,4c=76

#### 2.9 实时测量血氧值

接口说明： 输出实时血氧值
接口声明：

```swift
	RingManager.shared.readO2(progressBlock: { progress in
	                print(" 测量进度 =====>\(progress)")
	            }) { res in
	                switch res {
	                case .success(let value):
	                    print("血氧值=====>\(value)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.10 读取温度

接口说明： 读取当前温度，返回结果单位为摄氏度(℃)
接口声明：

```swift
	RingManager.shared.readTemperature { res in
	                switch res {
	                case .success(let value):
	                    BDLogger.info("温度=====>\(value)")
	                case .failure(let error):
	                    BDLogger.info("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无
追加：返回值的第5-7字节含义（1-4字节可以视为头文件，不需要解析）
[5]:佩戴状态 0测量中，1测量完成，2未佩戴，3繁忙
[6:7]: 温度(精度0.01) ，单位℃ 类型：有符号短整形
例，取最后一个上报的7字节数据0x 000d3400016f0d，第6，7个字节就是温度,0d6f=3439，即34.39℃

#### 2.11 读取当天实时步数

接口说明：
接口声明：

```swift
	RingManager.shared.readSteps { res in
	                switch res {
	                case .success(let value):
	                    print("步数=====>\(value)步")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.12 清除实时步数

接口说明：
接口声明：

```swift
	RingManager.shared.clearSteps { res in
	                switch res {
	                case .success(let isSuccess):
	                    print("结果=====>\(isSuccess)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.13 读取本地数据

接口说明： 读取本地历史数据，并且内部会将每一条数据存入到数据库中。关于如何从数据库中获取数据，见数据库管理类RingDBManager部分说明
接口声明：

```swift
	RingManager.shared.readDatas { progress, dataModel in
	                print(" 进度 =====>\(progress)==\(dataModel)")
	            } resultBlock: { res in
	                switch res {
	                case .success(let state):
	                    print("结果=====>\(state)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
该API获取设备历史数据，每获取到一条历史信息，都会通过progressBlock闭包回调，并在获取全部结果之后，通过resultBlock回调最终结果。其中dataModel为设备数据模型，相关属性如下：

```swift
	public final class RingDataModel: NSObject,TableCodable {
	    // 总个数
	    public var total:UInt32 = 0
	    // 序号，1开始
	    public var serialNum:UInt32 = 0
	    // 时间戳,秒
	    public var timestamp:UInt32 = 0
	    // 当天截止当前累计步数
	    public var stepsOfTheDay:UInt16 = 0
	    // 心率,0无效
	    public var rate = 0
	    // 血氧,0无效
	    public var O2 = 0
	    // 心率变异性,0无效
	    public var hrv = 0
	    // 精神压力指数,0无效
	    public var mentalStress = 0
	    // 温度，有符号的
	    public var temp:Float = 0
	    // 运动激烈程度 0: 静止  0x65:运动
	    public var isRunning = false
	    // 睡眠类型 0：无效 1：清醒 2：浅睡 3：深睡 4.眼动期
	    public var sleepType = 0
	    // RR 期间个数
	    public var RRNums = 0
	    // RR数组
	    public var rrs:[Int] = []28.	}
```

返回值：state为ReadDataResult枚举类型，值有:

```swift
	public enum ReadDataResult {
	    case empty // 无数据
	    case complete // 完成4
        }
```

#### 2.14 删除数据

接口说明： 删除全部本地数据历史记录
接口声明：

```swift
	RingManager.shared.clearRingData { res in
	                switch res {
	                case .success(let isSuccess):
	                    print("结果=====>\(isSuccess)")
	                case .failure(let failure):
	                    print("失败=====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.15 设置采集周期

接口说明： 采集周期设置，采集周期设置单位为秒(s)
接口声明：

```swift
	RingManager.shared.setFrequency(time: time) { res in
	                    switch res {
	                    case .success(let isSuccess):
	                        print("结果=====>\(isSuccess)")
	                    case .failure(let failure):
	                        print("失败=====>\(failure)")
	                    }
	                }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.16 读取采集周期

接口说明： 采集周期读取，读取到的采集周期为秒(s)
接口声明：

```swift
	RingManager.shared.readFrequency { res in
	                switch res {
	                case .success(let value):
	                    print("成功=====>\(value)秒")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.17 恢复出厂设置

接口说明：
接口声明：

```swift
	RingManager.shared.reset { res in
	                switch res {
	                case .success(let isSuccess):
	                    print("成功=====>\(isSuccess)")
	                case .failure(let error):
	                    print("失败=====>\(error)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.18 设置蓝牙名称

接口说明： 设置戒指蓝牙名称
参数说明：name:蓝牙名称，不超过12个字节，可以为中文、英文、数字，即4个汉字或者12个英文
接口声明：

```swift
	            manager.setBluetoothName(name: "你真的5H"){res in
	                switch res{
	                case .success(let success):
	                    BDLogger.info("成功=====>\(success)")
	                case .failure(let failure):
	                    BDLogger.info("失败=====>\(failure)")
	                }
	            }
```

注意事项：

* 1.调用此接口 ，需保证与戒指处于连接状态
* 2.设置蓝牙名称后，广播不会立即改变，需要等待一段时间
  参数说明：无
  返回值：无

#### 2.19 获取蓝牙名称

接口说明： 获取戒指蓝牙名称
接口声明：

```swift
	manager.readBluetoothName(){res in
	                switch res{
	                case .success(let success):
	                    BDLogger.info("成功=====>\(success)")
	                case .failure(let failure):
	                    BDLogger.info("失败=====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.20 心率停止测量

接口说明： 可以在测量心率时调用来停止测量
接口声明：

```swift
	manager.stopHeartRote{res in
	                switch res{
	                case .success(let success):
	                    BDLogger.info("成功====>\(success)")
	                case .failure(let failure):
	                    BDLogger.info("失败====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.21 血氧停止测量

接口说明： 可以在测量血氧时调用来停止测量
接口声明：

```swift
	manager.stopOxygenTest{res in
	                switch res{
	                case .success(let success):
	                    BDLogger.info("成功====>\(success)")
	                case .failure(let failure):
	                    BDLogger.info("失败====>\(failure)")
	                }
	            }
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.22 可设置时间的心率及测量返回RR原始数据

接口说明： 读取设定时间的心率及RR
接口声明：
参数声明：rrTime:心率测量时间 单位：S

```swift
	manager.readHeartRateWithRR(rrTime: 50, progressBlock: {progress in
	                BDLogger.info(" 进度 =====>\(progress)")
	            }, inHeartRRBlock: {seq, num, datas in
	                BDLogger.info("序号 ====>\(seq)")
	                BDLogger.info("数据个数 ====>\(num)")
	                BDLogger.info("RR数据 ====>\(datas)")
	            }, inHeartBlock: {heartValue in
	                BDLogger.info("测量中的心率\(heartValue)")
	            }, resultBlock: { res in
	                switch res {
	                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
	                case .failure(let failure):
	                    BDLogger.info("失败=====>\(failure)")
	                }
	            })
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 2.23 一键获取状态

接口说明： 一键获取系统支持的功能，简化版的接口集合，会返回电量、固件版本、采集周期等
接口声明：

```swift
	            manager.fetchSystemConfig(resultBlock: { res in
	                switch res{
	                case .success(let ringSysModel):
	                    BDLogger.info("固件版本:\(ringSysModel.firmwareVersion)")
	                    BDLogger.info("硬件版本:\(ringSysModel.hardwareVersion)")
	                    BDLogger.info("电量:\(ringSysModel.batteryLevel)")
	                    BDLogger.info("采集周期:\(ringSysModel.collectionInterval)")
	                    BDLogger.info("步数:\(ringSysModel.stepCount)")
	                    BDLogger.info("充电状态:\(ringSysModel.chargeStatus)")
	                    BDLogger.info("自检码:\(ringSysModel.selfCheck)")
	                case .failure(let failure):
	                    BDLogger.info("失败")
	                }
	            
	            })
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

### 3、	固件升级（OTA）

接口说明： 固件升级，参数fileUrl为固件文件所在的本地路径，升级进度以及结果通过handle进行回调
接口声明：

```swift
	if let path = Bundle.main.path(forResource: "otafileName", ofType: nil) {
	    let url = URL(fileURLWithPath: path)
	    RingManager.shared.startOTA(url) { res in
	        switch res {
	        case .start:
	            print("开始升级 =====>")
	        case .progress(let value):
	            print("升级进度 =====>\(value)")
	        case .success:
	            print("升级成功 =====>")
	        case .fail(let errorString):
	            print("升级失败 =====>\(errorString)")
	        }
	    }
	}
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

### 4、	数据库RingDBManager

使用 func readDatas(progressBlock: @escaping (Double, RingDataModel)->Void, resultBlock: @escaping (Result<ReadDataResult, ReadError>)->Void)从设备中获取到的本地历史数据，都会被保存到本地数据库中，访问数据库需要使用RingDBManager类，内部提供了一个单例对象用来操作相关数据，单例对象可通过RingDBManager.shared来获取，以下是相关的API说明。

#### 4.1 获取指定时间数据

接口说明： 从数据库中获取指定时间到目前为止的所有历史数据，timestamp参数为10位的时间戳
接口声明：

```swift
public func getObjects(from timestamp:TimeInterval) -> [RingDataModel]
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 4.2 获取某天数据

接口说明： 从数据库中获取某一天的历史数据（获取到的是该日期当天0时到24时的数据）
接口声明：

```swift
public func getObjects(of date:Date) -> [RingDataModel]
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 4.3 获取最近一条数据

接口说明： 从数据库中获取距离当前时间最近的一条历史数据
接口声明：

```swift
public func getLatestObject() -> RingDataModel?
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 4.4 获取某天睡眠数据

接口说明： 从数据库中获取某一天的睡眠数据(获取到的是该日期前一天18时到该日期18时的数据)，该部分接口得到的数据主要用于睡眠的计算
接口声明：

```swift
public func getSleepObjects(of date:Date) -> [RingDataModel]
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 4.5 删除所有数据

接口说明： 删除本地数据库所有历史数据
接口声明：

```swift
public func deleteAll() -> Bool
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 4.6 删除指定时间到现在的数据

接口说明： 删除从指定时间到目前为止的所有历史数据，timestamp参数为10位的时间戳
接口声明：

```swift
public func deleteAllBeforeTimestamp(timestamp:TimeInterval) -> Bool
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

### 5、	逻辑算法

该部分代码在RingManager类中，使用RingManager.shared获取单例，然后调用相关API即可

#### 5.1 计算步行距离

接口说明： 步行距离计算，steps参数为步数，stepSize参数为步长，单位为厘米(cm)，返回结果为距离，单位为米(m)
接口声明：

```swift
func calculateDistance(steps:Int,stepSize:Int) -> Float
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

#### 5.2 睡眠时间计算

接口说明： 睡眠时间计算，获取指定日期的睡眠数据及零星睡眠数据。返回值是一个元组，元组的第一个元素($0.0)是睡眠数据集合，第二个元素($0.1)是一个二维数组，是多个零星睡眠段的集合。$0.0数组中的第一个数据点的时间为入睡时间，最后一个数据点的时间为醒来时间，中间的各个数据点时间差累加即为睡眠时间。零星睡眠时长计算同理，使用$0.1数组中的数据分段计算即可。
接口声明：

```swift
	func caculateSleepData(targetDate: Date) -> ([RingDataModel], [[RingDataModel]])
使用示例：
	  let dateString = "2024-11-14 10:30:33"
	            let dateFormatter = DateFormatter()
	            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
	            dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 设置时区为 UTC
	            guard let targetDate = dateFormatter.date(from: dateString) else { return }
	//            let targetDate = Date() - 1.days
	            let (sleepData,sporadicSleepData) = manager.caculateSleepData(targetDate: targetDate)
	            BDLogger.info("睡眠数据\(sleepData)=========零星睡眠数据\(sporadicSleepData)")
	            break
```

注意事项：调用此接口 ，需保证与戒指处于连接状态    
参数说明：无    
返回值：无

#### 5.3 获取睡眠时长

接口说明： 获取睡眠时长，传入睡眠时间数据点集合，即可得出睡眠时长，返回睡眠时长单位为分钟(min)
接口声明：

```swift
func calculateSleepTimes(sleepDatas:[RingDataModel]) -> Int
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

### 6、网络相关功能

#### 6.1 获取SDK Token

接口说明：获取SDK使用所需的Token
接口声明：
```swift
RingNetworkManager.shared.createToken(apiKey: "your_api_key", userIdentifier: "user_id") { result in
    switch result {
    case let .success(token):
        print("✅ Token获取成功：")
        print("- Token: \(token)")
    case let .failure(error):
        print("❌ Token获取失败：")
        switch error {
        case .invalidParameters:
            print("参数无效，请检查API Key和用户ID")
        case let .httpError(code):
            print("HTTP错误：\(code)")
        case let .serverError(code, message):
            print("服务器错误[\(code)]: \(message)")
        case .invalidResponse:
            print("响应数据无效")
        case .decodingError:
            print("数据解析失败")
        case let .networkError(message):
            print("网络错误: \(message)")
        case .tokenError:
            print("Token异常")
        }
    }
}
```

注意事项：
- 需要提供有效的API Key和用户标识符
- 建议在应用启动时获取Token,SDK内部会缓存Token
参数说明：
- apiKey: SDK使用的API密钥
- userIdentifier: 用户唯一标识符
返回值：Token字符串或错误信息

#### 6.2 检查固件版本

接口说明：检查设备固件是否有新版本可用
接口声明：
```swift
RingNetworkManager.shared.checkDeviceVersion(version: "current_version") { result in
    switch result {
    case let .success(versionInfo):
        if versionInfo.hasNewVersion {
            print("""
            ✅ 发现新版本：
            - 版本号：\(versionInfo.version ?? "")
            - 下载地址：\(versionInfo.downloadUrl ?? "")
            - 文件名：\(versionInfo.fileName ?? "")
            """)
        } else {
            print("✅ 当前已是最新版本")
        }
        print("📝 消息：\(versionInfo.message)")
    case let .failure(error):
        // 处理错误情况
    }
}
```

注意事项：
- 需要提供当前设备的固件版本号
参数说明：
- version: 当前固件版本号
返回值：版本信息对象或错误信息

#### 6.3 下载固件

接口说明：下载新版本固件文件
接口声明：
```swift
let destinationPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
RingNetworkManager.shared.downloadFile(
    url: "firmware_download_url",
    fileName: "firmware.bin",
    destinationPath: destinationPath,
    progress: { progress in
        print("下载进度: \(progress)")
    },
    completion: { result in
        switch result {
        case let .success(filePathUrl):
            print("固件已保存到: \(filePathUrl)")
        case let .failure(error):
            print("固件下载失败: \(error)")
        }
    }
)
```

注意事项：
- 确保有足够的存储空间
- 建议在WiFi环境下下载
参数说明：
- url: 固件下载地址
- fileName: 固件文件名
- destinationPath: 保存路径
返回值：文件保存路径或错误信息

#### 6.4 固件升级

接口说明：执行固件升级(OTA)操作
接口声明：
```swift
RingManager.shared.startApolloOTA(fileUrl: firmwareFileUrl) { status in
    switch status {
    case .preparing:
        print("OTA: 准备开始升级...")
    case let .progress(progress):
        let percentage = Int(progress * 100)
        print("OTA: 升级进度 \(percentage)%")
    case .success:
        print("OTA: 固件传输成功")
    case let .error(message, code):
        print("OTA: 升级失败 - \(message) (错误码: \(code))")
    case .rebootSuccess:
        print("OTA: 设备重启成功")
    case .rebootFailed:
        print("OTA: 设备重启失败")
    }
}
```

注意事项：
- 升级过程中请确保设备电量充足
- 升级过程中请勿断开连接或关闭应用
参数说明：
- fileUrl: 固件文件本地路径
返回值：通过状态回调返回升级进度和结果

#### 6.5 读取蓝牙信号强度

接口说明：读取当前连接设备的蓝牙信号强度(RSSI)
接口声明：
```swift
RingManager.shared.startMonitorRSSI { result in
    switch result {
    case let .success(rssi):
        print("当前RSSI: \(rssi.intValue)")
    case let .failure(error):
        switch error {
        case .disconnect:
            print("设备未连接")
        case .fail:
            print("读取RSSI失败")
        default:
            print("其他错误: \(error)")
        }
    }
}
```

注意事项：
- 需要设备处于已连接状态
参数说明：无
返回值：RSSI值(负数,单位dBm)或错误信息

### 7、	日志配置

接口说明： 设置日志保存路径，默认保存在沙盒的Document中。可通过以下API修改默认保存路径
接口声明：

```swift
func configLogPath(directoryPath: String = defaultLogDirectoryPath)
```

注意事项：调用此接口 ，需保证与戒指处于连接状态
参数说明：无
返回值：无

## 四、	其他

### 1、	可能会遇到的问题

#### 1.1 使用SDK出错

将开发工具升级至适用范围
    支持 iOS 版本：iOS 13.0+
    支持的语言版本：Swift 5.0+
    开发工具: xcode 15+
**注：遇到问题可在github issues上提问**

#### 1.2 读取软件版本时，会多返回两个空格

版本号10个字节，空格补齐。
补充：固件版本一般是数字，末尾有可能是字母

#### 1.3 调用接口，返回超时

发送了一个指令，过了3秒，戒指没有响应，会返回超时超时问题要具体分析，以下是可能原因:

* 戒指未连接或已经断连
* 固件不支持的某些指令（非普通版本可用的指令，如语音录制，触控，震动等）
* 戒指返回的时间确实超过设定的超时时间，如某些情况下历史数据的指令返回时间较长
  
#### 1.4 戒指的睡眠功能如何测量

戴着戒指睡觉即可。如果睡眠过程中，APP读取readDatas接口（或其它两个获取数据的接口），也能获取到当前的睡眠数据。
