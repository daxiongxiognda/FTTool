//
//  Global.swift
//  FTTool
//
//  Created by 熊坤鹏 on 2026/8/31.
//

// MARK: - 命名空间，普通类型
/**
 @unchecked Sendable：告诉编译器“这个类型是线程安全的，请相信我”。
 */
public struct FTWrapper<Base>: @unchecked Sendable {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}
/**
 AnyObject：限制了只有类（class）才能遵循该协议，结构体和枚举无法遵循。这正好对应了“引用类型”的场景。
 */
public protocol FTCompatible: AnyObject {}
/**
 没有继承 AnyObject：因此结构体和枚举可以遵循，对应“值类型”的场景。
 */
public protocol FTCompatibleValue {}
/**
 去掉 set，代码会更清晰，也避免让使用者误以为可以赋值。
 */
extension FTCompatible {
    public var ft: FTWrapper<Self> {
        get { return FTWrapper(self) }
//        set { }
    }
}
extension FTCompatibleValue {
    public var ft:FTWrapper<Self> {
        get { return FTWrapper(self) }
//        set { }
    }
}


extension Int: FTCompatibleValue {}
extension Int64: FTCompatibleValue {}
extension Double: FTCompatibleValue {}
extension NSObject: FTCompatible {}


// MARK: -闭包
/// View的闭包
public typealias FTViewClosure = ((UITapGestureRecognizer?, UIView, NSInteger) -> Void)
/// 手势的闭包
public typealias FTRecognizerClosure = ((UIGestureRecognizer) -> Void)
/// UIControl闭包
public typealias FTControlClosure = ((UIControl) -> Void)

public typealias VoidClosure         = () -> Void
public typealias IntClosure          = (_ value: Int) -> Void
public typealias FloatClosure        = (_ value: CGFloat) -> Void
public typealias DoubleClosure       = (_ value: Double) -> Void
public typealias UrlClosure          = (_ value: URL?) -> Void
public typealias BoolClosure         = (_ finished: Bool) -> Void
public typealias StringClosure       = (_ str: String) -> Void
public typealias ArrayClosure        = (_ array: Array<Any>?) -> Void
public typealias DictionaryClosure   = (_ dict: [String:Any]?) -> Void
public typealias DataClosure         = (_ data: Data?) -> Void
public typealias ImageClosure        = (_ image: UIImage?) -> Void
public typealias AnyClosure          = (_ value: Any?) -> Void
