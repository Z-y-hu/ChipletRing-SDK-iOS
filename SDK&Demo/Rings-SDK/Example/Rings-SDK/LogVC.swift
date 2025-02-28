//
//  LogVC.swift
//  Rings-SDK_Example
//
//  Created by JianDan on 2025/2/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import RingsSDK
import UIKit
class LogVC: UIViewController {
    @IBOutlet var log_TV: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 清除当天已有日志
        readLogContent()
    }

    public func readLogContent() {
        clearTodayLogFile()
        BDLogger.info("-------------日志-----------------")
        readLog()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //  读取日志内容
    func readLog() {
        // 每秒读取一次日志
        _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let logTextView = self?.log_TV else {
                print("⚠️ log_TV 未正确初始化")
                return
            }

            if let logContent = self?.readLogContent() {
                if logTextView.text == logContent {
                    return
                }
                logTextView.text = logContent
                DispatchQueue.main.async {
                    logTextView.scrollRangeToVisible(NSMakeRange(logTextView.text.count - 1, 1))
                }
            } else {
                print("⚠️ 未能读取到日志内容")
            }
        }
    }
}

// MARK: - 日志文件操作

public let defaultLogDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
extension LogVC {
    /// 读取日志文件内容（默认读取当天日志，可指定其他日期或文件名）
    public func readLogContent(at directoryPath: String = defaultLogDirectoryPath, fileName: String? = nil) -> String? {
        // 如果未指定文件名，则默认使用当天日期生成的 .log 文件
        let finalFileName: String
        if let fileName = fileName, !fileName.isEmpty {
            finalFileName = fileName
        } else {
            // 需要先 import SwiftDate，使用 .toFormat("yyyy-MM-dd") 时
            // 确保全局已配置好 SwiftDate 的默认region，如果没有可改成常规方法
            let dateString = Date().toFormat("yyyy-MM-dd")
            finalFileName = "\(dateString).log"
        }

        let pathURL = URL(fileURLWithPath: directoryPath)
        let logFileURL = pathURL.appendingPathComponent(finalFileName)

        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: logFileURL.path) else {
            print("⚠️ 日志文件不存在: \(logFileURL.path)")
            return ""
        }

        do {
            // 读取文件内容
            let content = try String(contentsOf: logFileURL, encoding: .utf8)
            return content
        } catch {
            print("⚠️ 读取日志文件出错: \(error)")
            return ""
        }
    }

    /// 删除今日的日志文件
    /// - Parameter directoryPath: 日志存放目录（默认 `Documents`）
    /// - Returns: 是否删除成功
    @discardableResult
    public func clearTodayLogFile(directoryPath: String = defaultLogDirectoryPath) -> Bool {
        // 生成今天的日志文件名，例如 "2025-01-10.log"
        let dateString = Date().toFormat("yyyy-MM-dd")
        let fileName = "\(dateString).log"

        let pathURL = URL(fileURLWithPath: directoryPath)
        let logFileURL = pathURL.appendingPathComponent(fileName)

        // 如果文件不存在，直接返回 false 或视需求返回 true
        guard FileManager.default.fileExists(atPath: logFileURL.path) else {
            print("⚠️ 当日日志不存在：\(logFileURL.path)")
            return false
        }

        // 删除文件
        do {
            try FileManager.default.removeItem(at: logFileURL)
            return true
        } catch {
            print("⚠️ 删除日志文件出错：\(error)")
            return false
        }
    }
}
