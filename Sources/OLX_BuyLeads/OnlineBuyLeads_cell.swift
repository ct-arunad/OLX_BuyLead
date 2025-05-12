//
//  OnlineBuyLeads_cell.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 01/04/25.
//

import Foundation
import UIKit

protocol TableCellDelegate: AnyObject {
    func chatwithDealer(item: String,tag : Int)
    func deleteCar(item: [String:Any],tag : Int)
}

class OnlineBuyLeads_cell : UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    weak var delegate: TableCellDelegate?  // ✅ Delegate Reference

    var cars: [Any] = []
    let phoneLabel = UILabel()
    let nameLabel = UILabel()
    let statusLabel = UILabel()
    let dateLabel = UILabel()
    let visitedLabel = UILabel()
    let separatorView = UIView()
    public var chatBtn = UIButton()
    public var editBtn = UIButton()
    public var deleteBtn = UIButton()
    public var restoreBtn = UIButton()

    let status_category = UIButton(type: .system)

    var heightconstaint =  NSLayoutConstraint()
    var bottomViewconstaint =  NSLayoutConstraint()

    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Scroll horizontally
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let bottomView: UIView = {
          let view = UIView()
          view.backgroundColor = UIColor.systemGray6
          view.translatesAutoresizingMaskIntoConstraints = false
          return view
      }()
    
    private let cellseparatorView: UIView = {
          let view = UIView()
          view.backgroundColor = UIColor.clear
          view.translatesAutoresizingMaskIntoConstraints = false
          return view
      }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
            selectionStyle = .none
            contentView.backgroundColor = .clear
    //OLXBlueColor
            // Name Label
            nameLabel.font = .appFont(.medium, size: 15)
            nameLabel.textColor =  UIColor.black
            nameLabel.numberOfLines = 0
           // nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      
            status_category.setTitle("", for: .normal)
            status_category.translatesAutoresizingMaskIntoConstraints = false
            status_category.setTitleColor(.white, for: .normal)
            status_category.titleLabel?.font = .appFont(.bold, size: 12)
         //   contentView.addSubview(status_category)
            status_category.contentHorizontalAlignment = .center
          //  contentView.bringSubviewToFront(status_category)
            
            NSLayoutConstraint.activate([
                status_category.widthAnchor.constraint(equalToConstant: 75),
                status_category.heightAnchor.constraint(equalToConstant: 35)
                   ])
            let titleStackView = UIStackView(arrangedSubviews: [nameLabel,status_category])
            titleStackView.axis = .horizontal
            titleStackView.alignment = .center
            titleStackView.distribution = .fill
            titleStackView.spacing = 8
            titleStackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Name Label
            phoneLabel.font = .appFont(.regular, size: 16)
            phoneLabel.textColor =  .systemBlue
            phoneLabel.numberOfLines = 0
            phoneLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            
            
            // Status Label
            statusLabel.font = .appFont(.regular, size: 14)
            statusLabel.textColor =   UIColor.black
           // statusLabel.numberOfLines = 1
        statusLabel.numberOfLines = 0
        statusLabel.lineBreakMode = .byWordWrapping
        statusLabel.sizeToFit()
        statusLabel.setContentHuggingPriority(.defaultLow, for: .horizontal) // Allow label to grow
        statusLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            // Date Label
            dateLabel.font = .appFont(.regular, size: 14)
            dateLabel.numberOfLines = 0
            dateLabel.textColor =  UIColor.black

            // Visited Label
            visitedLabel.text = "VISITED"
            visitedLabel.font = .appFont(.medium, size: 14)
            visitedLabel.textColor = .systemGreen
            visitedLabel.textAlignment = .right
            visitedLabel.adjustsFontSizeToFitWidth = true
            visitedLabel.minimumScaleFactor = 0.8
        visitedLabel.sizeToFit()
        visitedLabel.setContentHuggingPriority(.defaultLow, for: .horizontal) // Allow label to grow
        visitedLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
         //   restoreBtn = createButton(title: "restore", color: UIColor.OLXBlueColor)
            restoreBtn.setImage(UIImage(named: "restore", in: .module, compatibleWith: nil), for: .normal)
            restoreBtn.setTitle("Restore", for: .normal)
            restoreBtn.setTitleColor(.appPrimary, for: .normal)
            restoreBtn.titleLabel?.font = .appFont(.regular, size: 8)
            restoreBtn.contentHorizontalAlignment = .center
            restoreBtn.contentVerticalAlignment = .center
            restoreBtn.setContentHuggingPriority(.defaultLow, for: .horizontal) // Allow label to grow
            restoreBtn.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            // Adjust spacing
            let spacing: CGFloat = 2

            restoreBtn.sizeToFit()

            let imageSize = restoreBtn.imageView?.frame.size ?? .zero
            let titleSize = restoreBtn.titleLabel?.intrinsicContentSize ?? .zero
            restoreBtn.titleEdgeInsets = UIEdgeInsets(
                top: spacing,
                left: -imageSize.width,
                bottom: -imageSize.height,
                right: 0
            )

            restoreBtn.imageEdgeInsets = UIEdgeInsets(
                top: -titleSize.height,
                left: 0,
                bottom: 0,
                right: -titleSize.width
            )
            let spacer = UIView()
