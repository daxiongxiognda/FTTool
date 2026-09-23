//
//  UIViewExt.swift
//  FTTool
//
//  Created by 熊坤鹏 on 2026/8/30.
//

import Foundation

// MARK: - UIView 防抖功能的点击
//  为 UIView 添加带防抖功能的点击事件
//  核心思想：通过关联对象存储闭包和手势，实现“设置闭包即添加手势”的自动化管理
extension UIView {
    
    // MARK: - 关联对象 Key 定义
    // 使用 UInt8 静态变量作为 Key，利用其唯一的内存地址作为标识符
    // 为什么不使用 Character？因为 Character 的内存地址不如 UInt8 稳定可靠
    private enum AssociatedKeys {
        static var tapGesture: UInt8 = 0       // 存储手势对象
        static var clickClosure: UInt8 = 0     // 存储点击闭包
        static var debounceInterval: UInt8 = 0 // 存储防抖间隔
        static var lastTapTimestamp: UInt8 = 0 // 存储最后点击时间戳
        static let externalBorderName = "externalBorder" // 外部边框名称（保留，与点击无关）
    }
    
    // MARK: - Convenience Method
    /// 便捷方法：设置点击事件和防抖间隔
    public func ttTaped(interval: TimeInterval = 0.5, closure: VoidClosure?) {
        ttDebounceInterval = interval
        ttclickClosure = closure
    }
    
