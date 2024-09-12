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

    @IBAction func startOrStopScanAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            RingManager.shared.startScan { devices in
                BDLogger.info("设备列表 =========>\(String(describing: devices))")
                if let device = devices?.first {
                    self.connectDevice(device: device)
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
            switch res {
            case .success(let deviceInfo):
                BDLogger.info("已连接设备 =========\(String(describing: deviceInfo.peripheralName))")
            case .failure(let error):
                BDLogger.info("连接失败 ========> \(error)")
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
            manager.readBattery { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 1: // 读取充电状态
            manager.readChargeStatus { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 2: // 读取戒指中的数据
            manager.readDatas { progress, dataModel in
                BDLogger.info(" 进度 =====>\(progress)==\(dataModel)")
            } resultBlock: { res in
                switch res {
                case .success(let success):
                    BDLogger.info("成功=====>\(success)")
                case .failure(let failure):
                    BDLogger.info("失败=====>\(failure)")
                }
            }
        case 3:
            break
        case 4: // 读取心率
            manager.readHeartRate(progressBlock: { progress in
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
            guard let path = Bundle.main.path(forResource: "2.3.7.511S.hex16", ofType: nil) else { return }
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
