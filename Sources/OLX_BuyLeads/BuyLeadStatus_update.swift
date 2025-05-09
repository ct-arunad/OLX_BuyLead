//
//  BuyLeadStatus_update.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 11/04/25.


import Foundation
import UIKit



class BuyLeadStatus_update : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var sections: [[NSMutableDictionary]] = []
    private var treeModel: TreeListModel?
    var sendsmsstatus = false
    let datePicker = UIDatePicker()
    let visiteddatePicker = UIDatePicker()

    var items = NSDictionary()

    var buyLeadData = [String:Any]()
    var Cities : [String] = []
    var subleads : [String] = []

    let topView = UIView()

    let popupView = UIView()
    let updateButton = UIButton(type: .system)
    
    let bgView = UIView()

       // Top Horizontal Labels
        let contactname = UILabel()
        let contactnumber = UILabel()
        let closeBtn = UIButton()
        
        // Bottom Vertical Labels
        let statusLbl = UILabel()
        let bottomLabel2 = UILabel()

    private let tableView = UITableView()
    

    
    var expandedSections: Set<Int> = [] // Track expanded sections
    var dropdown: DropdownView?
    private var sectionTitles = ["Lead Status"]
    private var itemsArray: [NSMutableDictionary] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.setupLayout(topviewheight: 140)
        self.tableView.reloadData()
        self.loadbuylead()
    }
    @objc func backButtonTapped()
    {
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dropdown?.removeFromSuperview()
        self.bgView.isHidden = true
    }
    func setupViews() {
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
           // Top View
      //  self.view.backgroundColor = .white
           topView.backgroundColor = .white
        self.view.addSubview(topView)

           // TableView
           tableView.dataSource = self
           tableView.delegate = self
        tableView.backgroundColor = .clear
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 1
        }
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.register(OLXFormTableViewCell.self, forCellReuseIdentifier: "FormCell")
        
           // Bottom Button
        updateButton.setTitle("Update", for: .normal)
        updateButton.titleLabel?.font = .appFont(.bold, size: 18)
        updateButton.backgroundColor = .appPrimary
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.layer.cornerRadius = 10
        updateButton.addTarget(self, action: #selector(updatebuylead), for: .touchUpInside)
        self.view.addSubview(updateButton)
        
        bgView.backgroundColor = .clear
        bgView.isHidden = true
        bgView.isUserInteractionEnabled = true
        view.addSubview(bgView)
        view.bringSubviewToFront(bgView)
       }

    func setupLayout(topviewheight : CGFloat) {
            popupView.translatesAutoresizingMaskIntoConstraints = false
           topView.translatesAutoresizingMaskIntoConstraints = false
           tableView.translatesAutoresizingMaskIntoConstraints = false
           updateButton.translatesAutoresizingMaskIntoConstraints = false
            bgView.translatesAutoresizingMaskIntoConstraints = false

           NSLayoutConstraint.activate([
            
        
            popupView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 50),
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),

               // Top View
               topView.topAnchor.constraint(equalTo:  popupView.topAnchor,constant: 20),
               topView.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor,constant: 25),
               topView.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor,constant: -25),
               topView.heightAnchor.constraint(equalToConstant: 60),
            

               // Bottom Button
               updateButton.bottomAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
               updateButton.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor, constant: 70),
               updateButton.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor, constant: -70),
               updateButton.heightAnchor.constraint(equalToConstant: 50),

               // TableView
               tableView.topAnchor.constraint(equalTo: topView.bottomAnchor,constant: 30),
               tableView.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor,constant: 25),
               tableView.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor,constant: -25),
               tableView.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -10),
            
            // bgView
            bgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 50)
           ])
           self.setupLabels()
           self.layoutLabels()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
       }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        tableView.contentInset.bottom = keyboardHeight
        tableView.scrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
    }
    @objc func closeTopView() {
        self.dismiss(animated: false)
    }
    
    func setupLabels() {
          // Common style
        let allLabels = [contactname, contactnumber, statusLbl, bottomLabel2]
          for label in allLabels {
              label.textAlignment = .left
              label.textColor = .black
              label.backgroundColor = .clear
              label.font = .appFont(.regular, size: 14)
              label.layer.cornerRadius = 8
              label.clipsToBounds = true
          }
        closeBtn.addTarget(self, action: #selector(closeTopView), for: .touchUpInside)
        contactname.text =  "\(items["contact_name"]! as! String)\n(\(items["mobile_clicked"]! as! String)\(items["mobile"]! as! String))"
        contactname.numberOfLines = 0
        contactnumber.textAlignment = .right
        contactnumber.text = "id:\(items["buylead_id"]! as! String)"
        closeBtn.setImage(UIImage.named( "close"),for: .normal)
        statusLbl.text = (items["status_text"]! as! String)
        bottomLabel2.text = (items["addeddate"]! as! String)
        bottomLabel2.backgroundColor = .clear
      
        let name = "N\(items["contact_name"]! as! String)"
        let phonenumber = items["mobile"]! as! String
        if(phonenumber.count != 0){
            let coloredText = NSMutableAttributedString(string: "\(name)\n(\(phonenumber))".capitalizingFirstLetter())
            // 3️⃣ Apply Color to Part of the Text
            coloredText.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: name.count)) // "Hello" in blue
            coloredText.addAttribute(.foregroundColor, value: UIColor(red: 33.0/255.0, green: 44.0/255.0, blue: 243.0/255.0, alpha: 1.0), range: NSRange(location: name.count+1, length: phonenumber.count+2))  // "Swift" in red
            contactname.attributedText = coloredText
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
      func layoutLabels() {
          
       
          let topStack = UIStackView(arrangedSubviews: [contactname, contactnumber])
           topStack.axis = .horizontal
          topStack.alignment = .center
          topStack.distribution = .fillEqually
          topStack.backgroundColor = .cellbg

//          let bottomStack = UIStackView(arrangedSubviews: [statusLbl, bottomLabel2])
//          bottomStack.axis = .vertical
//          bottomStack.spacing = 0
//          bottomStack.distribution = .fillProportionally

          topView.addSubview(topStack)
//          topView.addSubview(bottomStack)

          let titleLabel = UILabel()
          titleLabel.text = "Lead Status Update"
          titleLabel.textAlignment = .left
          titleLabel.textColor = .appPrimary
          titleLabel.font = .appFont(.bold, size: 20)
          topView.addSubview(titleLabel)
          
          topView.addSubview(closeBtn)
          
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          closeBtn.translatesAutoresizingMaskIntoConstraints = false

          topStack.translatesAutoresizingMaskIntoConstraints = false
//          bottomStack.translatesAutoresizingMaskIntoConstraints = false

          NSLayoutConstraint.activate([
              // Top horizontal labels
            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            closeBtn.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            closeBtn.heightAnchor.constraint(equalToConstant: 30),
            closeBtn.widthAnchor.constraint(equalToConstant: 30),

             topStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
              topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
              topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
              topStack.heightAnchor.constraint(equalToConstant: 40),
              
          ])
      }
    func fetchinventory()
    {
        print(self.getMakeList())
    }
    public func getMakeList()->[String]{
        return InventoryAPIManager.sharedInstance.getVariants() as! [String]
    }
    
    func loadbuylead()
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        let parameters = [
            "action":"loadbuylead",
            "dealer_id":MyPodManager.user_id,
            "buylead_id":UserDefaults.standard.value(forKey: "buylead_id") ?? "",
            "api_id":"cteolx2024v1.0",
            "device_id":Constant.uuid!,
        ] as! [String:Any]
        print(parameters)
        
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                if  let dic = data["data"] as? NSDictionary{
                    if(data["status"] as! String == "success"){
                        DispatchQueue.main.async {
                            if  let dic = data["data"] as? NSDictionary{
                                self.buyLeadData = (dic["buylead"] as! NSDictionary) as! [String : Any]
                                self.updatePlistWithAPIResponse()
                            }
                            else{
                                print(data)
                            }
                        }
                    }
                    else{
                      //  OnlineBuyLeads().refreshToken()
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
    private func updatePlistWithAPIResponse() {
        // Get the bundle for this module
        let bundle = Bundle.module
        
        // Get the plist URL from the bundle
        guard let url = bundle.url(forResource: "BuyLeadOnline", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plistDict = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
              var valueArray = plistDict["value"] as? [[String: Any]] else {
            print("Failed to load plist data")
            return
        }
        // Update Lead Status section
        if let leadStatusSection = valueArray.first(where: { ($0["main"] as? Bool) == true }),
           var leadStatus = leadStatusSection["value"] as? [[String: Any]] {
            
            for (index, var item) in leadStatus.enumerated() {
                switch item["key"] as? String {
                case "status_category":
                    item["text"] = buyLeadData["status_category"] as? String ?? ""
                case "status":
                    item["text"] = buyLeadData["status"] as? String ?? ""
                    self.subleads = (self.getsubleadstatus(leadState:buyLeadData["status"] as? String ?? ""))
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
            if let sectionIndex = valueArray.firstIndex(where: { ($0["main"] as? Bool) == true }) {
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
        DispatchQueue.main.async {
            // Reload the table view
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView DataSource
   
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return treeModel?.numberOfItemsInSection(section) ?? 0
      
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormCell", for: indexPath) as! OLXFormTableViewCell
        cell.delegate = self
        cell.setCellDataBasedOnIndexPath(indexPath, treeModel: treeModel!, view: view, tableView: tableView)
        return cell
    }
   
    // MARK: - TableView Headers (Expandable Sections)
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section][indexPath.row]
        if(item["isOpen"] as! Bool)
        {
            return 0
        }
        if(item["key"] as? String  == "Lead Classification" || item["key"] as? String  == "Lead Status" || item["key"] as? String  ==  "Note Against Status"){
         return 30
        }
        if(item["action"] as! String == "checkBox"){
            return 35
        }
        return 60
    }
   @objc func updatebuylead()
    {
        var visitedDate = ""
        var message = ""
        var parameters = [
                "status_date": "",
                "status": "",
                "substatus":"",
                "status_category": "",
                "customer_visited":"",
                "statustext": "",
                "buylead_id": UserDefaults.standard.value(forKey: "buylead_id")!,
                "action": "updatebuyleadstatus",
                "dealer_id": MyPodManager.user_id,
                "api_id":"cteolx2024v1.0", "device_id":Constant.uuid!] as! [String:Any]
        for (sectionIndex, title) in sectionTitles.enumerated() {
            print("Section \(sectionIndex): \(title)")
          
            if sectionIndex == 0 || sectionIndex == 2 {
                // Print plist data
                if let items = treeModel?.itemsInSection(sectionIndex) {
                    for item in items {
                        if let key = item["key"] as? String,
                           let text = item["text"] as? String {
                            print("  \(key): \(text)")
                         
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
                                    if(self.subleads.count != 0){
                                        message =  message.count == 0 ? "Lead SubStatus":"\(message)-Lead SubStatus"
                                    }
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
                                visitedDate = text
                            }
                            if(key == "customer_visited"){
                                if(visitedDate == "no"){
                                    
                                }
                                else{
                                    parameters["customer_visited"] = item["isOpen"] as! Bool ? "" : text
                                    if(text.count == 0){
                                    message =  message.count == 0 ? "Customer Visited Date" :"\(message)-Customer Visited Date"
                                    }
                                }
                            }
                            if(key == "statustext"){
                                if(text.count == 0)
                                {
                                    message =  message.count == 0 ?"Status Text":"\(message)-Status Text"
                                }
                                parameters["statustext"] = text
                            }
                            if(key == "Send Sms"){
                                self.sendsmsstatus = text == "yes" ? true : false
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
            let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
            let api = ApiServices()
            api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                switch result {
                case .success(let data):
                    print("Response Data: \(data)")
                    if(data["status"] as! String == "success"){
                        DispatchQueue.main.async {
                         if(self.sendsmsstatus){
                                self.sendSMS()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.view.showCustomAlert(image:"",
                                    title: "Update Successful",
                                    message: "BuyLead has been updated successfully",
                                    confirmTitle: "OK", // Optional, defaults to "OK"
                                    cancelTitle: "", // Optional, defaults to "CANCEL"
                                    confirmAction: {
                                        // Handle confirm action
                                        print("Confirmed")
                                        self.dismiss(animated: true)
                                        NotificationCenter.default.post(name:Notification.Name("refreshLeads"), object: nil)
                                    },
                                    cancelAction: {
                                        // Handle cancel action
                                        print("Cancelled")
                                    }
                                )
                             }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.customAlert(title: "Failed", message: (data["error"]! as! String).replacingOccurrences(of: "<br>", with: "\n"), confirmTitle: "OK", cancelTitle: "")
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    func sendSMS()
    {
        if let topVC = UIApplication.topViewController()
        {
            DispatchQueue.main.async {
                let popup = SendSMSPopupViewController()
                popup.items = self.items as! [String : Any]
                popup.modalPresentationStyle = .overCurrentContext
                popup.modalTransitionStyle = .crossDissolve
                topVC.present(popup, animated: true)
            }
        }
    }
    func customAlert(title: String, message: String, confirmTitle: String, cancelTitle: String)
    {
        self.view.showCustomAlert(image:"",
            title: title,
            message: message,
            confirmTitle: confirmTitle, // Optional, defaults to "OK"
            cancelTitle: cancelTitle, // Optional, defaults to "CANCEL"
            confirmAction: {
                // Handle confirm action
                print("Confirmed")
            },
            cancelAction: {
                // Handle cancel action
                print("Cancelled")
            }
        )
    }
}
extension BuyLeadStatus_update: CTEFormTableViewCellDelegate {
    
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
        print("Text field changed: \(textField.text ?? "")")
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
