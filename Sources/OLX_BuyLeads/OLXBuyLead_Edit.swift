//
//  OLXBuyLead_Edit.swift
//  OLX_BuyLeads
//
//  Created by Chandini on 30/04/25.
//

import UIKit
class VehicleinfoCell: UITableViewCell {
    let label = UILabel()
    let deleteBtn = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.text = ""
      //  label.numberOfLines = 0
        label.font = .appFont(.regular, size: 14)
      //  contentView.addSubview(label)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.setImage(UIImage.named( "delete"), for: .normal)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
     
        
        let stackView = UIStackView(arrangedSubviews: [label,spacer,deleteBtn])
        stackView.axis = .horizontal // Horizontal layout
        stackView.spacing = 5        // Space between items
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fill
               // Add StackView to the View
        contentView.addSubview(stackView)
               
        NSLayoutConstraint.activate([
            deleteBtn.heightAnchor.constraint(equalToConstant: 30),
            ])
               // Constraints
               NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
               stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                 //  stackView.widthAnchor.constraint(equalToConstant: 300),
                  // stackView.heightAnchor.constraint(equalToConstant: 30)
               ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
class HistoryCell: UITableViewCell {
    let dateLabel = UILabel()
    let followupLabel = UILabel()
    let hotLabel = UILabel()
    let notesLabel = UILabel()
    let remarksLabel = UILabel()
    
    let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
    }
 
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setupViews() {
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.OLXBlueColor.cgColor
        containerView.layer.cornerRadius = 4
        containerView.backgroundColor = UIColor.systemBackground
        
        dateLabel.font = .appFont(.bold, size: 14)
        followupLabel.font = .appFont(.regular, size: 14)
        hotLabel.font = .appFont(.regular, size: 14)
        hotLabel.textColor = .systemRed
        notesLabel.font = .appFont(.regular, size: 14)
        remarksLabel.font = .appFont(.regular, size: 14)
        notesLabel.numberOfLines = 0
        remarksLabel.numberOfLines = 0
        
        contentView.addSubview(containerView)
        [dateLabel, followupLabel, hotLabel, notesLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            followupLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            followupLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            hotLabel.centerYAnchor.constraint(equalTo: followupLabel.centerYAnchor),
            hotLabel.leadingAnchor.constraint(equalTo: followupLabel.trailingAnchor, constant: 8),
            
            notesLabel.topAnchor.constraint(equalTo: followupLabel.bottomAnchor, constant: 8),
            notesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            notesLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)

          
        ])
    }
}



class OLXBuyLead_Edit: UIViewController {

    // MARK: - Properties
    private var sectionTitles = ["Customer Details", "Vechicle Detatils", "Lead Status", "Lead History"]
    private var expandedSections: Set<Int> = [3]  // Section 0 expanded by default
    private var itemsArray: [NSMutableDictionary] = []
    var buyLeadData = [String:Any]()
    var Cities : [String] = []
    var subleads : [String] = []
    var items = NSDictionary()
    var cars: [Any] = []
    var logs: [Any] = []
    var dropdown: DropdownView?
    let loadingView = LoadingView()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .white
     
        table.register(OLXFormTableViewCell.self, forCellReuseIdentifier: "FormCell")
        table.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        table.register(VehicleinfoCell.self, forCellReuseIdentifier: "VehicleinfoCell")
        return table
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("UPDATE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .appPrimary
        return button
    }()
    let topView = UIView()
    let contactname = UILabel()
    let contactnumber = UILabel()
    let closeBtn = UIButton()
    
    // Bottom Vertical Labels
    let statusLbl = UILabel()
    let bottomLabel2 = UILabel()
    let bgView = UIView()
    let api = ApiServices()
    var sendsmsStatus = false