    /// 点击回调闭包
    /// - 设置闭包时自动添加手势（如果尚未添加）
    /// - 设为 nil 时自动移除手势
    public var ttclickClosure: VoidClosure? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.clickClosure) as? VoidClosure
        }
        set {
            // 移除旧手势（如果存在）
            removeTapGestureIfNeeded()
            
            // 设置新闭包
            objc_setAssociatedObject(self, &AssociatedKeys.clickClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            // 如果新闭包不为空，添加手势
            if newValue != nil {
                addTapGestureIfNeeded()
            }
        }
    }
    
    /// 防抖时间间隔（默认 0.5 秒）
    public var ttDebounceInterval: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.debounceInterval) as? TimeInterval ?? 0.5
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.debounceInterval, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 最后点击时间戳（用于防抖计算）
    private var lastTapTimestamp: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastTapTimestamp) as? TimeInterval ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastTapTimestamp, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Private Methods
    
    /// 添加点击手势（如果尚未添加）
    private func addTapGestureIfNeeded() {
        // 避免重复添加
        if objc_getAssociatedObject(self, &AssociatedKeys.tapGesture) != nil {
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedKeys.tapGesture, tap, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /// 移除点击手势（如果存在）
    private func removeTapGestureIfNeeded() {
        guard let tap = objc_getAssociatedObject(self, &AssociatedKeys.tapGesture) as? UITapGestureRecognizer else {
            return
        }
        removeGestureRecognizer(tap)
        objc_setAssociatedObject(self, &AssociatedKeys.tapGesture, nil, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    /// 点击事件处理（防抖逻辑）
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let currentTime = Date().timeIntervalSince1970
        let interval = currentTime - lastTapTimestamp
        
        // 检查防抖间隔：如果两次点击间隔太短，忽略本次点击
        guard interval >= ttDebounceInterval else { return }
        // 更新最后点击时间戳
        lastTapTimestamp = currentTime
        // 执行闭包
        ttclickClosure?()
    }
}



// MARK: -动画
public extension UIView {
    /// 开始旋转
    /// - Parameter animationKey: 动画 animationKey
    func startRotating(animationKey: String) {
        layer.startRotating(animationKey: animationKey)
    }
    
    /// 结束动画
    /// - Parameter animationKey: 使用刚才开始的 animationKey
    func stopRotating(animationKey: String) {
        layer.stopRotating(animationKey: animationKey)
    }
}
// MARK: -frame
public extension FTWrapper where Base: UIView {
    /// 尺寸
    /**
     当你写 base.frame.size = newValue 时，Swift 会：
     
     读取 base.frame 的当前值（一个 CGRect 结构体）
     创建一个新的 CGRect，将其 size 替换为 newValue
     将新的 CGRect 赋值回 base.frame
     这是一个整体替换操作，由编译器自动完成。
     size 是 frame 的直接属性，可以直接赋值
     size 可以直接赋值，是因为 Swift 允许直接修改结构体的属性，编译器将其视为一个整体操作。
     */
    var size: CGSize {
        get { return base.frame.size }
        set { base.frame.size = newValue }
    }
    /// origin 点
    var origin: CGPoint {
        get { return base.frame.origin }
        set { base.frame.origin = newValue }
    }
    
    /// 宽度
    /**
     width 是 size 的子属性（嵌套属性），不能直接赋值
     width 必须分步赋值，是因为 Swift 不允许直接修改结构体的嵌套属性，必须通过“读取-修改-写入”的模式来完成。
     */
    var width: CGFloat {
        get { return base.frame.size.width }
        set {
            var frame = base.frame  // 1. 读取整个 frame
            frame.size.width = newValue // 2. 修改 size.width
            base.frame = frame      // 3. 整体赋值回去
        }
    }
    
    /// 高度
    var height: CGFloat {
        get { return base.frame.size.height }
        set {
            var frame = base.frame
            frame.size.height = newValue
            base.frame = frame
        }
    }
    
    /// 横坐标
    var x: CGFloat {
        get { return base.frame.minX }
        set {
            var frame = base.frame
            frame.origin.x = newValue
            base.frame = frame
        }
    }
    
    /// 纵坐标
    var y: CGFloat {
        get { return base.frame.minY }
        set {
            var frame = base.frame
            frame.origin.y = newValue
            base.frame = frame
        }
    }
    
    
    
    /// 右端横坐标
    var right: CGFloat {
        get { return base.frame.origin.x + base.frame.size.width }
        set {
            var frame = base.frame
            frame.origin.x = newValue - frame.size.width
            base.frame = frame
        }
    }
    
    /// 底端纵坐标
    var bottom: CGFloat {
        get { return base.frame.origin.y + base.frame.size.height }
        set {
            var frame = base.frame
            frame.origin.y = newValue - frame.size.height
            base.frame = frame
        }
    }
    
    /// 中心横坐标
    var centerX: CGFloat {
        get { return base.center.x }
        set {
            var center = base.center  // 读取整个 center
            center.x = newValue       // 修改 x
            base.center = center      // 整体赋值回去
        }
    }
    
    /// 中心纵坐标
    var centerY: CGFloat {
        get { return base.center.y }
        set {
            var center = base.center  // 读取整个 center
            center.y = newValue       // 修改 y
            base.center = center      // 整体赋值回去
        }
    }
    
    /// 右上角坐标
    var topRight: CGPoint {
        get { return CGPoint(x: base.frame.origin.x + base.frame.size.width, y: base.frame.origin.y) }
        set { base.frame.origin = CGPoint(x: newValue.x - width, y: newValue.y) }
    }
    
    /// 右下角坐标
    var bottomRight: CGPoint {
        get { return CGPoint(x: base.frame.origin.x + base.frame.size.width, y: base.frame.origin.y + base.frame.size.height) }
        set { base.frame.origin = CGPoint(x: newValue.x - width, y: newValue.y - height) }
    }
    
    /// 左下角坐标
    var bottomLeft: CGPoint {
        get { return CGPoint(x: base.frame.origin.x, y: base.frame.origin.y + base.frame.size.height) }
        set { base.frame.origin = CGPoint(x: newValue.x, y: newValue.y - height) }
    }
    
    /**
     对视图进行截图，并返回一个指定尺寸的 UIImage 图像。
     它是一个非常实用的 UIView 扩展方法，常用于生成视图快照、分享图片或保存到相册等场景
     */
    func screenshot(size: CGSize?=nil) -> UIImage?{
        let imageSize = size ?? base.layer.frame.size
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        base.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public extension UIView{
    /**
     通过一个方法同时设置视图在指定轴（水平或垂直）上的两个核心布局优先级。
     在 StackView 或复杂布局中，这个方法尤其有用，可以帮助你快速调整视图的伸缩行为，而无需单独调用两个方法。
     */
    func setPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        //内容拥抱优先级：视图“抱住”自己内容的倾向。优先级越高，视图越不愿意被拉伸，会紧贴其内容大小。
        self.setContentHuggingPriority(priority, for: axis)
        //内容压缩阻力优先级：视图抵抗被压缩的倾向。优先级越高，视图越不愿意被压缩，会保持其内容的完整性。
        self.setContentCompressionResistancePriority(priority, for: axis)
    }
}
