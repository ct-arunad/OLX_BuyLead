//
//  OnlineBuyLeads_collectioncell.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 01/04/25.
//
import Foundation
import UIKit

class OnlineBuyLeads_collectioncell: UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"
    
    public let checkBox: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.named("uncheck"), for: .normal)
        return button
    }()
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Label"
        label.textAlignment = .left
        label.font = .appFont(.medium, size: 13)
        label.textColor = .black
        return label
    }()
    
    public let bottomArrow: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.named("downarrow"), for: .normal)
        return button
    }()
    
    public let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupStackView() {
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.layer.masksToBounds = true

        stackView.addArrangedSubview(checkBox)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(bottomArrow)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            checkBox.widthAnchor.constraint(equalToConstant: 15),
            checkBox.heightAnchor.constraint(equalToConstant: 15),
            bottomArrow.widthAnchor.constraint(equalToConstant: 15),
            bottomArrow.heightAnchor.constraint(equalToConstant: 15),
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