    private var sections: [[NSMutableDictionary]] = []
    private var treeModel: TreeListModel?

    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // loadPlistData()
        loadbuylead()
        setupUI(topviewheight: 80)

    }
    
    // MARK: - Private Methods
    private func setupUI(topviewheight : CGFloat) {
        view.backgroundColor = .white
        title = "Edit Buy Lead"
        topView.backgroundColor = .clear
        view.addSubview(topView)
        view.addSubview(tableView)
        view.addSubview(saveButton)
        topView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = .clear
        bgView.isHidden = true
        bgView.isUserInteractionEnabled = true
        view.addSubview(bgView)
        view.bringSubviewToFront(bgView)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 1
        } else {
            // Fallback on earlier versions
        }
        
        
        NSLayoutConstraint.activate([
            
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: topviewheight),
            
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // bgView
            bgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        self.setupLabels()
        layoutLabels()

    }
    @objc func closeTopView() {
        self.setupUI(topviewheight: 0)
    }
    func layoutLabels() {
        let topStack = UIStackView(arrangedSubviews: [contactname, contactnumber, closeBtn])
        topStack.axis = .horizontal
        topStack.distribution = .fillProportionally
        topStack.spacing = 10

        let bottomStack = UIStackView(arrangedSubviews: [statusLbl, bottomLabel2])
        bottomStack.axis = .vertical
        bottomStack.spacing = 0
        bottomStack.distribution = .fillEqually

        topView.addSubview(topStack)
        topView.addSubview(bottomStack)

        topStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Top horizontal labels
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            topStack.heightAnchor.constraint(equalToConstant: 20),
            
            // Bottom vertical labels
            bottomStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: 0),
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomStack.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    func setupLabels() {
          // Common style
        let allLabels = [contactname, contactnumber, statusLbl]
          for label in allLabels {
              label.textAlignment = .left
              label.textColor = .black
              label.backgroundColor = .clear
              label.font = .appFont(.regular, size: 14)
              label.layer.cornerRadius = 8
              label.clipsToBounds = true
          }
        closeBtn.addTarget(self, action: #selector(closeTopView), for: .touchUpInside)
        contactname.text =  (items["contact_name"]! as! String)
        contactnumber.text = "\(items["mobile_clicked"]! as! String)\(items["mobile"]! as! String)"
        closeBtn.setImage(UIImage.named("close"),for: .normal)
        statusLbl.text = "\(items["status_text"]! as! String)\n\(items["addeddate"]! as! String)"
        statusLbl.numberOfLines = 0
       
    
        if((items["contact_name"]! as! String).count != 0){
            let coloredText = NSMutableAttributedString(string:  "N : \(items["contact_name"]! as! String)")
            // 3️⃣ Apply Color to Part of the Text
            coloredText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 1)) // "Hello" in blue
            coloredText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 4, length: (items["contact_name"]! as! String).count))  // "Swift" in red
            contactname.attributedText = coloredText
        }
        
        let phonenumber = (items["mobile"]! as! String)
        let name = "M"
        if((items["mobile"]! as! String).count != 0){
            let coloredText = NSMutableAttributedString(string:  "\(name) : \(items["mobile"]! as! String)")
            // 3️⃣ Apply Color to Part of the Text
            coloredText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: name.count)) // "Hello" in blue
            coloredText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: name.count+3, length: phonenumber.count))  // "Swift" in red
            contactnumber.attributedText = coloredText
        }
        if((items["mobile_clicked"]! as! String) != "y"){
            let callGesture = UITapGestureRecognizer(target: self, action: #selector(calltoBuyLead))
            contactnumber.addGestureRecognizer(callGesture)
        }
      }
    @objc func calltoBuyLead(sender : UITapGestureRecognizer){
      if let phoneURL = URL(string: "tel://\(items["mobile"]! as! String)"),
         UIApplication.shared.canOpenURL(phoneURL) {
          UIApplication.shared.open(phoneURL)
      } else {
          print("📵 Calling not supported on this device")
      }
  }
    
    
    func loadbuylead()
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        let parameters = [
            "action":"loadbuylead",
            "dealer_id":MyPodManager.user_id,
            "buylead_id":UserDefaults.standard.value(forKey: "buylead_id")!,
                "api_id":"cteolx2024v1.0",
            "device_id":Constant.uuid!,
        ] as! [String:Any]
        
        
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                if  let dic = data["data"] as? NSDictionary{
                    if(data["status"] as! String == "success"){
                        DispatchQueue.main.async {
                            if  let dic = data["data"] as? NSDictionary{
                                self.buyLeadData = (dic["buylead"] as! NSDictionary) as! [String : Any]
                                self.cars = (self.buyLeadData["cars"] as! NSArray) as! [Any]
                                self.logs = (dic["log"] as! NSArray) as! [Any]
                                self.updatePlistWithAPIResponse()
                                self.tableView.reloadData()
                            }
                            else{
                                print(data)
                            }
                        }
                    }
                    else{
                      //  OnlineBuyLeads().refreshToken()
                      //  self.navigationController?.popViewController(animated: true)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
              
            }
        }
    }
    
    private func updatePlistWithAPIResponse() {
           // Get the bundle for this module
           let bundle = Bundle.module
           
           // Get the plist URL from the bundle
           guard let url = bundle.url(forResource: "buyleadPhoneClick", withExtension: "plist"),
                 let data = try? Data(contentsOf: url),
                 let plistDict = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
                 var valueArray = plistDict["value"] as? [[String: Any]] else {
               print("Failed to load plist data")
               return
           }
           
           // Update Customer Details section
           if let customerDetailsSection = valueArray.first(where: { ($0["main"] as? Bool) == true }),
              var customerDetails = customerDetailsSection["value"] as? [[String: Any]] {
               
               // Update each field
               for (index, var item) in customerDetails.enumerated() {
                   switch item["key"] as? String {
                   case "FirstName":
                       item["text"] = buyLeadData["name"] as? String ?? ""
                   case "Mobile":
                       item["text"] = buyLeadData["mobile"] as? String ?? ""
                   case "Email":
                       item["text"] = buyLeadData["email"] as? String ?? ""
                   case "State":
                       let state = buyLeadData["state"] as? String ?? ""
                       item["text"] = state
                   case "City":
                       let state = buyLeadData["city"] as? String ?? ""
                       item["text"] = state
                   default:
                       break
                   }
                   customerDetails[index] = item
               }
               // Update the modified customer details back to the section
               if let sectionIndex = valueArray.firstIndex(where: { ($0["main"] as? Bool) == true }) {
                   valueArray[sectionIndex]["value"] = customerDetails
               }
           }
           
           // Update Lead Status section
           if let leadStatusSection = valueArray.last(where: { ($0["main"] as? Bool) == true }),
              var leadStatus = leadStatusSection["value"] as? [[String: Any]] {
               
               for (index, var item) in leadStatus.enumerated() {
                   switch item["key"] as? String {
                   case "status_category":
                       item["text"] = buyLeadData["status_category"] as? String ?? ""
                   case "status":
                       item["text"] = buyLeadData["status"] as? String ?? ""
                   case "substatus":
                       item["text"] = buyLeadData["substatus"] as? String ?? ""
                   case "status_date":
                       item["text"] = buyLeadData["status_date"] as? String ?? ""
                   case "Customer Visited":
                       item["text"] = (buyLeadData["customer_visited"] as! String).count == 0 ? "no" : "yes"
                   case "customer_visited":
                       item["text"] = buyLeadData["customer_visited"] as? String ?? ""
                       item["isOpen"] = (buyLeadData["customer_visited"] as! String).count == 0 ? true : false
                   case "statustext":
                       item["text"] = buyLeadData["statustext"] as? String ?? ""
                   default:
                       break
                   }
                   leadStatus[index] = item
               }
               // Update the modified lead status back to the section
               if let sectionIndex = valueArray.lastIndex(where: { ($0["main"] as? Bool) == true }) {
                   valueArray[sectionIndex]["value"] = leadStatus
               }
           }
           
           
           // Create sections array for the tree model
         //  var sections: [[NSMutableDictionary]] = []
           
           // Vehicle Details Section (Section 0)
           if valueArray.count > 0,
              let vehicleDetails = valueArray[0]["value"] as? [[String: Any]] {
               sections.append(vehicleDetails.map { NSMutableDictionary(dictionary: $0) })
           } else {
               sections.append([])
           }
           
           // Empty Custom Section 1
           sections.append([])
           
           // Additional Details Section (Section 2)
           if valueArray.count > 1,
              let additionalDetails = valueArray[1]["value"] as? [[String: Any]] {
               sections.append(additionalDetails.map { NSMutableDictionary(dictionary: $0) })
           } else {
               sections.append([])
           }
           
           // Empty Custom Section 2
           sections.append([])
           
           // Update the tree model with the new sections
           treeModel = TreeListModel()
           treeModel?.updateSections(sections)
           
           // Update the itemsArray for the table view
           itemsArray = sections.flatMap { $0 }
           
           // Reload the table view
           self.tableView.reloadData()
       }
    private func updatePlistWithAPIResponse123() {
        // Get the bundle for this module
        let bundle = Bundle.module
        
        // Get the plist path from the bundle
        guard let plistPath = bundle.path(forResource: "buyleadPhoneClick", ofType: "plist") else {
            print("Could not find plist file path in bundle")
            return
        }
        
        guard let plistDict = NSMutableDictionary(contentsOfFile: plistPath) else {
            print("Failed to load plist as dictionary")
            return
        }
        
        // Get the value array which contains our sections
        guard var valueArray = plistDict["value"] as? [[String: Any]] else {
            print("Could not find 'value' array in plist")
            return
        }
        
        // Update Customer Details section
        if let customerDetailsSection = valueArray.first(where: { ($0["main"] as? Bool) == true }),
           var customerDetails = customerDetailsSection["value"] as? [[String: Any]] {
            
            // Update each field
            for (index, var item) in customerDetails.enumerated() {
                switch item["key"] as? String {
                case "FirstName":
                    item["text"] = buyLeadData["name"] as? String ?? ""
                case "Mobile":
                    item["text"] = buyLeadData["mobile"] as? String ?? ""
                case "Email":
                    item["text"] = buyLeadData["email"] as? String ?? ""
                case "State":
                    let state = buyLeadData["state"] as? String ?? ""
                    item["text"] = state
                case "City":
                    let state = buyLeadData["city"] as? String ?? ""
                    item["text"] = state
                default:
                    break
                }
                customerDetails[index] = item
            }
            
            // Update the modified customer details back to the section
            if let sectionIndex = valueArray.firstIndex(where: { ($0["main"] as? Bool) == true }) {
                valueArray[sectionIndex]["value"] = customerDetails
            }
        }
        
        // Update Lead Status section
        if let leadStatusSection = valueArray.last(where: { ($0["main"] as? Bool) == true }),
           var leadStatus = leadStatusSection["value"] as? [[String: Any]] {
            
            for (index, var item) in leadStatus.enumerated() {
                switch item["key"] as? String {
                case "status_category":
                    item["text"] = buyLeadData["status_category"] as? String ?? ""
                case "status":
                    item["text"] = buyLeadData["status"] as? String ?? ""
                case "substatus":
                    item["text"] = buyLeadData["substatus"] as? String ?? ""
                case "status_date":
                    item["text"] = buyLeadData["status_date"] as? String ?? ""
                case "Customer Visited":
                    item["text"] = (buyLeadData["customer_visited_date"] as? String ?? "").count == 0 ? "no" : "yes"
                case "customer_visited":
                    item["text"] = buyLeadData["customer_visited_date"] as? String ?? ""
                    item["isOpen"] = (buyLeadData["customer_visited_date"] as? String ?? "").count == 0
                case "statustext":
                    item["text"] = buyLeadData["statustext"] as? String ?? ""
                default:
                    break
                }
                leadStatus[index] = item
            }
            
            // Update the modified lead status back to the section
            if let sectionIndex = valueArray.lastIndex(where: { ($0["main"] as? Bool) == true }) {
                valueArray[sectionIndex]["value"] = leadStatus
            }
        }
        
        // Update the modified value array back to the plist dictionary
        plistDict["value"] = valueArray
        
        // Create sections array from the updated plist data
        sections = []
        for section in valueArray {
            if let sectionItems = section["value"] as? [[String: Any]] {
                sections.append(sectionItems.map { NSMutableDictionary(dictionary: $0) })
            } else {
                sections.append([])
            }
        }
        itemsArray = sections.flatMap { $0 }

        // Update the tree model
        treeModel = TreeListModel()
        treeModel?.updateSections(sections)
        
        self.tableView.reloadData()
    }
    
    private func getCustomCells(for section: Int) -> [String] {
        switch section {
        case 1:
            return ["Custom Cell 2-1", "Custom Cell 2-2"]
        case 3:
            return ["Custom Cell 2-1", "Custom Cell 2-2"]
        default:
            return []
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dropdown?.removeFromSuperview()
        self.bgView.isHidden = true
    }
    @objc private func saveButtonTapped() {
        // Print all data
        var message = ""
        var parameters = [
            "action":"updatebuylead",
            "dealer_id":MyPodManager.user_id,
            "api_id":"cteolx2024v1.0",
            "buylead_id":UserDefaults.standard.value(forKey: "buylead_id")!,
            "state":"",
            "name":"",
            "email":"",
            "mobile":"",
            "city":"",
            "customer_visited":"",
            "status_date":"",
            "status":"",
            "substatus":"",
            "statustext":"",
            "status_category":"",
            "device_id":Constant.uuid!
        ] as! [String:Any]
        for (sectionIndex, title) in sectionTitles.enumerated() {
            print("Section \(sectionIndex): \(title)")
          
            if sectionIndex == 0 || sectionIndex == 2 {
                // Print plist data
                if let items = treeModel?.itemsInSection(sectionIndex) {
                    for item in items {
                        if let key = item["key"] as? String,
                           let text = item["text"] as? String {
                            print("  \(key): \(text)")
                            if(key == "FirstName"){
                                if(text.count > 50)
                                {
                                    message  = message.count == 0 ? "Invalid Name" : "\(message)-Invalid Name"
                                }
                                parameters["name"] = text
                            }
                            if(key == "Mobile"){
                                if(!api.isValidPhoneNumber(text))
                                {
                                    message  = message.count == 0 ? "Invalid Mobile Number" :"\(message)-Invalid Mobile Number"
                                }
                                parameters["mobile"] = text
                            }
                            if(key == "Email"){
                                if(text.count != 0){
                                    if(!api.isValidEmail(text))
                                    {
                                        message  = message.count == 0 ? "Invalid Email Id":"\(message)-Invalid Email Id"
                                    }
                                }
                                parameters["email"] = text
                            }
                            if(key == "State"){
                               
                                parameters["state"] = text
                            }
                            if(key == "City"){
                                
                                parameters["city"] = text
                            }
                            if(key == "status_category"){
                                if(text.count == 0)
                                {
                                    message = message.count == 0 ?"Classification":"\(message)-Classification"
                                }
                                parameters["status_category"] = text
                            }
                            if(key == "status"){
                                if(text.count == 0)
                                {
                                    message = message.count == 0 ? "Lead Status" :"\(message)-Lead Status"
                                }
                                parameters["status"] = text

                            }
                            if(key == "substatus"){
                                if(text.count == 0)
                                {
                                    message =  message.count == 0 ? "Lead SubStatus":"\(message)-Lead SubStatus"
                                }
                                parameters["substatus"] = text

                            }
                            if(key == "status_date"){
                                if(text.count == 0)
                                {
                                    message = message.count == 0 ?"Status Date" :"\(message)-Status Date"
                                }
                                parameters["status_date"] = text

                            }
                            if(key == "Customer Visited"){
                                if(text == "yes")
                                {
                                message =  message.count == 0 ? "Customer Visited Date" :"\(message)-Customer Visited Date"
                                }
                            }
                            if(key == "customer_visited"){
                                parameters["customer_visited"] = item["isOpen"] as! Bool ? "" : text
                            }
                            if(key == "statustext"){
                                if(text.count == 0)
                                {
                                    message =  message.count == 0 ?"Status Text":"\(message)-Status Text"
                                }
                                parameters["statustext"] = text
                            }
                            if(key == "Send Sms"){
                                self.sendsmsStatus = text == "yes" ? true : false
                            }
                        }
                    }
                }
                if(message.count != 0){
                    self.customAlert(title: "Please Fill Valid Details..", message: message.replacingOccurrences(of: "-", with: "<br>"), confirmTitle: "OK", cancelTitle: "CANCEL")
                    return
                }
            }
        }
        
        if(message.count == 0){
            loadingView.show(in: self.view, withText: "Updating Lead...")
            let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
            
            api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                switch result {
                case .success(let data):
                    print("Response Data: \(data)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.loadingView.hide()
                    }
                        if(data["status"] as! String == "success"){
                            DispatchQueue.main.async {
                                self.view.showCustomAlert(image:"",
                                    title: "Update Successful",
                                    message: data["data"]! as! String,
                                    confirmTitle: "OK", // Optional, defaults to "OK"
                                    cancelTitle: "", // Optional, defaults to "CANCEL"
                                    confirmAction: {
                                        print("Confirmed")
                                        self.navigationController?.popViewController(animated: true)
                                        NotificationCenter.default.post(name:Notification.Name("refreshLeads"), object: nil)
                                    },
                                    cancelAction: {
                                        print("Cancelled")
                                    }
                                )
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if(self.sendsmsStatus){
                                        self.sendSMS()
                                    }
                                 }
                            }
                        }
                        else{
                            DispatchQueue.main.async {
                                self.customAlert(title: "Failed", message: (data["error"]! as! String).replacingOccurrences(of: "<br>", with: "\n"), confirmTitle: "OK", cancelTitle: "")
                            }
                        }
                  
                case .failure(let error):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.loadingView.hide()
                    }
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    func sendSMS()
    {
            DispatchQueue.main.async {
                let popup = SendSMSPopupViewController()
                popup.items = self.items as! [String : Any]
                popup.modalPresentationStyle = .overCurrentContext
                popup.modalTransitionStyle = .crossDissolve
                self.present(popup, animated: true)
            }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension OLXBuyLead_Edit: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard expandedSections.contains(section) else { return 0 }
        
        switch section {
        case 0:
            return treeModel?.numberOfItemsInSection(section) ?? 0
        case 2:
            return treeModel?.numberOfItemsInSection(section) ?? 0
        case 1:
            return self.cars.count
        case 3:
            return logs.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FormCell", for: indexPath) as! OLXFormTableViewCell
            cell.delegate = self
            cell.setCellDataBasedOnIndexPath(indexPath, treeModel: treeModel!, view: view, tableView: tableView)
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
            let dic = logs[indexPath.row] as! NSDictionary
            cell.dateLabel.text = "\(dic["updated_date_time"] as! String)"
            cell.followupLabel.text = "\(dic["status"] as! String)"
            cell.hotLabel.text = "\(dic["lead_classification"] as! String)"
            
            if((dic["lead_classification"]! as! String) == "HOT" || (dic["lead_classification"]! as! String) == "VERY HOT"){
                cell.hotLabel.textColor = .systemRed
            }
            else if((dic["lead_classification"]! as! String) == "COLD"){
                cell.hotLabel.textColor = .appPrimary
            }
            else{
                cell.hotLabel.textColor = .systemOrange
            }
            cell.notesLabel.text = "Notes: \(dic["notes"] as! String)"
            cell.remarksLabel.text = "Remarks: \(dic["notes"] as! String)"
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleinfoCell", for: indexPath) as! VehicleinfoCell
            let dic = cars[indexPath.row] as! NSDictionary
            cell.label.text = "\((dic["make"] as! String)) \((dic["model"] as! String)) \((dic["year"] as! String))"
            if(cars.count > 1){
                cell.deleteBtn.isHidden = false
            }
            else{
                cell.deleteBtn.isHidden = true
            }
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteCar), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    @objc func deleteCar(sender : UIButton)
    {
        let response =  cars[sender.tag] as! [String : Any]
        self.view.showCustomAlert(image: "delete_alert",
            title: "Remove Car",
            message: "Do you want to remove this \(response["make"] ?? "")?",
            confirmTitle: "DELETE", // Optional, defaults to "OK"
            cancelTitle: "CANCEL", // Optional, defaults to "CANCEL"
            confirmAction: {
                print("Deleted")
                self.deleteDealerCar(carid: response["id"] as! String,buyLead_id:  UserDefaults.standard.value(forKey: "buylead_id")! as! String,tag: sender.tag)
            },
            cancelAction: {
                print("Cancelled")
            }
        )
        
    }
    func deleteDealerCar(carid : String,buyLead_id:String,tag : Int)
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
            let parameters = [
                "action":"archivebuyleadcar",
               "api_id":"cteolx2024v1.0",
                "device_id":Constant.uuid!,
                "buylead_id":buyLead_id,
                "carid":carid,
                "dealer_id":MyPodManager.user_id
             ] as! [String:Any]
            let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                switch result {
                case .success(let data):
                    print("Response Data: \(data)")
                    DispatchQueue.main.async {
                        if  let dic = data["data"] as? NSDictionary{
                            if(data["status"] as! String == "success"){
                                self.view.showCustomAlert(image: "",
                                    title: "Success",
                                    message: data["details"] as! String,
                                    confirmTitle: "Ok", // Optional, defaults to "OK"
                                    cancelTitle: "", // Optional, defaults to "CANCEL"
                                    confirmAction: {
                                        print("Deleted")
                                        print("Deleted")
                                         self.cars.remove(at: tag)
                                         self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
                                         NotificationCenter.default.post(name:Notification.Name("refreshLeads"), object: nil)
                                    },
                                    cancelAction: {
                                        print("Cancelled")
                                    }
                                )
                            }
                            else{
                                self.customAlert(title: "Failed", message: dic["error"] as! String, confirmTitle: "Ok", cancelTitle: "")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                    }
                }
            }
    }
    func customAlert(title: String, message: String, confirmTitle: String, cancelTitle: String)
    {
        self.view.showCustomAlert(image: "",
            title: title,
            message: message,
            confirmTitle: confirmTitle, // Optional, defaults to "OK"
            cancelTitle: cancelTitle, // Optional, defaults to "CANCEL"
            confirmAction: {
              
            },
            cancelAction: {
                print("Cancelled")
            }
        )
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 236/255, green: 241/255, blue: 255/255, alpha: 1.0)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = sectionTitles[section]
        titleLabel.font = .appFont(.medium, size: 16)
        titleLabel.textColor = .appPrimary
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage.named(expandedSections.contains(section) ? "uparrow" : "downarrow_new")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            imageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(tapGesture)
        headerView.tag = section
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(sections.count != 0){
            if(indexPath.section == 2){
                let item = sections[indexPath.section][indexPath.row]
                if(item["isOpen"] as! Bool)
                {
                    return 0
                }
                if(item["key"] as? String  == "Lead Classification" || item["key"] as? String  == "Lead Status" || item["key"] as? String  ==  "Note Against Status"){
                 return 30
                }
                if(item["action"] as? String  == "checkBox"){
                 return 35
                }
                return 60
            }
            return UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
    @objc private func sectionHeaderTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        
        // If the tapped section is already expanded, collapse it
        if expandedSections.contains(section) {
            expandedSections.remove(section)
        } else {
            // If a different section was expanded, collapse it first
            if let previousExpanded = expandedSections.first {
                expandedSections.remove(previousExpanded)
                tableView.reloadSections(IndexSet(integer: previousExpanded), with: .automatic)
            }
            // Expand the new section
            expandedSections.insert(section)
        }
        
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
}

// MARK: - CTEFormTableViewCellDelegate
extension OLXBuyLead_Edit: CTEFormTableViewCellDelegate,UITextFieldDelegate {
    
    public func getStatesList()->[String]{
        return InventoryAPIManager.sharedInstance.getstates() as! [String]
    }
    public func getCitiesList(state : String)->[String]{
        return InventoryAPIManager.sharedInstance.getCities(state: state) as! [String]
    }
    public func getleadstatus()->[String]{
        return InventoryAPIManager.sharedInstance.getleadStatus() as! [String]
    }
    public func getsubleadstatus(leadState : String)->[String]{
        return InventoryAPIManager.sharedInstance.getsubleads(leadstate: leadState ) as! [String]
    }
    
    func didSelectButton(_ button: UIButton) {
        // Handle button selection
        print("Button tapped: \(button.title(for: .normal) ?? "")")
        print("Selected button tapped")
        
        // Find the cell by traversing up the view hierarchy
        var view: UIView? = button
        while view != nil && !(view is UITableViewCell) {
            view = view?.superview
        }
        
        guard let cell = view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            print("Could not find index path for button")
            return
        }
        
        print("Selected index path: section=\(indexPath.section), row=\(indexPath.row)")
        treeModel!.setSelectedIndexPath(indexPath)

        let item = sections[indexPath.section][indexPath.row]
        let key = item["key"] as? String ?? ""
        let action = item["type"] as? String ?? ""
        var header = ""
        if action == "button" {
            // For select action, show options picker
            var options: [String] = []
            switch key {
            case "State":
                options = getStatesList()
                header = "Select State"
            case "City":
                header = "Select City"
                options = self.Cities
            case "status_category":
                header = "Select Classificatoin"
                options =  ["VERY HOT","HOT","WARM","COLD"]
            case "status":
                header = "Select Status"
                options  = self.getleadstatus()
            case "substatus":
                header = "Select Substatus"
                options  = self.subleads
            default:
                options = ["Option 1", "Option 2", "Option 3"]
            }
            
            if dropdown?.superview == nil {
                showOptionsAlert(options: options, for: indexPath,header: header)
               }
          
        } else if action == "datePicker" {
            // For date field, show date picker
            switch key {
            case "customer_visited":
                header = "Select State"
            default:
                break
            }
            showDatePicker(for: indexPath,keyvalue: "customer_visited")
        }
    }
    
    func selectedCheckBox(_ button: UIButton) {
        print("Checkbox tapped")
        
        // Find the cell by traversing up the view hierarchy
        var view: UIView? = button
        while view != nil && !(view is UITableViewCell) {
            view = view?.superview
        }
        
        guard let cell = view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            print("Could not find index path for checkbox")
            return
        }
        
        print("Selected index path: section=\(indexPath.section), row=\(indexPath.row)")
        treeModel!.setSelectedIndexPath(indexPath)
        
        if(self.sections[indexPath.section][indexPath.row]["placeholder"] as! String  == "Send sms to customer")
        {
            self.sections[indexPath.section][indexPath.row]["text"] =  button.isSelected ? "yes" : "no"
            self.treeModel?.updateSections(self.sections ?? [])

            let indexPaths = [
                IndexPath(row: indexPath.row, section: indexPath.section),
            ]
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
        else{
            self.sections[indexPath.section][indexPath.row]["text"] =  button.isSelected ? "yes" : "no"
            self.sections[indexPath.section][indexPath.row+1]["isOpen"] =  button.isSelected ? false : true
            self.treeModel?.updateSections(self.sections ?? [])
            let indexPaths = [
                IndexPath(row: indexPath.row, section: indexPath.section),
                IndexPath(row: indexPath.row+1, section: indexPath.section)
            ]
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
       
    }
    
 
    
    func didSelectCheckbox(_ button: UIButton) {
        // Handle checkbox selection
        print("Checkbox tapped")
    }
    
    func didUpdateTextField(_ textField: UITextField) {
        // Handle text field changes
//        print("Text field changed: \(textField.text ?? "")")
//        // Find the cell by traversing up the view hierarchy
//        var view: UIView? = textField
//        while view != nil && !(view is UITableViewCell) {
//            view = view?.superview
//        }
//        guard let cell = view as? UITableViewCell,
//              let indexPath = tableView.indexPath(for: cell) else {
//            print("Could not find index path for text field")
//            return
//        }
//        
//        print("Selected index path: section=\(indexPath.section), row=\(indexPath.row)")
//        treeModel!.setSelectedIndexPath(indexPath)
//        
//        if indexPath.section < sections.count,
//           indexPath.row < sections[indexPath.section].count {
//            sections[indexPath.section][indexPath.row]["text"] = textField.text ?? ""
//            self.treeModel?.updateSections(self.sections ?? [])
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
        
        print("Text field changed: \(textField.text ?? "")")
        
        // Find the cell by traversing up the view hierarchy
        var view: UIView? = textField
        while view != nil && !(view is UITableViewCell) {
            view = view?.superview
        }
        
        guard let cell = view as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            print("Could not find index path for text field")
            return
        }
        print("Selected index path: section=\(indexPath.section), row=\(indexPath.row)")
        treeModel!.setSelectedIndexPath(indexPath)
        
        if indexPath.section < sections.count,
           indexPath.row < sections[indexPath.section].count {
            sections[indexPath.section][indexPath.row]["text"] = textField.text ?? ""
            self.treeModel?.updateSections(self.sections ?? [])
        }
        textField.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    private func showOptionsAlert(options: [String], for indexPath: IndexPath,header:String) {
        self.bgView.isHidden = false
        self.view.resignFirstResponder()
        dropdown?.removeFromSuperview()
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // Calculate the frame for the dropdown
        let cellFrame = cell.convert(cell.bounds, to: view)
        let dropdownWidth: CGFloat = cell.frame.size.width-40
        let dropdownHeight: CGFloat = min(CGFloat(options.count * 44) + 40, 300) // 40 for header, 44 per row
        let dropdownFrame = CGRect(
            x: cellFrame.midX - dropdownWidth/2,
            y: cellFrame.maxY ,
            width: dropdownWidth,
            height: dropdownHeight
        )
        
        // Get the section title for the dropdown header
        let sectionTitle = sectionTitles[indexPath.section]
        
        // Create and show the dropdown
        self.dropdown = DropdownView(items: options, headertitle: header, frame: dropdownFrame)
        self.dropdown!.onItemSelected = { [weak self] selectedItem in
            
            self!.bgView.isHidden = true
            self?.sections[indexPath.section][indexPath.row]["text"] = selectedItem.contains("Select") ? "" : selectedItem
            self!.treeModel?.updateSections(self?.sections ?? [])
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            if(header == "Select State"){
                self!.sections[indexPath.section][indexPath.row+1]["text"] = ""
                self!.treeModel?.updateSections(self?.sections ?? [])
                self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row+1, section: indexPath.section)], with: .automatic)
                self?.Cities = (self?.getCitiesList(state: selectedItem))!
            }
            if(header == "Select Status"){
                self?.subleads = (self?.getsubleadstatus(leadState:selectedItem))!
                if(self?.subleads.count == 0)
                {
                    self!.sections[indexPath.section][indexPath.row+1]["text"] = ""
                    self!.sections[indexPath.section][indexPath.row+1]["isOpen"] = true
                    self!.treeModel?.updateSections(self?.sections ?? [])
                    self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row+1, section: indexPath.section)], with: .automatic)
                }
                else{
                    self!.sections[indexPath.section][indexPath.row+1]["text"] = ""
                    self!.sections[indexPath.section][indexPath.row+1]["isOpen"] = false
                    self!.treeModel?.updateSections(self?.sections ?? [])
                    self?.tableView.reloadRows(at: [IndexPath(row: indexPath.row+1, section: indexPath.section)], with: .automatic)
                }
            }
        }
        view.addSubview(self.dropdown!)
    }
    
    private func showDatePicker(for indexPath: IndexPath,keyvalue : String) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if(keyvalue == "customer_visited"){
            datePicker.maximumDate = Date()
        }
        else{
            datePicker.maximumDate = nil
        }
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        let alert = UIAlertController(title: "Select Date", message: "\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        // Configure datePicker constraints
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
            datePicker.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: datePicker.date)
            self?.sections[indexPath.section][indexPath.row]["text"] = dateString
            self!.treeModel?.updateSections(self?.sections ?? [])
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = alert.popoverPresentationController,
           let cell = tableView.cellForRow(at: indexPath) {
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        present(alert, animated: true)
    }
}
