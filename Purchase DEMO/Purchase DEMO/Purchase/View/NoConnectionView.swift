//
//  NoConnectionView.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation

class NoConnectionView: UIView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.text = "网络连接失败"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        self.backgroundColor = UIColor(hex: 0x000000,alpha: 0.7)
        addSubviews(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self, let window = UIApplication.shared.keyWindow else { return }
            self.alpha = 1.0
            window.addSubview(self)
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 0.0
        } completion: { [weak self] success in
            self?.removeFromSuperview()
        }
    }
}
