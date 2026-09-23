//
//  UIColor+HEX.swift
//  FTTool
//
//  Created by 熊坤鹏 on 2026/9/8.
//

import Foundation

public extension UIColor {
    
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hexValue: 0x开头
    convenience init(_ hexValue: UInt) {
        self.init(hexValue, alphaValue: 1)
    }
    
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hexValue: 0x开头
    ///   - alphaValue: 透明度 0.x
    convenience init(_ hexValue: UInt, alphaValue: Float) {
        let red = CGFloat((hexValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((hexValue & 0x00FF00) >> 8) / 255
        let blue = CGFloat(hexValue & 0x0000FF) / 255
        self.init(red: red, green: green, blue: blue, alpha: CGFloat(alphaValue))
    }
    
    /// 获取颜色
    /// - Parameters:
    ///   - hexValue: 0x开头
    /// - Returns: 返回颜色
    static func hex(_ hexValue: UInt) -> UIColor {
        return hex(hexValue, alphaValue: 1)
    }
    
    /// 获取颜色
    /// - Parameters:
    ///   - hexValue: 0x开头
    ///   - alphaValue: 透明度 0.x
    /// - Returns: 返回颜色
    static func hex(_ hexValue: UInt, alphaValue: Float) -> UIColor {
        return UIColor(hexValue, alphaValue: alphaValue)
    }

    /// 随机色
    static var random: UIColor {
        let red = CGFloat.random(in: 0.0...1.0)
        let green = CGFloat.random(in: 0.0...1.0)
        let blue = CGFloat.random(in: 0.0...1.0)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // 从UIColor获取RGB分量
    // swiftlint:disable:next large_tuple
    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue)
        }
        return nil
    }
    
}
