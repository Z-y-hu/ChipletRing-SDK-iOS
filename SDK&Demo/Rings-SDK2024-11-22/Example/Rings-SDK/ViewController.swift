//
//  ViewController.swift
//  Rings-SDK
//
//  Created by weicb on 10/07/2023.
//  Copyright (c) 2023 weicb. All rights reserved.
//

import UIKit
// import Rings_iOS_SDK
import RingsSDK
import QMUIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//       let lastModel = RingDBManager.shared.getLatestObject()
//        print("最新一条=======>\(lastModel)")
//        let lastModels = RingDBManager.shared.getObjects(from: 1702545773)
//        print("指定数据=======>\(lastModels)")
    }
    var uuidS:String = "" //保存uuid
    var isDidConnect = RingManager.shared.isDidConnect //连接状态
    var status = 0
    
    @IBAction func startOrStopScanAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            
    
            RingManager.shared.startScan { [self] devices in
                BDLogger.info("设备列表 =========>\(String(describing: devices))")
                if let devices = devices{
//                    let macTarget = "E7:C4:4D:8F:B9:A7"
//                    let macTarget = "12:34:56:46:54:65"
//                    let macTarget = "C0:00:00:00:00:30"
                   // let macTarget = "B2:20:11:00:00:C6"
                    let macTarget="B0:02:30:00:03:E1"
                    //"B0:02:30:00:00:07"
//                    let macTarget = "B0:02:B0:00:01:E1"
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
                            //RingManager.shared.stopScan()
                           
                        }
                    }
