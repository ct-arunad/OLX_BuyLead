//
//  CarsCollection.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 03/04/25.
//

import Foundation
import UIKit

class CarsCollection : UICollectionViewCell {
    
    static let identifier = "CustomCollectionViewCell"

    let titleLabel = UILabel()
    let chatBtn = UIButton()
    let deleteBtn = UIButton()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
      
        // Checkbox
       
        chatBtn.translatesAutoresizingMaskIntoConstraints = false
      
        let image = UIImage.named( "olxchat")
        chatBtn.setImage(image, for: .normal)
        deleteBtn.setImage(UIImage.named( "delete"), for: .normal)
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .appFont(.regular, size: 14)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left
        // Label
               
               // Create StackView
        let stackView = UIStackView(arrangedSubviews: [titleLabel, chatBtn, deleteBtn])
        stackView.axis = .horizontal // Horizontal layout
        stackView.spacing = 5        // Space between items
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
               
               // Add StackView to the View
        contentView.addSubview(stackView)
               
        NSLayoutConstraint.activate([
            chatBtn.widthAnchor.constraint(equalToConstant: 30),
            chatBtn.heightAnchor.constraint(equalToConstant: 30),
            deleteBtn.widthAnchor.constraint(equalToConstant: 30),
            deleteBtn.heightAnchor.constraint(equalToConstant: 30),
            ])
               // Constraints
               NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                 //  stackView.widthAnchor.constraint(equalToConstant: 300),
                   stackView.heightAnchor.constraint(equalToConstant: 30)
               ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}
