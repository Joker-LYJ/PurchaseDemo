//
//  Util.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation
import Photos
import UIKit
import AVKit

// MARK: - Localizations
public func __(_ text: String) -> String {
    return NSLocalizedString(text, tableName: "Localizations", bundle: Bundle.main, value: "", comment: "")
}

extension Data {
    public func subdata(in range: CountableClosedRange<Data.Index>) -> Data {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
}

public class Util {
    
    public class var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public static func countryCode() -> String {
        return NSLocale.current.regionCode ?? ""
    }
    
    /// 返回最顶层的 view controller
    @available(iOSApplicationExtension, unavailable)
    public static func topViewControllerOptional() -> UIViewController? {
        var keyWinwow = UIApplication.shared.keyWindow
        if keyWinwow == nil {
            keyWinwow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        }
        if #available(iOS 13.0, *), keyWinwow == nil {
            keyWinwow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        }
        
        var top = keyWinwow?.rootViewController
        if top == nil {
            top = UIApplication.shared.delegate?.window??.rootViewController
        }
        
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        
        return top
    }
    @available(iOSApplicationExtension, unavailable)
    public static func topViewController() -> UIViewController {
        return topViewControllerOptional()!
    }

    /// 返回本地化的app名称
    public static func appName() -> String {
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else {
            return Bundle.main.infoDictionary?["CFBundleName"] as! String
        }
    }
    
    /// 返回版本号
    public static func appVersion() -> String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    class func getPreviewFromVideo(path: String) -> UIImage? {
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            debugPrint("Get preview fail: \(error)")
            return nil
        }
    }
    
    class func formattedTime(for time: Double) -> String {
        if time.isNaN { return "00:00" }
        
        var min = Int(time / 60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        
        if min >= 60 {
            let hour = Int(min / 60)
            min = min - hour * 60
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        }
        
        return String(format: "%02d:%02d", min, sec)
    }
    
}

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff, a: alpha)
    }
    
    static var random: UIColor {
      return UIColor(red: CGFloat.random(in: 0...1),
                     green: CGFloat.random(in: 0...1),
                     blue: CGFloat.random(in: 0...1),
                     alpha: 1.0)
    }
}

@available(iOSApplicationExtension, unavailable)
extension Util {
    class func accessPhotos(withHandler: @escaping () -> Void) {
        var isAuthorized: Bool? {
            didSet {
                DispatchQueue.main.async {
                    if (isAuthorized != nil) && isAuthorized! {
                        withHandler()
                    } else {
                        showPhotosAuthorizationAlert()
                    }
                }
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    isAuthorized = true
                }
            }
        case .authorized:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    class func showPhotosAuthorizationAlert() {
        let alertController = UIAlertController(
            title: __("无法访问照片"),
            message: String(format: __("您需要设置允许%@访问“照片”权限才可以使用"), Util.appName()) ,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: __("取消"), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: __("去设置"), style: .default) { (action) in
            openURL(UIApplication.openSettingsURLString)
        })
        Util.topViewController().present(alertController, animated: true, completion: nil)
    }
    
    class func openURL(_ withString: String, failure: (@escaping () -> Void) = {}) {
        if let url = URL(string: withString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                failure()
            }
        }
    }
    
    enum SaveToPhotoAlbumResult {
        case success, error, denied
    }
    class func saveWallpapertoAlbum(resultImage: UIImage, completion: ((_ result: SaveToPhotoAlbumResult) -> ())?) {
//        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: resultImage)
        }) { (success, error) in
            if success {
                completion?(.success)
            } else {
                completion?(.error)
            }
        }
    }
}


extension Util {
    static let isIPad: Bool = {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
    }()
    
    @available(iOSApplicationExtension, unavailable)
    static var isLandscape: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    @available(iOSApplicationExtension, unavailable)
    static let deviceWidth = isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
    
    @available(iOSApplicationExtension, unavailable)
    static let deviceHeight = isLandscape ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
    
    @available(iOSApplicationExtension, unavailable)
    public static var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, tvOS 11.0, *) {
            if let safeAreaInsets = UIApplication.shared.delegate?.window??.safeAreaInsets {
                return safeAreaInsets
            } else if let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
                return safeAreaInsets
            }
        }
    
        return UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    
    /// 是否有底部Home区域
    @available(iOSApplicationExtension, unavailable)
    public static var hasBottomSafeAreaInsets: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with home indicator: 34.0 on iPhone X, XS, XS Max, XR.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 > 0
        }
        
        return false
    }
    @available(iOSApplicationExtension, unavailable)
    static var tabBarHeight: CGFloat {
        if isIPad {
            if hasBottomSafeAreaInsets {
                return 65
            } else {
                if #available(iOS 12.0, *) {
                    return 50
                } else {
                    return 49
                }
            }
        } else {
            let height: CGFloat = 49
            return height + safeAreaInsets.bottom
        }
    }
}

extension CALayer {
    func setShadow(color: UIColor? = .black,
                       alpha: CGFloat = 50,
                       x: CGFloat = 0, y: CGFloat = 2,
                       blur: CGFloat = 4,
                       spread: CGFloat = 0) {
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur * 0.5 // 模糊/2
        shadowColor = color?.cgColor
        shadowOpacity = Float(alpha/100) // shadowColorAlpha/100

        let rect = bounds.insetBy(dx: -spread, dy: -spread) // spread 扩展
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        shadowPath = path.cgPath
        masksToBounds = false
    }
}


extension UIImage {
    
    /// APP icon
    static var icon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}


public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for aView in subviews {
            self.addSubview(aView)
        }
    }
    
    // handler: (subview) -> stopped
    func enumerateAllSubviews(_ handler: (UIView) -> Bool) {
        self.enumerateSubviews(handler)
    }
    
    @discardableResult
    func insertSeparator(height: CGFloat = 0.5, color: UIColor? = nil, maker: ((ConstraintMaker) -> Void)) -> UIView {
        let separator = UIView()
        separator.backgroundColor = color ?? UIColor.lightGray
        self.addSubview(separator)
        
        separator.snp.makeConstraints { (make) in
            make.height.equalTo(height)
            maker(make)
        }
        
        return separator
    }
    
    func enumerateSubviews(_ handler: (UIView) -> Bool) {
        for subview in self.subviews {
            let stopped = handler(subview)
            if stopped == false {
                subview.enumerateAllSubviews(handler)
            }
        }
    }
}
public extension UIView {
    
    var safeAreaTop: ConstraintItem {
        get {
            return safeAreaLayoutGuide.snp.top
        }
    }
    
    var safeAreaBottom: ConstraintItem {
        get {
            return safeAreaLayoutGuide.snp.bottom
        }
    }
    
    var safeTop: CGFloat {
        get {
            return safeAreaLayoutGuide.layoutFrame.minY
        }
    }
    
    var safeBottom: CGFloat {
        get {
            return frame.size.height - safeTop - safeAreaLayoutGuide.layoutFrame.height
        }
    }
    
    var safeAreaHeight: CGFloat {
        get {
            return frame.size.height - safeTop - safeBottom
        }
    }
    
    var size: CGSize {
        set {
            self.frame.size = newValue
        }
        get {
            return self.frame.size
        }
    }
}

public extension UIView {
    
    // 将当前视图转为UIImage
    func asImage(size: CGSize) -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: .init(origin: .zero, size: size))
            return renderer.image { (context) in
                layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }
    }
    
}

