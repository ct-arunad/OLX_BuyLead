//
//  OLXFormTableViewCell.swift
//  OLX_BuyLeads
//
//  Created by Chandini on 30/04/25.
//

import UIKit
protocol CTEFormTableViewCellDelegate: AnyObject {
    func didSelectButton(_ button: UIButton)
    func didUpdateTextField(_ textField: UITextField)
    func selectedCheckBox(_ button: UIButton)
}
class OLXFormTableViewCell: UITableViewCell {

    // MARK: - Properties
    weak var delegate: CTEFormTableViewCellDelegate?
    private var currentItem: [String: Any] = [:]
    private var tapGesture: UITapGestureRecognizer?
    var itemsArray: [[String: Any]] = []
    private var apiResponse: [String: Any] = [:]
    var visibleStackView = UIStackView()
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.cornerRadius = 4
        view.backgroundColor = .cellbg
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont(.regular, size: 14)
        label.textColor = .gray
        label.backgroundColor = .clear
        return label
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = .appFont(.regular, size: 14)
        field.borderStyle = .none
        field.clearButtonMode = .whileEditing
        return field
    }()
    
    private let selectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.tintColor = .systemGray
        button.titleLabel?.font = .appFont(.regular, size: 14)
        return button
    }()
    
    private let dropdownIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let datePickerIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    private let mandatoryIndicator: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "*"
        label.textColor = .red
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.named("uncheck"), for: .normal)
        button.setImage(UIImage.named("check"), for: .selected)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        return button
    }()
    
    private let checkboxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont(.regular, size: 14)
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        visibleStackView = UIStackView(arrangedSubviews: [checkboxButton,checkboxLabel])
        visibleStackView.axis = .horizontal
        visibleStackView.alignment = .center
        visibleStackView.distribution = .fillProportionally
        visibleStackView.spacing = 8
        visibleStackView.translatesAutoresizingMaskIntoConstraints = false
   
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(selectionButton)
        containerView.addSubview(dropdownIcon)
        containerView.addSubview(datePickerIcon)
        containerView.addSubview(visibleStackView)
//        containerView.addSubview(checkboxButton)
        contentView.addSubview(mandatoryIndicator)
//        checkboxButton.isHidden = true
//        checkboxLabel.isHidden = true

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -7),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            
            mandatoryIndicator.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            mandatoryIndicator.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            visibleStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            visibleStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            visibleStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
          //  checkboxButton.heightAnchor.constraint(equalToConstant: 30),
           // checkboxButton.widthAnchor.constraint(equalToConstant: 30),
            