//                    self.connectDevice(device: device)
                }
            }
        } else {
            RingManager.shared.stopScan()
        }
    }

    //  连接设备
    func connectDevice(device: DeviceInfo) {
        BDLogger.info(" ========> 开始连接设备")

        RingManager.shared.startConnect(deviceUUID: device.uuidString, resultBlock: { res in
            self.isDidConnect = RingManager.shared.isDidConnect
            switch res {
            case .success(let deviceInfo):
                BDLogger.info("已连接设备 =========\(String(describing: deviceInfo.peripheralName))连接状态\(self.isDidConnect)")
            case .failure(let error):
                BDLogger.info("连接失败 ========> \(error)连接状态\(self.isDidConnect)")
                
            }
        })
    }

    // 断开连接
    @IBAction func disconnectAction(_ sender: UIButton) {
        RingManager.shared.disconnect()
    }

    @IBAction func btnAction(_ sender: UIButton) {
        let manager = RingManager.shared
        switch sender.tag {
        case 0: // 读取电量
//            manager.readBattery { res in
//                switch res {
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
//            manager.setBluetoothName(name: "你真的5H"){res in
//                switch res{
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
//            manager.readBluetoothName(){res in
//                switch res{
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
            self.uuidS = "77A44F4F-BB0A-DD02-065A-51289A6BEFE1"
            manager.startReConnect(deviceUUID: self.uuidS,deviceName: "BCL603")
        case 1: // 读取充电状态
            self.isDidConnect = RingManager.shared.isDidConnect
            BDLogger.info("查看连接状态\(isDidConnect)")
//            manager.readChargeStatus { res in
//                switch res {
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
//            manager.stopOxygenTest{res in
//                switch res{
//                case .success(let success):
//                    BDLogger.info("成功====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败====>\(failure)")
//                }
//            }
        case 2: // 读取戒指中的数据
            manager.readNewHistoryDatas{progress,dataModel in
                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res{
                case .success(let success):
                    BDLogger.info("成功====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败====>\(failure)")
                }
            }
//            manager.readDatas { progress, dataModel in
//                BDLogger.info(" 进度 =====>\(progress)==\(dataModel)")
//            } resultBlock: { res in
//                switch res {
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
        case 3:
            let dateString = "2024-11-14 10:30:33"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 设置时区为 UTC
            guard let targetDate = dateFormatter.date(from: dateString) else { return }
//            let targetDate = Date() - 1.days
            let (sleepData,sporadicSleepData) = manager.caculateSleepData(targetDate: targetDate)
            BDLogger.info("睡眠数据\(sleepData)=========零星睡眠数据\(sporadicSleepData)")
            break
        case 4: // 读取心率
//            manager.readHeartRate(progressBlock: { progress in
//                BDLogger.info(" 进度 =====>\(progress)")
//            }, isOpenWave: true) { seq, num, datas in
//                BDLogger.info("序号 ====>\(seq)")
//                BDLogger.info("数据个数 ====>\(num)")
//                BDLogger.info("波形数据 ====>\(datas)")
//            } inHeartBlock: { heartValue in
//                BDLogger.info("测量中的心率\(heartValue)")
//            } resultBlock: { res in
//                switch res {
//                case .success(let success):
//                    BDLogger.info("成功=====>\(success)")
//                case .failure(let failure):
//                    BDLogger.info("失败=====>\(failure)")
//                }
//            }
            //读取设定时间的心率及RR
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
        case 5: // 读取血氧
            manager.readO2(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 6: // 读取心率变异性
            manager.readHRV(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 7: // 读取温度
            manager.readTemperature { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }

        case 8: // 读取软件版本号
            manager.readAppVersion { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 9: // 读取硬件版本号
            manager.readHardWareVersion { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 10: // 清除戒指中的所有数据
            manager.clearRingData { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 11: // 戒指恢复出厂设置
            manager.reset { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 12: // 设置采集周期
            let alert = QMUIAlertController(title: "请输入采集周期，单位秒(最小值60s)", message: "", preferredStyle: .alert)
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.placeholder = "请输入"
                tf.font = .systemFont(ofSize: 16)
                tf.textInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            }
            let checkAction = QMUIAlertAction(title: "确定", style: .default) { alertVC, alertAction in
                guard let text = alertVC.textFields?.first?.text,
                      let time = Int(text) else {
                    QMUITips.show(withText: "请输入正确的时间")
                    return
                }
                RingManager.shared.setFrequency(time: time) { res in
                    switch res {
                    case .success(let success):
                        BDLogger.info("成功=====>\(success)")
                    case .failure(let failure):
                        BDLogger.info("失败=====>\(failure)")
                    }
                }
            }
            checkAction.buttonAttributes = [.font: UIFont.qmui_mediumSystemFont(ofSize: 16)!, .foregroundColor: UIColor.qmui_color(withHexString: "478EDA")!]
            let cancelAction = QMUIAlertAction(title: "取消", style: .cancel)
            cancelAction.buttonAttributes = [.font: UIFont.qmui_mediumSystemFont(ofSize: 16)!, .foregroundColor: UIColor.qmui_color(withHexString: "999999")!]
            alert.addAction(checkAction)
            alert.addAction(cancelAction)
            alert.modalPresentationStyle = .fullScreen
            alert.showWith(animated: true)
            alert.textFields?.first?.becomeFirstResponder()
        case 13: // OTA固件升级
            guard let path = Bundle.main.path(forResource: "2.4.8.6Z3K.hex16", ofType: nil) else { return }
            let url = URL(fileURLWithPath: path)
            manager.startOTA(url, handle: { res in
                switch res {
                case .start:
                    BDLogger.info("======> 开始升级")
                case .progress(let progress):
                    BDLogger.info("升级进度======> \(progress)")
                case .success:
                    BDLogger.info("======>升级成功")
                case .fail(let errorString):
                    BDLogger.info("升级失败 ======>\(errorString)")
                }
            })
        case 14: // 读取采集周期
            manager.readFrequency { res in
                switch res {
                case .success(let value):
                    BDLogger.info("成功=====>\(value)秒")
                case .failure(let error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
        case 15: // 读取戒指时间
            manager.readTime { res in
                switch res {
                case .success(let value):
                    BDLogger.info("成功=====>\(value)毫秒")
                case .failure(let error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
        case 16: // 读取实时步数
            manager.readSteps { res in
                switch res {
                case .success(let value):
                    BDLogger.info("成功=====>\(value)步")
                case .failure(let error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
        case 17: // 清除实时步数
            manager.clearSteps { res in
                switch res {
                case .success(let value):
                    BDLogger.info("成功=====>\(value)")
                case .failure(let error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
        default:
            break
        }
    }
}
