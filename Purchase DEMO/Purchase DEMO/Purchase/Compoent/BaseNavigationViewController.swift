//
//  BaseNavigationViewController.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/9.
//

class BaseNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let style = self.topViewController?.preferredStatusBarStyle {
            return style
        } else {
            return .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
//        navigationBar.barTintColor = .clear
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor(hex: 0x000000), .font:UIFont.systemFont(ofSize: 16, weight: .semibold)]
        // 隐藏黑线
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        
    }
    

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
        super.pushViewController(viewController, animated: animated)
    }
    
    
}
