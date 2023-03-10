//
//  PurchaseViewController.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation


class PurchaseViewController:UIViewController {
    
    private var purchasePageType: PurchaseType = .no
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ClosePurchaseButton"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(hex: 0xFF893E).cgColor
        button.layer.cornerRadius = 22
        return button
    }()
    
    lazy var yearPriceButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.setTitle("价格获取中", for: .normal)
        button.layer.borderColor = UIColor(hex: 0xFF893E).cgColor
        button.addTarget(self, action: #selector(purchaseButtonClik(sender:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var weekPriceButton:  UIButton = {
        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(hex: 0xFF893E).cgColor
        button.setTitle("价格获取中", for: .normal)
        button.addTarget(self, action: #selector(purchaseButtonClik(sender:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    init(pageType: PurchaseType ){ //使用指定方式来初始化视图控制器。
        super.init(nibName: nil, bundle: nil)
        self.purchasePageType = pageType
        
    }
    
    convenience init() { //便利初始化方法，使用默认方式来初始化视图控制器。
        self.init(pageType: .no)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Purchase.shared.getPrices{
                self.yearPriceButton.setTitle(Recoder.PurchaseInfomation?.yearPrice, for: .normal)
                self.yearPriceButton.isEnabled = true
                self.weekPriceButton.setTitle(Recoder.PurchaseInfomation?.weekPrice, for: .normal)
                self.weekPriceButton.isEnabled = true
            }
            
            self.updateUI()
        }
    }
}

//MARK: - Action
extension PurchaseViewController {
    @objc func closeButtonClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func purchaseButtonClik(sender: UIButton){
        
        if sender == self.yearPriceButton {
            Purchase.shared.purchaseProduct(K.vipYearID) { [weak self ]success, info in
                guard let self = self else {return}
                if success {
                    self.updateUI()
                }
            }
        } else {
            Purchase.shared.purchaseProduct(K.vipWeekID) { [weak self ]success, info in
                guard let self = self else {return}
                if success {
                    self.updateUI()
                }
            }
        }
    }
}

//MARK: - UI
extension PurchaseViewController {
    func setupUI() {
        
        self.view.addSubviews(closeButton,yearPriceButton,weekPriceButton)
        
        
    }
    
    func setupConstraints() {
        yearPriceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(100)
            make.centerY.equalToSuperview().offset(-80)
        }
        
        weekPriceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(100)
            make.top.equalTo(yearPriceButton.snp.bottom).offset(40)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.size.equalTo(44)
            make.centerX.equalToSuperview()
            make.top.equalTo(weekPriceButton.snp.bottom).offset(60)
        }
    }
    
    
    func updateUI() {
        if Recoder.PurchaseInfomation?.purchasedStatus == "year" {
            self.purchasePageType  = .year
        } else if Recoder.PurchaseInfomation?.purchasedStatus == "week" {
            self.purchasePageType = .week
        } else {
            self.purchasePageType = .no
        }
    
        DispatchQueue.main.async {
            switch self.purchasePageType {
            case .no:
                self.title = "普通内购页面"
                self.view.backgroundColor = .yellow
                self.weekPriceButton.isEnabled = true
                self.yearPriceButton.isEnabled = true
            case .week:
                self.title = "内购升级页面"
                self.view.backgroundColor = UIColor(hex: 0x75B8FF)
                self.weekPriceButton.setTitle("已购买", for: .disabled)
                self.weekPriceButton.isEnabled = false
                self.yearPriceButton.isEnabled = true
            case .year:
                self.title = "最终页面"
                self.weekPriceButton.isEnabled = false
                self.yearPriceButton.isEnabled = false
                self.weekPriceButton.setTitle("已购买", for: .disabled)
                self.yearPriceButton.setTitle("已购买", for: .disabled)
                self.view.backgroundColor = UIColor(hex: 0x000000)
            }
            
            self.view.layoutIfNeeded()
        }
        
    }
}