//            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
//            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
             
        
            let visibleStackView = UIStackView(arrangedSubviews: [statusLabel,spacer,visitedLabel,restoreBtn])
            visibleStackView.axis = .horizontal
            visibleStackView.alignment = .center
            visibleStackView.distribution = .fill
            visibleStackView.spacing = 4
            visibleStackView.translatesAutoresizingMaskIntoConstraints = false
           visibleStackView.isLayoutMarginsRelativeArrangement = true
            visibleStackView.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
            // Separator
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = .lightGray
            NSLayoutConstraint.activate([
                separatorView.heightAnchor.constraint(equalToConstant: 1)
            ])
        
            //collectionView
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(CarsCollection.self, forCellWithReuseIdentifier: CarsCollection.identifier)
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            heightconstaint = collectionView.heightAnchor.constraint(equalToConstant: 50)
            heightconstaint.isActive = true
            
            collectionView.setContentHuggingPriority(.required, for: .vertical)
            collectionView.setContentCompressionResistancePriority(.required, for: .vertical)
            //bottom View
           // bottomView.backgroundColor =  UIColor(red: 216/255, green: 219/255, blue: 224/255, alpha: 1.0)
            bottomView.translatesAutoresizingMaskIntoConstraints = false
            bottomView.isUserInteractionEnabled = true
         

            NSLayoutConstraint.activate([
                cellseparatorView.heightAnchor.constraint(equalToConstant: 20),
                // Only one height constraint
                ])
          
            
               chatBtn = createButton(title: "sms", color: UIColor.OLXBlueColor)
               editBtn = createButton(title: "edit", color: UIColor.OLXBlueColor)
               deleteBtn = createButton(title: "download", color: UIColor.OLXBlueColor)
                 
                 // Create Labels
            let spacer1 = UIView()
            let spacer2 = UIView()
            let spacer3 = UIView()
            let spacer4 = UIView()
            spacer2.backgroundColor = .white
            spacer3.backgroundColor = .white
            // Set fixed width and full height
            NSLayoutConstraint.activate([
                spacer2.widthAnchor.constraint(equalToConstant: 1),
                spacer3.widthAnchor.constraint(equalToConstant: 1),
            ])
                 // Add Stack View
            let bottomstackView = UIStackView(arrangedSubviews: [spacer1, chatBtn, spacer2, editBtn,spacer3, deleteBtn,spacer4])
            bottomstackView.axis = .horizontal
            bottomstackView.alignment = .fill
            bottomstackView.distribution = .equalSpacing
            bottomstackView.spacing = 10
            bottomstackView.translatesAutoresizingMaskIntoConstraints = false
                 
            bottomView.addSubview(bottomstackView)
            
            bottomView.layer.cornerRadius = 12
            bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            bottomView.layer.masksToBounds = true
            bottomView.backgroundColor =   UIColor(red: 216/255, green: 219/255, blue: 224/255, alpha: 1.0)
            bottomView.isUserInteractionEnabled = true
       
            
            NSLayoutConstraint.activate([
                bottomstackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0),
                bottomstackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: 0),
                bottomstackView.topAnchor.constraint(equalTo: bottomView.topAnchor),
                bottomstackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
                bottomstackView.heightAnchor.constraint(equalToConstant: 50),
            ])
                        
            let stackView = UIStackView(arrangedSubviews: [titleStackView, visibleStackView, separatorView, dateLabel, collectionView])
            stackView.axis = .vertical
            stackView.spacing = 8
            contentView.addSubview(stackView)
            stackView.backgroundColor = .clear
            stackView.translatesAutoresizingMaskIntoConstraints = false


            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.backgroundColor = .white
            containerView.layer.cornerRadius = 12
            containerView.layer.shadowColor = UIColor.darkGray.cgColor
            containerView.layer.shadowOpacity = 0.5
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 5
            containerView.layer.masksToBounds = false

            contentView.addSubview(containerView)

            // 2. Constraints for containerView
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
            
            containerView.addSubview(stackView)
            containerView.addSubview(bottomView)

            // Set stackView constraints inside containerView
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
                stackView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            ])

            // Set bottomView constraints under stackView
            NSLayoutConstraint.activate([
                bottomView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
                bottomView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                bottomView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bottomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
             //   bottomView.heightAnchor.constraint(equalToConstant: 0) // if fixed height
            ])
            bottomViewconstaint = bottomView.heightAnchor.constraint(equalToConstant: 50)
            bottomViewconstaint.isActive = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 5, bottom: 15, right: 5)
            
         
        }
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewHeight()
    }
    func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .custom)
        let image = UIImage.named(title)
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = .appFont(.regular, size: 12)
        button.setTitleColor(UIColor.OLXBlueColor, for: .normal)
        button.layer.cornerRadius = 10
        return button
      }
     
    func configure(name: String, status: String, date: String, cars:  [Any] ,phonenumber : String) {
        nameLabel.text = "\(name)(\(phonenumber))".capitalizingFirstLetter()
        statusLabel.text = status
        dateLabel.text =  "Inquired Cars"
        dateLabel.textColor = .black
        phoneLabel.text = ""
        self.cars = cars
     
     //   self.updateCollectionViewHeight()
        if(phonenumber.count != 0){
            let coloredText = NSMutableAttributedString(string: "\(name) (\(phonenumber))".capitalizingFirstLetter())
            // 3️⃣ Apply Color to Part of the Text
            coloredText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: name.count)) // "Hello" in blue
            coloredText.addAttribute(.foregroundColor, value: UIColor(red: 33.0/255.0, green: 44.0/255.0, blue: 243.0/255.0, alpha: 1.0), range: NSRange(location: name.count+1, length: phonenumber.count+2))  // "Swift" in red
            nameLabel.attributedText = coloredText
        }
    }
    func updateCollectionViewHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        heightconstaint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        if(UserDefaults.standard.string(forKey: "show_archieve") == "y"){
            bottomViewconstaint.constant = 0
            restoreBtn.isHidden = false
        }
        else{
            bottomViewconstaint.constant = 50
            restoreBtn.isHidden = true
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarsCollection.identifier, for: indexPath) as! CarsCollection
        guard let dic = cars[indexPath.item] as? [String: Any] else { return cell }
        cell.configure(title: "\((dic["make"] as! String)) \((dic["model"] as! String)) \((dic["year"] as! String))")
        cell.chatBtn.tag = indexPath.row
        cell.chatBtn.addTarget(self, action: #selector(chatFunction), for: .touchUpInside)
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteindividualCar), for: .touchUpInside)
        if(self.cars.count > 1){
            cell.deleteBtn.alpha = 1.0
        }
        else{
            cell.deleteBtn.alpha = 0.0
        }
        return cell
    }
    @objc func chatFunction(sender : UIButton){
        let selectedItem = cars[sender.tag] as! NSDictionary
        delegate?.chatwithDealer(item: NSString(format: "%@", selectedItem["adId"] as! CVarArg) as String,tag: collectionView.tag)
    }
    @objc func deleteindividualCar(sender : UIButton)
    {
        let selectedItem = cars[sender.tag] as! [String:Any]
        delegate?.deleteCar(item: selectedItem,tag: collectionView.tag)
    }
    // MARK: - UICollectionView Delegate FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.frame.size.width, height: 25)
    }
}

//extension Bundle {
//    public static var buyLeadsBundle: Bundle {
//        if let bundleURL = Bundle.main.url(forResource: "OLX_BuyLeads", withExtension: "bundle"),
//                  let bundle = Bundle(url: bundleURL) {
//                   return bundle
//               } else {
//                   return Bundle(for: OnlineBuyLeads.self)
//               }
//    }
//}


extension Bundle {
    static var framework: Bundle {
        return Bundle(for: OnlineBuyLeads_cell.self)
    }
}
