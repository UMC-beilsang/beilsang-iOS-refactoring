//
//  Header.swift
//  UIComponentsShared
//
//  Created by Park Seyoung on 7/5/25.
//

import UIKit
import SnapKit
import DesignSystemShared

public enum HeaderType {
    case primary
    case secondary(title: String)
}

final class Header: UIView {
    private let type: HeaderType

    private let container = UIView()
    private let label = UILabel()
    private let logoView = UIView()
    private let typoLogoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "typoLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let notificationIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "notificationIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "searchIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    

    public init(type: HeaderType) {
        self.type = type
        super.init(frame: .zero)
        setup()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        self.type = .primary
        super.init(coder: coder)
        setup()
        applyStyle()
    }

    private func setup() {
        addSubview(container)
        addSubview(notificationIconView)
        addSubview(searchIconView)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(60)
        }

        switch type {
        case .primary:
            container.addSubview(logoView)
            container.addSubview(typoLogoView)
            
            logoView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(24)
                make.height.width.equalTo(32)
                make.centerY.equalToSuperview()
            }
            
            typoLogoView.snp.makeConstraints { make in
                make.leading.equalTo(logoView.snp.trailing).offset(6)
                make.height.equalTo(20)
                make.centerY.equalToSuperview()
            }

        case .secondary(let title):
            container.addSubview(label)
            label.text = title
            
            label.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(24)
                make.centerY.equalToSuperview()
            }
        }
        
        searchIconView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.height.width.equalTo(28)
        }
        
        notificationIconView.snp.makeConstraints { make in
            make.trailing.equalTo(searchIconView).offset(-16)
            make.height.width.equalTo(28)
        }
        
    }

    private func applyStyle() {
        switch type {
        case .primary:
            container.backgroundColor = ColorSystem.backgroundNormalNormal
            label.applyStyle(.title1)
            label.textColor = ColorSystem.labelNormalStrong
        case .secondary:
            container.backgroundColor = ColorSystem.backgroundNormalNormal
        }
    }
}
