import UIKit
import MessageUI


class SendSMSPopupViewController: UIViewController,MFMessageComposeViewControllerDelegate, StockTableViewDelegate {
    func didSelectStock(_ name: String, addID: String) {
                self.inventoryid = addID
                print("Selected item: \(name)")
                self.inventoryButton.setTitle(" \(name)", for: .normal)
                    if(templateTextField.titleLabel?.text == " Appointment fixed"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), Thank you for contacting us. Your appointment for \(name) has been fixed. Our address is \(self.dealerinfo?.address ?? "") \r\nFor any queries, please call. \(self.dealerinfo?.name ?? "")-\(self.dealerinfo?.mobile ?? "")."
                       }
                    if(templateTextField.titleLabel?.text == " Uncontactable"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), we tried to reach you for your enquiry about our \(name). We would be happy to help you in your car buying process. Please feel free to call for any assistance. \nRegards, \(self.dealerinfo?.name ?? "")-\(self.dealerinfo?.mobile ?? "")"
                      }
    }
    

    
    public var items = [String:Any]()

    // MARK: - UI Elements
    private let popupView = UIView()
    private let iconImageView = UIImageView(image: UIImage(systemName: "message"))
    private let templetIconImageView = UIImageView(image: UIImage(systemName: "downarrow"))
    private let inventoryIconImageView = UIImageView(image: UIImage(systemName: "downarrow"))

    private let titleLabel = UILabel()
    private let contactLabel = UILabel()
    private let templatePicker = UIPickerView()
    private let templateTextField = UIButton()
    private let inventoryButton = UIButton()

    private let messageTextView = UITextView()
    private let cancelButton = UIButton(type: .system)
    private let sendButton = UIButton(type: .system)


    private let templates = ["Appointment Reminder", "Thank You", "Custom Message"]
    var dropdown: DropdownView?
    var inventoryheight = 0
   var inventoryButtonHeightConstraint =  NSLayoutConstraint()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    var dealerinfo : DealerInfo?
    var inventoryid =  ""
    let messageVC = MFMessageComposeViewController()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dropdown?.removeFromSuperview()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // Create 'Done' button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]

        // Assign toolbar to inputAccessoryView
        messageTextView.inputAccessoryView = toolbar
        
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        
        inventoryIconImageView.tintColor = .systemBlue
        inventoryIconImageView.contentMode = .scaleAspectFit
        popupView.addSubview(inventoryIconImageView)
        
        
        templetIconImageView.tintColor = .systemBlue
        templetIconImageView.contentMode = .scaleAspectFit
        popupView.addSubview(templetIconImageView)
        
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        popupView.addSubview(iconImageView)

        titleLabel.text = "Send SMS"
        titleLabel.font = .appFont(.bold, size: 16)
        popupView.addSubview(titleLabel)

        
        if let name = items["contact_name"] as? String,
           let mobile = items["mobile"] as? String {
            contactLabel.text = "\(name) (\(mobile))"
        }
        contactLabel.font = .appFont(.regular, size: 16)
        contactLabel.textColor = .black
        popupView.addSubview(contactLabel)

        
        
        templateTextField.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
        templateTextField.setTitle(" Select Message Template", for: .normal)
        templateTextField.setTitleColor(.black, for: .normal)
        templateTextField.layer.cornerRadius = 5
        templateTextField.titleLabel?.font = .appFont(.regular, size: 12)
        popupView.addSubview(templateTextField)
        templateTextField.contentHorizontalAlignment = .leading
        templateTextField.backgroundColor = .sendsms
   

     
        
        inventoryButton.addTarget(self, action: #selector(showinventoryView), for: .touchUpInside)
        inventoryButton.setTitleColor(.black, for: .normal)
        inventoryButton.setTitle(" Select Inventory", for: .normal)
        inventoryButton.layer.cornerRadius = 5
        inventoryButton.titleLabel?.font = .appFont(.regular, size: 12)
        popupView.addSubview(inventoryButton)
        inventoryButton.contentHorizontalAlignment = .leading
     
        
        inventoryButton.backgroundColor =  .sendsms
        
        inventoryButtonHeightConstraint = inventoryButton.heightAnchor.constraint(equalToConstant: 0)
        inventoryButtonHeightConstraint.isActive = true
        inventoryButton.isHidden = true
     
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
     //   messageTextView.layer.borderWidth = 1
        messageTextView.layer.cornerRadius = 3
        messageTextView.backgroundColor =  .sendsms
        popupView.addSubview(messageTextView)
        messageTextView.font = .appFont(.regular, size: 13)

        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.borderColor =  UIColor(red: 23.0/255.0, green: 73.0/255.0, blue: 152.0/255.0, alpha: 1.0).cgColor
        cancelButton.setTitleColor(.appPrimary, for: .normal)
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.cornerRadius = 5
        cancelButton.titleLabel?.font = .appFont(.bold, size: 14)

        cancelButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        popupView.addSubview(cancelButton)

        sendButton.setTitle("SEND", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = .appPrimary
        sendButton.layer.cornerRadius = 5
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        popupView.addSubview(sendButton)
        sendButton.titleLabel?.font = .appFont(.bold, size: 14)

        self.dealerinfo = loadUserFromFile()
    }
    
    
    func loadUserFromFile() -> DealerInfo? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user.json")
        if let data = try? Data(contentsOf: url) {
            return try? JSONDecoder().decode(DealerInfo.self, from: data)
        }
        return nil
    }
    @objc func toggleDropdown(sender : UIButton) {
        dropdown?.removeFromSuperview()
        let items = ["Appointment fixed","Blank","Booking","Customer Feedback","Thank you","Uncontactable","Visit"]
        let buttonFrame = sender.convert(sender.bounds, to: view)
        let dropdownHeight = min(CGFloat(items.count) * 44 + 40, 350)
        let dropdownFrame = CGRect(
            x: buttonFrame.minX,
            y: buttonFrame.maxY + 4,
            width: buttonFrame.width,
            height: dropdownHeight
        )
        dropdown = DropdownView(items: items,headertitle: "Select Lead Status", frame: dropdownFrame)
        dropdown?.onItemSelected = { selected in
            
            if(selected !=  "Select Lead Status"){
                self.inventoryButton.setTitle("Select Inventory", for: .normal)
                self.messageTextView.text = ""
                if(selected == "Appointment fixed" || selected == "Uncontactable"){
                    self.inventoryButtonHeightConstraint.constant = 40
                    self.inventoryButton.isHidden = false
                }
                else{
                    self.inventoryButtonHeightConstraint.constant = 0
                    self.inventoryButton.isHidden = true
                    if(selected == "Blank"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String)"
                    }
                    if(selected == "Booking"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), Thanks for your car booking at our showroom. Please feel free to call at any time. \nRegards,\n \(self.dealerinfo?.name ?? "")"
                    }
                    if(selected == "Customer Feedback"){
                        self.messageTextView.text = "Dear Customer,\n\nThank you for choosing \(self.dealerinfo?.name ?? ""). Please give your valuable feedback on https://www.olx.in/profile/\(MyPodManager.user_id)\n\nRegards,\n \(self.dealerinfo?.name ?? "")"
                    }
                    if(selected == "Thank you"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), Thank you for our phone call just now. Please feel free to call for any future assistance. \nRegards, \n \(self.dealerinfo?.name ?? "")"
                    }
                    if(selected == "Visit"){
                        self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), Thank you for visiting our showroom. We look forward to hearing from you soon. \nRegards,\n \(self.dealerinfo?.name ?? "")"
                    }
                }
            }
            sender.setTitle(" \(selected)", for: .normal)
          
        }
        if let dropdown = dropdown {
            view.addSubview(dropdown)
        }
       }
    private func setupLayout() {
        [iconImageView, titleLabel, contactLabel, templateTextField,templetIconImageView, inventoryButton,inventoryIconImageView, messageTextView, cancelButton, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            iconImageView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10),
            iconImageView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 5),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            

            contactLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contactLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10),

            
            templateTextField.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 20),
            templateTextField.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            templateTextField.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
            templateTextField.heightAnchor.constraint(equalToConstant: 40),
            


            inventoryButton.topAnchor.constraint(equalTo: templateTextField.bottomAnchor, constant: 10),
            inventoryButton.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            inventoryButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
