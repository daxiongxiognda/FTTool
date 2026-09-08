//
//  CALayer+Rotation.swift
//  FTTool
//
//  Created by qqq on 2026/8/31.
//

import Foundation

public extension CALayer {
    /**
     这段代码实现的是一个无限循环的 360° 旋转动画，常用于加载指示器（如菊花转圈）或按钮的等待状态。具体效果是：元素围绕自己的中心点，沿着 Z 轴持续旋转，像一个永不停止的“风车”。
     */
    /// - Parameter animationKey: 动画 animationKey
    func startRotating(animationKey: String) {
        stopRotating(animationKey: animationKey)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.autoreverses = false //不反向，始终朝同一方向转
        animation.fillMode = .forwards
        animation.repeatCount = Float.greatestFiniteMagnitude //无限循环，永不停止
        animation.isRemovedOnCompletion = false //动画完成后不自动移除，保持旋转状态
        add(animation, forKey: animationKey)
    }
    
    /// 结束动画
    /// - Parameter animationKey: 使用刚才开始的 animationKey
    func stopRotating(animationKey: String) {
        guard let key = animationKeys()?.first(where: { $0 == animationKey }), !key.isEmpty else { return }
        removeAnimation(forKey: animationKey)
    }
}
