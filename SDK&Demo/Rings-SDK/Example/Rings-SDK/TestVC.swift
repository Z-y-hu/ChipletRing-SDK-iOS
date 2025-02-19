//
//  TestVC.swift
//  Rings-SDK_Example
//
//  Created by JianDan on 2025/1/10.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import QMUIKit
import RingsSDK
import UIKit

class TestVC: UIViewController {
    var deviceMac = ""
    @IBOutlet var log_Btn: UIButton!
    var logVC = LogVC()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let log_VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogVC_ID") as? LogVC {
            logVC = log_VC
            log_VC.readLogContent()
        }

        RingManager.shared.connectStateChangeBlock = { state in
            if state {
                BDLogger.info("蓝牙设备已连接")
            } else {
                BDLogger.info("蓝牙设备断开连接")
            }
        }
    }

    @IBAction func clickAction(_ sender: UIButton) {
        let manager = RingManager.shared
        switch sender.tag {
        case 1000: //  搜索并连接
            guard !deviceMac.isEmpty else {
                let alert = QMUIAlertController(title: "请输入连接设备的Mac地址(忽略大小写，eg:00:00:00:00:00:00)", message: "", preferredStyle: .alert)
                alert.addTextField { tf in
                    tf.placeholder = "请输入Mac地址"
                    tf.font = .systemFont(ofSize: 16)
                    tf.textInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
                }
                let checkAction = QMUIAlertAction(title: "确定", style: .default) { alertVC, _ in
                    guard let text = alertVC.textFields?.first?.text, !text.isEmpty else {
                        QMUITips.show(withText: "请输入正确的Mac地址")
                        return
                    }
                    guard self.isValidMacAddress(text) else {
                        QMUITips.show(withText: "请输入正确的Mac地址")
                        return
                    }

                    // 将text转为大写
                    self.deviceMac = text.uppercased()
                    BDLogger.info("=========>开始扫描设备")
                    manager.startScan { [self] devices in
                        BDLogger.info("设备列表 =========>\(String(describing: devices))")
                        if let devices = devices {
                            for device in devices {
                                var macString = ""
                                if let macData = device.advertisementData["kCBAdvDataManufacturerData"] as? Data, macData.count >= 8 {
                                    macString = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", macData[7], macData[6], macData[5], macData[4], macData[3], macData[2])
                                }
                                if macString == deviceMac {
                                    BDLogger.info("--------发现目标设备并开始连接--------")
                                    BDLogger.info("连接蓝牙设备Mac地址 =========>\(macString)")
                                    BDLogger.info("连接蓝牙设备UUID =========>\(device.uuidString)")
                                    RingManager.shared.stopScan()
                                    self.connectDevice(device: device)
                                }
                            }
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
                return
            }
            BDLogger.info("=========>开始扫描设备")
            manager.startScan { [self] devices in
                BDLogger.info("设备列表 =========>\(String(describing: devices))")
                if let devices = devices {
                    for device in devices {
                        var macString = ""
                        if let macData = device.advertisementData["kCBAdvDataManufacturerData"] as? Data, macData.count >= 8 {
                            macString = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", macData[7], macData[6], macData[5], macData[4], macData[3], macData[2])
                        }
                        if macString == deviceMac {
                            BDLogger.info("--------发现目标设备并开始连接--------")
                            BDLogger.info("连接蓝牙设备Mac地址 =========>\(macString)")
                            BDLogger.info("连接蓝牙设备UUID =========>\(device.uuidString)")
                            RingManager.shared.stopScan()
                            self.connectDevice(device: device)
                        }
                    }
                }
            }
            break
        case 1001: // 断开连接
            BDLogger.info("=========>执行断开连接操作")
            manager.disconnect()
            deviceMac = ""
            break
        case 1002: // 同步时间
            BDLogger.info("=========>执行同步时间操作")
            manager.syncTime(date: Date()) { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1003: // 读取时间
            BDLogger.info("=========>执行读取时间操作")
            manager.readTime { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)毫秒")
                    let dateFormate = DateFormatter()
                    dateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateFormate.timeZone = TimeZone.current
                    let timeDate = dateFormate.string(from: Date(timeIntervalSince1970: TimeInterval(value / 1000)))
                    BDLogger.info("时间=====>\(timeDate)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1004: // 读取步数
            BDLogger.info("=========>执行读取步数操作")
            manager.readSteps { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)步")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1005: // 清除步数
            BDLogger.info("=========>执行清除步数操作")
            manager.clearSteps { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1006: // 读取电量
            BDLogger.info("=========>执行读取电量操作")
            manager.readBattery { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1007: // 读取充电状态
            BDLogger.info("=========>执行读取充电状态操作")
            manager.readChargeStatus { res in
                switch res {
                case let .success(success):
                    if success == .full {
                        BDLogger.info("充电状态=====>充满")
                    } else if success == .charging {
                        BDLogger.info("充电状态=====>充电中")
                    } else {
                        BDLogger.info("充电状态=====>未充电")
                    }
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1008: // 体温
            BDLogger.info("=========>执行体温操作")
            manager.readTemperature { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1009: // 实时血氧
            BDLogger.info("=========>执行实时血氧操作")
            manager.readO2(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1010: // 心率变异性
            BDLogger.info("=========>执行心率变异性操作")
            manager.readHRV(progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, isOpenWave: true) { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("波形数据 ====>\(datas)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1011: // 实时心率
            BDLogger.info("=========>执行实时心率及间期RR-50操作")
            manager.readHeartRateWithRR(rrTime: 50, progressBlock: { progress in
                BDLogger.info(" 进度 =====>\(progress)")
            }, inHeartRRBlock: { seq, num, datas in
                BDLogger.info("序号 ====>\(seq)")
                BDLogger.info("数据个数 ====>\(num)")
                BDLogger.info("RR数据 ====>\(datas)")
            }, inHeartBlock: { heartValue in
                BDLogger.info("测量中的心率:\(heartValue)")
            }, resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            })
            break
        case 1012: // 清除数据
            BDLogger.info("=========>执行清除数据操作")
            manager.clearRingData { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1013: // 读取全部数据
            BDLogger.info("=========>执行读取全部数据操作")
            manager.readAllHistoryDatas { progress, dataModel in
                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败====>\(failure)")
                }
            }
            break
        case 1014: // 读取未上传数
            BDLogger.info("=========>执行读取未上传数据操作")
            manager.readNewHistoryDatas { progress, dataModel in
                BDLogger.info("进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败====>\(failure)")
                }
            }

            break
        case 1015: // 固件版本
            BDLogger.info("=========>执行固件版本操作")
            manager.readAppVersion { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1016: // 硬件版本
            BDLogger.info("=========>执行硬件版本操作")
            manager.readHardWareVersion { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        case 1017: // 睡眠算法
            BDLogger.info("=========>获取指定日期的睡眠数据")
            let sleepModel = manager.caculateSleep(targetDate: Date())
            BDLogger.info("睡眠数据\(sleepModel.description)")
            break
        case 1018: // 设置采集周期
            BDLogger.info("=========>执行设置采集周期操作")
            let alert = QMUIAlertController(title: "请输入采集周期，单位秒(最小值60s)", message: "", preferredStyle: .alert)
            alert.addTextField { tf in
                tf.keyboardType = .numberPad
                tf.placeholder = "请输入"
                tf.font = .systemFont(ofSize: 16)
                tf.textInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
            }
            let checkAction = QMUIAlertAction(title: "确定", style: .default) { alertVC, _ in
                guard let text = alertVC.textFields?.first?.text,
                      let time = Int(text) else {
                    QMUITips.show(withText: "请输入正确的时间")
                    return
                }
                RingManager.shared.setFrequency(time: time) { res in
                    switch res {
                    case let .success(success):
                        BDLogger.info("成功=====>\(success)")
                    case let .failure(failure):
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
            break
        case 1019: // 读取采集周期
            BDLogger.info("=========>执行读取采集周期操作")
            manager.readFrequency { res in
                switch res {
                case let .success(value):
                    BDLogger.info("成功=====>\(value)秒")
                case let .failure(error):
                    BDLogger.info("失败=====>\(error)")
                }
            }
            break
        case 1020:
            BDLogger.info("=========>执行恢复出厂设置操作")
            manager.reset { res in
                switch res {
                case let .success(success):
                    BDLogger.info("成功=====>\(success)")
                case let .failure(failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
            break
        default:
            break
        }
    }

    @IBAction func log_Action(_ sender: Any) {
        present(logVC, animated: true, completion: nil)
    }

    //  连接设备
    func connectDevice(device: DeviceInfo) {
        BDLogger.info(" ========> 开始连接设备")
        RingManager.shared.startConnect(deviceUUID: device.uuidString, resultBlock: { res in
            switch res {
            case let .success(deviceInfo):
                BDLogger.info("已连接设备 =========>\(String(describing: deviceInfo.peripheral.name))")
                BDLogger.info("连接状态 =========>\(RingManager.shared.isDidConnect)")
            case let .failure(error):
                BDLogger.info("连接失败 ========> \(error)连接状态\(RingManager.shared.isDidConnect)")
            }
        })
    }

    // 校验mac地址是否正确
    func isValidMacAddress(_ mac: String) -> Bool {
        // 只允许冒号分隔，并忽略大小写
        let pattern = "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        guard let regex = regex else { return false }

        let range = NSRange(location: 0, length: mac.utf16.count)
        let match = regex.firstMatch(in: mac, options: [], range: range)
        return (match != nil)
    }
}