//            inventoryButton.heightAnchor.constraint(equalToConstant: inventoryButtonHeightConstraint.constant),
            
        
            
            messageTextView.topAnchor.constraint(equalTo: inventoryButton.bottomAnchor, constant: 10),
            messageTextView.leadingAnchor.constraint(equalTo: templateTextField.leadingAnchor),
            messageTextView.trailingAnchor.constraint(equalTo: templateTextField.trailingAnchor),
            messageTextView.heightAnchor.constraint(equalToConstant: 100),

            cancelButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: messageTextView.leadingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -20),

            sendButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            sendButton.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor),
            sendButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            sendButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            sendButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 16)
        ])
        
        let imageView =  UIImageView(image:UIImage.named("downarrow"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        templateTextField.addSubview(imageView)
        // Layout image inside the button (e.g., center it)
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(equalTo: templateTextField.trailingAnchor,constant: -10),
            imageView.centerYAnchor.constraint(equalTo: templateTextField.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 15),
            imageView.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        let inventimageView =  UIImageView(image:UIImage.named("downarrow"))
        inventimageView.translatesAutoresizingMaskIntoConstraints = false
        inventimageView.backgroundColor = .clear
        inventoryButton.addSubview(inventimageView)
        // Layout image inside the button (e.g., center it)
        NSLayoutConstraint.activate([
            inventimageView.trailingAnchor.constraint(equalTo: inventoryButton.trailingAnchor,constant: -10),
            inventimageView.centerYAnchor.constraint(equalTo: inventoryButton.centerYAnchor),
            inventimageView.widthAnchor.constraint(equalToConstant: 15),
            inventimageView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    @objc func showinventoryView()
     {
         let inventoryVC = StockInventoryView()
         inventoryVC.delegate = self
         present(inventoryVC, animated: true)
     }
    @objc private func dismissPopup() {
        dismiss(animated: false, completion: nil)
    }

       // Required delegate method
       func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                         didFinishWith result: MessageComposeResult) {
           controller.dismiss(animated: true, completion: nil)
           self.dismiss(animated: false)
       }
    
    @objc private func sendMessage() {
        print("SMS Sent to: \(contactLabel.text ?? "")")
        
        guard let body = contactLabel.text, !body.isEmpty else {
            // Show alert
            return
        }
        if MFMessageComposeViewController.canSendText() {
            messageVC.messageComposeDelegate = self
            messageVC.recipients = ["\(self.items["mobile"] as! String)"] // Optional: phone number
            messageVC.body = messageTextView.text // Optional: message body
            present(messageVC, animated: true, completion: nil)
        } else {
            print("Device cannot send SMS.")
        }
    }
}
//extension SendSMSPopupViewController: StockTableViewDelegate {
//    func didSelectStock(_ name: String, addID: String) {
//        self.inventoryid = addID
//        print("Selected item: \(name)")
//        self.inventoryButton.setTitle(" \(name)", for: .normal)
//            if(templateTextField.titleLabel?.text == "Appointment fixed"){
//                self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), Thank you for contacting us. Your appointment for \(name) has been fixed. Our address is \(self.dealerinfo?.address ?? "") \r\nFor any queries, please call. \(self.dealerinfo?.name ?? "")-\(self.dealerinfo?.mobile ?? "")."
//               }
//            if(templateTextField.titleLabel?.text == "Uncontactable"){
//                self.messageTextView.text = "Dear \(self.items["contact_name"] as! String), we tried to reach you for your enquiry about our \(name). We would be happy to help you in your car buying process. Please feel free to call for any assistance. \nRegards, \(self.dealerinfo?.name ?? "")-\(self.dealerinfo?.mobile ?? "")"
//              }
//        }
//}
  

