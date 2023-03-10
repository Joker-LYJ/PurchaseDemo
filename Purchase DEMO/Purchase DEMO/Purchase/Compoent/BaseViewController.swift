//
//  BaseViewController.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/9.
//

import Foundation

class BaseViewController: UIViewController {
    ///返回按钮
    lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "NavBackIcon"),style: .plain, target: self, action: #selector(backButtonDidTapped))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///侧滑返回代理
        navigationController?.interactivePopGestureRecognizer?.delegate = self
//        navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ///启用侧滑返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
  
}

extension BaseViewController {
    @objc func backButtonDidTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setNavigationBarStyle(tittle: String, isShowSettingButton: Bool){
        let tittleLabel = UILabel()
        tittleLabel.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        tittleLabel.text = tittle
        
        navigationItem.leftBarButtonItem = .init(customView: tittleLabel)
        
        if isShowSettingButton {
         
            
          
        }
    }
    
   
}

extension BaseViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //判断当前的导航栏个数是否唯一
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}