//            checkboxLabel.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
//            checkboxLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8),
//            checkboxLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            selectionButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            selectionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            selectionButton.trailingAnchor.constraint(equalTo: dropdownIcon.leadingAnchor, constant: -8),
            selectionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            dropdownIcon.centerYAnchor.constraint(equalTo: selectionButton.centerYAnchor),
            dropdownIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            dropdownIcon.widthAnchor.constraint(equalToConstant: 15),
            dropdownIcon.heightAnchor.constraint(equalToConstant: 15),
            
            datePickerIcon.centerYAnchor.constraint(equalTo: selectionButton.centerYAnchor),
            datePickerIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            datePickerIcon.widthAnchor.constraint(equalToConstant: 20),
            datePickerIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        selectionButton.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Public Methods
    func configure(with item: [String: Any]) {
        currentItem = item
        let key = item["key"] as? String ?? ""
        var text = item["text"] as? String ?? ""
        let placeholder = item["placeholder"] as? String ?? ""
        
        // Check if we have a value from the API response
        if let apiValue = apiResponse[key] as? String {
            text = apiValue
            // Update the item with API value
            var updatedItem = item
            updatedItem["text"] = text
            currentItem = updatedItem
        }
        
        titleLabel.text = key
        textField.placeholder = placeholder
        textField.text = text
        
        // Show/hide title label and mandatory indicator based on text
        let hasText = !text.isEmpty
        titleLabel.isHidden = true
        mandatoryIndicator.isHidden = true
        
        if let type = item["type"] as? String {
            switch type {
            case "textField":
                configureTextField(item)
            case "button":
                configureButton(item)
            case "datePicker":
                configureDatePicker(item)
            case "label":
                configureCheckbox(item)
            default:
                break
            }
        }
    }
    
    private func getItemBasedOnKey(_ key: String) -> [String: Any]? {
        return itemsArray.first { ($0["key"] as? String) == key }
    }
    
    func setCellDataBasedOnIndexPath(_ indexPath: IndexPath, treeModel: TreeListModel, view: UIView, tableView: UITableView) {
        guard let item = treeModel.itemForRowAtIndexPath(indexPath) else {
            print("No item found for indexPath: \(indexPath)")
            return
        }
        
        // Get the local item from itemsArray if it exists
        let localItem = getItemBasedOnKey(item["key"] as? String ?? "")
        
        // Configure the cell with the appropriate item
        if let localItem = localItem, localItem["key"] as? String == item["key"] as? String {
            configure(with: localItem)
        } else {
            configure(with: item as! [String : Any])
        }
    }
    
    // MARK: - Private Methods
    private func configureTextField(_ item: [String: Any]) {
        textField.isHidden = false
        selectionButton.isHidden = true
        dropdownIcon.isHidden = true
        datePickerIcon.isHidden = true
//        checkboxButton.isHidden = true
//        checkboxLabel.isHidden = true
        visibleStackView.isHidden = true
        containerView.backgroundColor = .cellbg
        
        if let keyboard = item["keyboard"] as? String, keyboard == "number" {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .default
        }
        
    }
    
    private func configureButton(_ item: [String: Any]) {
        textField.isHidden = true
        selectionButton.isHidden = false
        dropdownIcon.isHidden = false
        datePickerIcon.isHidden = true
        
        visibleStackView.isHidden = true

        
        let text = item["text"] as? String ?? ""
        let placeholder = item["placeholder"] as? String ?? ""
        let displayText = text.isEmpty ? placeholder : text
        selectionButton.setTitle(displayText, for: .normal)
        selectionButton.setImage(UIImage.named(""), for: .normal)
        dropdownIcon.image = UIImage.named("downarrow")?.withRenderingMode(.alwaysTemplate)
        if(item["isOpen"] as! Bool)
        {
            dropdownIcon.isHidden = true
            containerView.backgroundColor = .clear
            containerView.layer.borderWidth = 0
            selectionButton.isHidden = true
        }
        else{
            containerView.backgroundColor = .cellbg
            containerView.layer.borderWidth = 1
            dropdownIcon.isHidden = false
            selectionButton.isHidden = false
        }
    }
    private func configureDatePicker(_ item: [String: Any]) {
        textField.isHidden = true
        selectionButton.isHidden = false
        dropdownIcon.isHidden = true
        datePickerIcon.isHidden = true
        visibleStackView.isHidden = true

        let text = item["text"] as? String ?? ""
        let placeholder = item["placeholder"] as? String ?? ""
        let displayText = text.isEmpty ? placeholder : text
        selectionButton.setTitle(displayText, for: .normal)
      //  datePickerIcon.image = UIImage.named("calendar")?.withRenderingMode(.alwaysTemplate)
        selectionButton.setImage(UIImage.named("calendar"), for: .normal)

        if(item["isOpen"] as! Bool)
        {
            selectionButton.isHidden = true
            containerView.backgroundColor = .clear
            containerView.layer.borderWidth = 0
        }
        else{
            containerView.backgroundColor = .cellbg
            containerView.layer.borderWidth = 1
        }
    }
    
    private func configureCheckbox(_ item: [String: Any]) {
        textField.isHidden = true
        selectionButton.isHidden = true
        dropdownIcon.isHidden = true
        datePickerIcon.isHidden = true
        titleLabel.isHidden = true
        visibleStackView.isHidden = false
        checkboxLabel.text = item["key"] as? String ?? ""
        // Set checkbox state if available
        if let text = item["text"] as? String {
            checkboxButton.isSelected = text.lowercased() == "yes"
        }
            if(item["key"] as? String  == "Lead Classification" || item["key"] as? String  == "Lead Status" || item["key"] as? String  ==  "Note Against Status"){
                checkboxButton.isHidden = true
            }
            else{
                checkboxButton.isHidden = false
            }
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 0
    }
    
    // MARK: - Actions
    @objc private func selectionButtonTapped(_ sender: UIButton) {
        delegate?.didSelectButton(sender)
        setupTapGesture()
    }
    
    @objc private func checkboxTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.selectedCheckBox(sender)
    }
    
    private func setupTapGesture() {
        // Remove existing tap gesture if any
        if let existingGesture = tapGesture {
            UIApplication.shared.windows.first?.removeGestureRecognizer(existingGesture)
            tapGesture = nil
        }
        
        // Add new tap gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        gesture.cancelsTouchesInView = false
        UIApplication.shared.windows.first?.addGestureRecognizer(gesture)
        tapGesture = gesture
    }
    
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        guard let window = UIApplication.shared.windows.first else { return }
        
        let cellFrame = convert(bounds, to: window)
        let tapPoint = gesture.location(in: window)
        
        if !cellFrame.contains(tapPoint) {
            window.removeGestureRecognizer(gesture)
            tapGesture = nil
            delegate?.didSelectButton(selectionButton)
        }
    }
    
    @objc private func textFieldDidChange(_ sender: UITextField) {
        let hasText = !(sender.text?.isEmpty ?? true)
        titleLabel.isHidden = true
        mandatoryIndicator.isHidden = true
       // containerView.layer.borderColor = hasText ? UIColor.systemGray4.cgColor : UIColor.systemGray4.cgColor
        delegate?.didUpdateTextField(sender)
    }
    
    // MARK: - Cleanup
    override func prepareForReuse() {
        super.prepareForReuse()
        if let gesture = tapGesture {
            UIApplication.shared.windows.first?.removeGestureRecognizer(gesture)
            tapGesture = nil
        }
    }
    
    // MARK: - API Response
    func fillWithAPIResponse(_ response: [String: Any]) {
        apiResponse = response
        // If the cell is already configured, update it with the API data
        if !currentItem.isEmpty {
            configure(with: currentItem)
        }
    }

}
