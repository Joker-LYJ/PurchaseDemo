//
//  ViewController.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import UIKit

class HomePageViewController: BaseViewController {
    
    lazy var networkRequestButton: UIButton = {
        let button = UIButton()
        button.setTitle("网络请求", for: .normal)
        button.backgroundColor = UIColor.purple
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(networkRequestButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var getInfomationButton: UIButton = {
        let button = UIButton()
        button.setTitle("获取信息", for: .normal)
        button.backgroundColor = UIColor.purple
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(getInfomationButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var purchaseButton: UIButton = {
        let button = UIButton()
        button.setTitle("购买", for: .normal)
        button.backgroundColor = UIColor.purple
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(purchaseButtonClick), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupConstraints()
        netWorkCheck()
    }
}
 
//MARK: - Aciton
extension HomePageViewController {
    func netWorkCheck() {
        NetworkMannager.shared.requestNetworkPermission { [weak self] success in
            guard let self = self else {return}
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                if success {
                    self.informationLabel.text = "网络连接成功"
                } else {
                    self.informationLabel.text = "网络异常"
                }
            }
            
        }
    }
    
    @objc func purchaseButtonClick() {
        
        var type: PurchaseType = .no
       
        if UserRecorder.getPurchased(productID: K.vipYearID)  {
            type  = .year
        } else if UserRecorder.getPurchased(productID: K.vipWeekID) {
            type = .week
        } else {
            type = .no
        }
  
        let vc = PurchaseViewController(pageType: type)
        let navController = BaseNavigationController(rootViewController: vc)
        navController.modalTransitionStyle = .crossDissolve
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true)
    }
    
    @objc func networkRequestButtonClick() {
        AppClient.shared.startUp(.hot)
    }
    
    @objc func getInfomationButtonClick() {
        
    }
}

//MARK: - UI
extension HomePageViewController {
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubviews(informationLabel,purchaseButton,networkRequestButton)
    }
    
    func setupConstraints() {
        informationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        purchaseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
            make.top.equalTo(informationLabel.snp.bottom).offset(40)
        }
        
        networkRequestButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
            make.top.equalTo(purchaseButton.snp.bottom).offset(40)
        }
    }
}

