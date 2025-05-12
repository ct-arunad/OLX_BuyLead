//
//  OnlineBuyLeads.swift
//  CTE_BuyLeads
//
//  Created by Aruna on 25/03/25.
//

import Foundation
import UIKit
import CallKit

struct DealerInfo: Codable {
    let id: String
    let name: String
    let email: String
    let mobile: String
    let address : String
}


public class OnlineBuyLeads: UIViewController,TableCellDelegate,collectionCellDelegate,UISearchBarDelegate,CXCallObserverDelegate {
   
   
    private let apiService = ApiServices()
    private var items = NSMutableArray()
    private let tableView = UITableView()
    private let searchtableView = UITableView()
    var selectionitems = NSDictionary()
    var selectionBuyLead = [String:Any]()
    var buylead_click_id = ""

    private var Buyleads = NSMutableArray()
    private var searchList = NSArray()

    private var data : [Any] = ["All","Hot","Inv Cars","Archive","Appointment Fixed"]
    private var apidata : [Any] = []
    var status = ""
    var searchtag = ""
    var searchkey = ""
    var spage = 0

    var inventoryId = ""
    var noleadView = UIView()
    let noLeadLabel = UILabel()
    public var refresh = UIButton()
    public var searchButton = UIButton()
    let searchBar = UISearchBar()
    var issearchenable = false
    let loadingView = LoadingView()
    var filterParams = [String:Any]()
    var callObserver: CXCallObserver?
    private let callQueue = DispatchQueue(label: "my.ios10.call.status.queue")

    @objc func appCameBackFromCall() {
        DispatchQueue.main.async {
            let popup = BuyLeadStatus_update()
            popup.items = self.selectionitems
            popup.modalPresentationStyle = .fullScreen
            self.present(popup, animated: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchBuyLeads), name: Notification.Name("refreshLeads"), object: nil)
        if let frameworkDefaults = UserDefaults(suiteName: "com.Samplepod.OLX-BuyLeads") {
            frameworkDefaults.removePersistentDomain(forName: "com.Samplepod.OLX-BuyLeads")
            frameworkDefaults.synchronize()
        }
        UserDefaults.standard.set("n", forKey: "show_archieve")
        UserDefaults.standard.set("n", forKey: "show_apptfixed")
        UserDefaults.standard.set("n", forKey: "hotleads")
     
        FontLoader.registerFonts()
        self.title = "Online Buy Leads"
        navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white, // Title text color
                .font: UIFont(name: "Roboto-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
            ]
    
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            // Now you can access the window
            print("Got the window: \(window)")
            if let statusBarFrame = window.windowScene?.statusBarManager?.statusBarFrame {
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.backgroundColor = .appPrimary
                window.addSubview(statusBarView)
            }
        }
        
        navigationController?.navigationBar.isTranslucent = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // or .configureWithTransparentBackground()
        appearance.backgroundColor = .appPrimary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 👈 Title color here
        appearance.shadowColor = .clear // 🔥 removes the bottom line

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .appPrimary
        view.backgroundColor = .white
        
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage.named("back_arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backBArButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBArButton
        
        
        searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage.named("search_white"), for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        navigationItem.rightBarButtonItem = searchBarButton
    
        setupTableView()
        setupSearchTableView()
       }

    //MARK : navigation titleview
       func setupSearchBar() {
           let bgView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
           bgView.backgroundColor = .white
           bgView.layer.cornerRadius = 8
           searchButton.isHidden = true
//           searchButton.removeTarget(self, action:  #selector(didTapSearchButton), for: .touchUpInside)
//           searchButton.addTarget(self, action: #selector(searchBuyLeads), for: .touchUpInside)
           searchBar.placeholder = "Search a name"
           searchBar.searchTextField.backgroundColor = .white
           searchBar.searchTextField.tintColor = .appPrimary
           searchBar.delegate = self

           // Set a fixed width
           let searchBarWidth = UIScreen.main.bounds.width - 40
           searchBar.frame = CGRect(x: 0, y: 0, width: searchBarWidth, height: 36)
           // Put it in the navigation bar
           navigationItem.titleView = searchBar
       }
      @objc private func didTapSearchButton() {
          self.searchBar.becomeFirstResponder()
          searchtableView.isHidden = false
          issearchenable = true
          searchtag = ""
          searchkey = ""
          setupSearchBar()
          self.searchList = []
          self.searchtableView.reloadData()
      }
      @objc func searchBuyLeads()
      {
          searchResults()
     }
       // MARK: - UISearchBarDelegate
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           searchtableView.isHidden = false
           print("Searching: \(searchText)")
           self.searchResults()
       }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
             searchBar.text = ""
            self.searchList = []
            self.searchtableView.reloadData()
       }
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    @objc func backButtonTapped()
    {
        if(issearchenable){
            self.searchtableView.isHidden = true
            self.searchtag = ""
            self.searchkey = ""
            issearchenable = false
            self.navigationItem.titleView = nil
            self.title = "Online Buy Leads"
            self.searchBar.text = ""
            self.searchBar.tintColor = .white
            self.searchBar.resignFirstResponder()
            self.fetchBuyLeads()
            searchButton.isHidden = false
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func searchResults()
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)"] as! [String:String]
        let parameters = [
            "action": "searchBuyleadSources",
            "api_id": "cteolx2024v1.0",
            "device_id": Constant.uuid ?? "",
            "key":self.searchBar.text ?? "",
              "dealer_id": MyPodManager.user_id,
        ] as! [String:Any]
        
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    if((data["status"] as! String == "success")){
                        if((data["status"] as! String == "success")){
                            if  let dic = data["data"] as? NSDictionary{
                                self.searchList = dic["searchResult"] as! NSArray
                                self.searchtableView.reloadData()
                            }
                        }
                    }
                    else{
                        print(data)
                        let dic = data
                        if(dic["error"] as! String == "INVALID_TOKEN")
                        {
                          //  self.refreshToken()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.loadingView.hide()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                }
            }
        }
    }
    
    func dealerDetails()
    {
        loadingView.show(in: self.view, withText: "Loading Dealer Details...")
        self.noleadView.isHidden = true

        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]

        let api = ApiServices()
        api.fetchdatawithGETAPI(headers: headers,url: "https://fcgapi.olx.in/dealer/users/me?id=\(MyPodManager.user_id)",authentication: "") { result in
            switch result {
            case .success(let data):
                print("Response Dealer Details: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    var fullAddress = ""
                        if  let dic = data["data"] as? NSDictionary{
                            if let addressDict = (dic["address"] as! NSArray).firstObject as? [String:Any] {
                                let street = addressDict["street_address"] as? String ?? ""
                                let city = addressDict["city"] as? String ?? ""
                                let state = addressDict["state"] as? String ?? ""
                                let postalCode = addressDict["postal_code"] as? Int ?? 0
                                let country = addressDict["country_code"] as? String ?? ""
                                fullAddress = [street, city, state, postalCode == 0 ? nil : "\(postalCode)", country]
                                    .compactMap { $0?.isEmpty == false ? $0 : nil }
                                    .joined(separator: ", ")
                                print("Full Address: \(fullAddress)")
                            }
                            self.saveUserToFile(DealerInfo(id: dic["id"] as! String, name: dic["name"]! as! String, email: dic["email"]! as! String, mobile: dic["phone"]! as! String, address: fullAddress))
                        }
                        else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                }
            }
        }
    }
    func saveUserToFile(_ user: DealerInfo) {
        if let data = try? JSONEncoder().encode(user) {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user.json")
            try? data.write(to: url)
        }
    }
    func stockFetchAPI()
    {
        loadingView.show(in: self.view, withText: "Loading Dealer Details...")
        self.noleadView.isHidden = true

        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]

        let api = ApiServices()
        api.fetchdatawithGETAPI(headers: headers,url: "https://fcgapi.olx.in/dealer/v1/users/\(MyPodManager.user_id)/ads?page=1&size=50",authentication: "") { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    if  let dic = data["data"] as? NSArray{
                        InventorySaveDataIntoDB.sharedInstance.saveStockTitles(dic as Any)
                        }
                        else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                }
            }
        }
    }
    func synchHomeAPI()
    {
        loadingView.show(in: self.view, withText: "Loading Authentiation...")
        self.noleadView.isHidden = true

        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)"] as! [String:String]
        
        let parameters = [
            "action": "homeapi",
            "api_id": "cteolx2024v1.0",
            "refresh_token":MyPodManager.refresh_token,
            "user_id":MyPodManager.user_id,
            "sync_time": UserDefaults.standard.value(forKey: "synchtime") ?? "",
            "system_info":"dflgjdflghdlfuhg",
            "device_id": Constant.uuid ?? ""
        ] as! [String:Any]
        
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    if  let dic = data["data"] as? NSDictionary{
                    if((data["status"] as! String == "success")){
                            UserDefaults.standard.set(dic["sync_time"], forKey: "synchtime")
                            self.fetchBuyLeads()
                            self.dealerDetails()
                            if(dic["sync_done"] as! String == "n"){
                                self.loadCities()
                                self.loadInventory()
                            }
                            else{
                            }
                        }
                        else{
                            print(data)
                            let dic = data
//                            self.customAlert(title: "Error", message: data["error"] as! String, confirmTitle: "OK", cancelTitle: "")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                    }
                    else{
                        print(data)
                        let dic = data
                        if(dic["error"] as! String == "INVALID_TOKEN")
                        {
                           // self.refreshToken()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.loadingView.hide()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.view.showCustomAlert(image:"",
                        title: "Error",
                        message: error.localizedDescription,
                        confirmTitle: "OK", // Optional, defaults to "OK"
                        cancelTitle: "", // Optional, defaults to "CANCEL"
                        confirmAction: {
                            print("Confirmed")
                            self.navigationController?.popViewController(animated: true)
                        },
                        cancelAction: {
                            print("Cancelled")
                        }
                    )
                   // self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                }
            }
        }
    }

    
      func loadInventory()
      {
          let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
          let parameters = [
              "action": "loadbuyleadstatus",
              "api_id": "cteolx2024v1.0",
              "dealer_id":MyPodManager.user_id,
              "device_id":Constant.uuid!,
          ] as! [String:Any]
          
          let api = ApiServices()
          api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
              switch result {
              case .success(let data):
                  print("Response Data: \(data)")
                  DispatchQueue.main.async {
                      if  let dic = data["data"] as? NSDictionary{
                          InventorySaveDataIntoDB.sharedInstance.saveleadsandsubleadsIntoDB(response: dic)
                      }
                  }
              case .failure(let error):
                  print("Error: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.loadingView.hide()

                      self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                  }
              }
          }
      }
    func loadCities()
    {
        loadingView.show(in: self.view, withText: "Loading Cities...")
        self.noleadView.isHidden = true
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        let parameters = [
            "action":"loadcities",
               "device_id":Constant.uuid!,
               "dealer_id":MyPodManager.user_id,
               "api_id": "cteolx2024v1.0"
        ] as! [String:Any]
        
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    if  let dic = data["data"] as? NSDictionary{
                        InventorySaveDataIntoDB.sharedInstance.saveStatesandcitiesIntoDB(response: dic)
                    }
                    else{
                        print(data)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.loadingView.hide()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                }
            }
        }
    }
    func loadModels()
    {
        loadingView.show(in: self.view, withText: "Loading Models...")
        self.noleadView.isHidden = true
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]

        let parameters = [
            "action":"loadmodels",
                "device_id":Constant.uuid!,
            "dealer_id":MyPodManager.user_id,
                "api_id": "cteolx2024v1.0"
        ] as! [String:Any]
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
                print("Response Data: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    if  let dic = data["data"] as? NSDictionary{
                        InventorySaveDataIntoDB.sharedInstance.saveMakesModelsAndVariantsIntoDB(response: dic)
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.loadingView.hide()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                }
            }
        }
    }
   @objc func fetchBuyLeads()
    {
        loadingView.show(in: self.view, withText: "Loading Leads...")
        self.noleadView.isHidden = true
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        // "spage" : self.spage
        let parameters = [ "action":"loadallbuylead",
                           "api_id": "cteolx2024v1.0",
                           "device_id":Constant.uuid!,
                           "dealer_id":MyPodManager.user_id,
                           "status_filters":self.status.replacingOccurrences(of: " ", with: "_"),
                           "car_inventory_id":self.inventoryId,
                           "show_apptfixed": UserDefaults.standard.value(forKey: "show_apptfixed") ?? "n",
                           "hotleads": UserDefaults.standard.value(forKey: "hotleads") ?? "n",
                           "show_archieve":UserDefaults.standard.value(forKey: "show_archieve") ?? "n",
                           "app_type":"olx",
                           "search_key":self.searchkey,
                           "search_tag":self.searchtag,
                           "android_version":"15"
                          ] as! [String:Any]
        let api = ApiServices()
        api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
            switch result {
            case .success(let data):
              //  print("Response Data: \(data)")
                DispatchQueue.main.async {
                    self.loadingView.hide()
                    if  let dic = data["data"] as? NSDictionary{
                        guard  let result = dic["buyleads"] as? NSDictionary else {
                            return
                           }
//                        if let buyleadsArray = result["buylead"] as? NSArray {
//                            for item in buyleadsArray {
//                                if item is [String: Any]{
//                                    if(self.Buyleads.contains(item)){
//                                    }
//                                    else{
//                                        self.Buyleads.add(item)
//                                    }
//                                }
//                            }
//                        }
                         //  self.Buyleads.append(result["buylead"] as! NSArray)
                        self.Buyleads = (result["buylead"] as! NSArray).mutableCopy() as! NSMutableArray
                           let pagination = result["pagination"] as! NSDictionary
                            self.spage = pagination["next"] as! Int
                            self.apidata = (result["status_count"] as! NSArray) as! [Any]
                            var statusString = (self.data[0] as! String).replacingOccurrences(of: "[^a-zA-Z\\s]", with: "", options: .regularExpression)
                            statusString = statusString.replacingOccurrences(of: " ", with: "")
                            self.data[0] = "\(statusString) (\(self.Buyleads.count))"
                            self.tableView.reloadData()
                           if(self.Buyleads.count == 0){
                            self.noleadView.isHidden = false
                           }else{
                            self.noleadView.isHidden = true
                           }
                    }
                    else{
                        print(data)
                        let dic = data
                        if(dic["error"] as! String == "INVALID_TOKEN")
                        {
                         //   self.refreshToken()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.loadingView.hide()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                 //   self.loadingView.hide()
            //self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                        self.loadingView.hide()
                        self.view.showCustomAlert(image:"",
                            title: "Error",
                            message: error.localizedDescription,
                            confirmTitle: "OK", // Optional, defaults to "OK"
                            cancelTitle: "", // Optional, defaults to "CANCEL"
                            confirmAction: {
                                print("Confirmed")
                                self.navigationController?.popViewController(animated: true)
                            },
                            cancelAction: {
                                print("Cancelled")
                            }
                        )
                       // self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                }
            }
        }
    }
 
  
    @objc func retryNetworkRequest() {
          print("Retry button tapped! Retry network request here.")
           self.navigationController?.popViewController(animated: true)
      }
    
    private func setupSearchTableView(){
        searchtableView.backgroundColor = .cellbg
        view.addSubview(searchtableView)
        searchtableView.translatesAutoresizingMaskIntoConstraints = false
        searchtableView.rowHeight = UITableView.automaticDimension
        searchtableView.estimatedRowHeight = 60
     
        NSLayoutConstraint.activate([
            searchtableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchtableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchtableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchtableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        searchtableView.separatorColor = .none
        searchtableView.separatorStyle = .none
        searchtableView.delegate = self
        searchtableView.dataSource = self
        if #available(iOS 15.0, *) {
            searchtableView.sectionHeaderTopPadding = 5
        }
        searchtableView.register(VehicleinfoCell.self, forCellReuseIdentifier: "VehicleinfoCell")
        searchtableView.isHidden = true
    }
    private func setupTableView() {
        
        tableView.backgroundColor = .cellbg
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
     
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.separatorColor = .none
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 5
        }
        tableView.register(OnlineBuyLeads_cell.self, forCellReuseIdentifier: "CustomCell")
        tableView.register(OnlineBuyLeads_collection.self, forCellReuseIdentifier: OnlineBuyLeads_collection.identifier)
      //  tableView.register(LeadTableViewCell.self, forCellReuseIdentifier: "LeadCell")
        
        noleadView.backgroundColor = .clear
        // Add the view to the parent view
        view.addSubview(noleadView)

        // Enable Auto Layout
        noleadView.translatesAutoresizingMaskIntoConstraints = false
        noleadView.layer.cornerRadius = 5
        self.view.addSubview(noleadView)
        self.view.bringSubviewToFront(noleadView)

        // Center the view horizontally and vertically
        NSLayoutConstraint.activate([
            noleadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noleadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noleadView.widthAnchor.constraint(equalToConstant: 150), // Example width
            noleadView.heightAnchor.constraint(equalToConstant: 80) // Example height
        ])
        
           
        noLeadLabel.text = "No Leads Found"
        noLeadLabel.textColor = .lightGray
        noLeadLabel.backgroundColor = .clear
        
        refresh.backgroundColor = UIColor.OLXBlueColor
        refresh.setTitle("Refresh", for: .normal)
        refresh.addTarget(self, action: #selector(fetchBuyLeads), for: .touchUpInside)
        refresh.layer.cornerRadius = 5.0
        
        
        
        let stackView = UIStackView(arrangedSubviews: [noLeadLabel,refresh])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        noleadView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: noleadView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: noleadView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: noleadView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: noleadView.bottomAnchor, constant: -10)
        ])
        stackView.layer.cornerRadius = 10
        stackView.layer.masksToBounds = true
      
        self.synchHomeAPI()
        print(getStockList())
        if(getStockList().count != 0){
            
        }
        else{
            self.stockFetchAPI()
        }
      //  print(view.constraints)
    }
    public func getStockList()->[Ads]{
        return InventoryAPIManager.sharedInstance.getStocks() as! [Ads]
    }
    
  
}
extension OnlineBuyLeads: FilterPopupTableViewDelegate {
    public func didSelectItemFromAll(_ item: String) {
        print("Selected item: \(item)")
        self.status = item.lowercased()
        self.data[0] = item
        self.fetchBuyLeads()
    }
}
extension OnlineBuyLeads: InventoryTableViewDelegate {
    public func didSelectInventory(_ item: String) {
        print("Selected item: \(item)")
        if(self.inventoryId == ""){
            self.inventoryId = item
        }
        else{
            self.inventoryId = ""
        }
        self.fetchBuyLeads()
    }
}
// MARK: - UITableViewDelegate & DataSource

extension OnlineBuyLeads: UITableViewDelegate, UITableViewDataSource {
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 2 {
            if(self.spage  != 0){
           //     self.fetchBuyLeads()
            }
        }
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0)
        {
            return 0
        }
        return 35
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .black
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 30))
        let statusString = (self.data[0] as! String).replacingOccurrences(of: "[^a-zA-Z\\s]", with: "", options: .regularExpression)
        titleLabel.text = statusString.uppercased()
        titleLabel.textColor = .white
        titleLabel.font = .appFont(.bold, size: 14)
        headerView.addSubview(titleLabel)
        return headerView
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == searchtableView){
            return UITableView.automaticDimension
        }
        if(indexPath.section == 0){
            return 70
        }
        return UITableView.automaticDimension
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == searchtableView){
            return searchList.count
        }
        if(section == 0){
            return 1
        }
        return Buyleads.count
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == searchtableView){
            return 1
        }
        return 2
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == searchtableView){
                let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleinfoCell", for: indexPath) as! VehicleinfoCell
                let dic = searchList[indexPath.row] as! NSDictionary
                cell.label.text = (dic["value"] as! String)
                cell.deleteBtn.setTitle(" \(dic["tag"] as! String) ", for: .normal)
                cell.deleteBtn.layer.borderColor = UIColor(red: 23.0/255.0, green: 73.0/255.0, blue: 152.0/255.0, alpha: 1.0).cgColor
                cell.deleteBtn.layer.borderWidth = 1
                cell.deleteBtn.layer.cornerRadius = 5
                cell.deleteBtn.titleLabel?.font = .appFont(.regular, size: 10)
                cell.deleteBtn.setTitleColor(.appPrimary, for: .normal)
                cell.deleteBtn.setImage(UIImage.named(""), for: .normal)
                cell.deleteBtn.isHidden = false
                cell.selectionStyle = .none
                return cell
        }
        if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! OnlineBuyLeads_cell
            let response = Buyleads[indexPath.row] as! NSDictionary
            let cars = response["cars"] as! NSArray
            var make = ""
            for name in cars {
                let car = name as! NSDictionary
                if(make.count == 0){
                    make = "\(car["make"] as! String)"
                }
                else{
                    make = "\(make)\n\(car["make"] as! String)"
                }
            }
            cell.collectionView.tag = indexPath.row
            cell.configure(name: response["contact_name"]! as! String, status: response["status_text"]! as! String, date: make, cars: cars as! [Any],phonenumber: response["mobile"]! as! String)
            
            //change status category backgourd based on category
            cell.status_category.setTitle(" \((response["status_category"]! as! String)) ", for: .normal)
            cell.status_category.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            cell.status_category.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.status_category.titleLabel?.minimumScaleFactor = 0.8
            
            if let original = UIImage(named: "tag", in: .module, compatibleWith: nil) {
                    if((response["status_category"]! as! String).count == 0){
                        cell.status_category.isHidden = true
                    }else{
                        cell.status_category.isHidden = false
                        if((response["status_category"]! as! String) == "HOT" || (response["status_category"]! as! String) == "VERY HOT"){
                            let tinted = original.tinted(with: .systemRed)
                            cell.status_category.setBackgroundImage(tinted, for: .normal)
                        }
                        else if((response["status_category"]! as! String) == "COLD"){
                            let tinted = original.tinted(with: .appPrimary)
                            cell.status_category.setBackgroundImage(tinted, for: .normal)
                        }
                        else{
                            let tinted = original.tinted(with: .systemOrange)
                            cell.status_category.setBackgroundImage(tinted, for: .normal)
                        }
                    }
            }
            cell.delegate = self
            if((response["customer_visited"]! as! String).count != 0){
                cell.visitedLabel.isHidden = false
            }
            else{
                cell.visitedLabel.isHidden = true
            }
            cell.visitedLabel.tag = indexPath.row
            
            //show visiting popup
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(visitingStatus))
            cell.visitedLabel.addGestureRecognizer(tapGesture)
            cell.visitedLabel.isUserInteractionEnabled = true
            cell.contentView.backgroundColor = .cellbg
            
            //navigate to chat screen from SDK to OLX App
            cell.chatBtn.isUserInteractionEnabled = true
            cell.chatBtn.tag =  indexPath.row
            let chatGesture = UITapGestureRecognizer(target: self, action: #selector(navigateToHostVC))
            cell.chatBtn.addGestureRecognizer(chatGesture)
            
            //make a call
            cell.nameLabel.tag = indexPath.row
            let callGesture = UITapGestureRecognizer(target: self, action: #selector(calltoBuyLead))
            cell.nameLabel.addGestureRecognizer(callGesture)
            cell.nameLabel.isUserInteractionEnabled = true
            
            //delete Dealer
            
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(deleteBuyLead), for: .touchUpInside)
            
            //update BuyLead
            cell.editBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: #selector(editBuylead), for: .touchUpInside)
            
            //resore action
            cell.restoreBtn.tag = indexPath.row
            cell.restoreBtn.addTarget(self, action: #selector(restroreBuyLead), for: .touchUpInside)
            
            DispatchQueue.main.async {
                  cell.updateCollectionViewHeight()
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
              }
          
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: OnlineBuyLeads_collection.identifier, for: indexPath) as! OnlineBuyLeads_collection
            cell.delegate = self
            cell.configure(with: data)  // Pass data to cell
            cell.contentView.backgroundColor = .cellbg
            return cell
        }
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(issearchenable){
            if(tableView == searchtableView){
                self.searchBar.resignFirstResponder()
                searchtableView.isHidden = true
                let dic = searchList[indexPath.row] as! NSDictionary
                searchtag = (dic["tag"] as! String)
                if(dic["tag"] as? String == "inventory"){
                    searchkey = "\((dic["id"] as! CVarArg))"
                }
                else{
                    searchkey = (dic["value"] as! String)
                    searchkey = (dic["value"] as! String)
                }
                fetchBuyLeads()
            }
        }
    }
    @objc func restroreBuyLead(sender : UIButton){
        self.view.showCustomAlert(image: "restore",
            title: "Restore Lead",
            message: "Do you want to restore this lead?",
            confirmTitle: "Ok", // Optional, defaults to "OK"
            cancelTitle: "CANCEL", // Optional, defaults to "CANCEL"
            confirmAction: {
                print("Ok")
            let response = self.Buyleads[sender.tag] as! NSDictionary
               self.loadingView.show(in: self.view, withText: "Restore Lead...")
                 self.noleadView.isHidden = true
                 let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
                 
                 let parameters = [ "action":"restorebuylead",
                                    "api_id": "cteolx2024v1.0",
                                    "device_id":Constant.uuid!,
                                    "dealer_id":MyPodManager.user_id,
                                    "buylead_id": response["buylead_id"] ?? ""
                                   ] as! [String:Any]
                 let api = ApiServices()
                 api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                     switch result {
                     case .success(let data):
                         print("Response Data: \(data)")
                         DispatchQueue.main.async {
                             self.loadingView.hide()
                             if  let dic = data["data"] as? NSDictionary{
                                 if(data["status"] as! String == "success"){
                                     if  let dic = data["data"] as? NSDictionary{
                                         self.customAlert(title: "Success", message: dic["message"]! as! String, confirmTitle: "OK", cancelTitle: "")
                                         self.fetchBuyLeads()
                                     }
                                 }
                                 else{
                                     self.customAlert(title: "Failed", message: data["error"]! as! String, confirmTitle: "OK", cancelTitle: "")
                                 }
                             }
                             else{
                                 print(data)
                                 let dic = data
                                 if(dic["error"] as! String == "INVALID_TOKEN")
                                 {
                                    // self.refreshToken()
                                 }
                                 else{
                                     if(data["status"] as! String == "success"){
                                         if  let dic = data["data"] as? NSDictionary{
                                             self.customAlert(title: "Success", message: dic["message"]! as! String, confirmTitle: "OK", cancelTitle: "")
                                         }
                                     }
                                     else{
                                         self.customAlert(title: "Failed", message: data["error"]! as! String, confirmTitle: "OK", cancelTitle: "")
                                     }
                                 }
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                     self.loadingView.hide()
                                 }
                             }
                            
                         }
                     case .failure(let error):
                         print("Error: \(error.localizedDescription)")
                         DispatchQueue.main.async {
                             self.loadingView.hide()
                             self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                         }
                     }
                 }
            },
            cancelAction: {
                print("Cancelled")
            }
        )
    }
    @objc func selectedCellitem(item: Int)
    {
        if(item == 0){
            let popupVC = FilterTableViewController()
            popupVC.configure(with: self.apidata)
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.delegate = self
            present(popupVC, animated: true)
        }
        else{
            if(item == 2){
                let inventoryVC = LoadInventoryView()
                inventoryVC.delegate = self
                present(inventoryVC, animated: true)
            }
            else{
                self.fetchBuyLeads()
            }
        }
    }
    @objc func deselectedCellitem(item: Int)
    {
        if(item == 2){
            self.inventoryId = ""
            self.fetchBuyLeads()
        }
        else{
            self.fetchBuyLeads()
        }
    }
    //Delete BuyLead
    @objc func deleteBuyLead(sender : UIButton)
    {
        let response =  Buyleads[sender.tag] as! [String : Any]
        self.view.showCustomAlert(image: "delete_alert",
            title: "Delete Lead",
            message: "Do you want to delete this Lead?",
            confirmTitle: "DELETE", // Optional, defaults to "OK"
            cancelTitle: "CANCEL", // Optional, defaults to "CANCEL"
            confirmAction: {
                print("Deleted")
            self.deleteDealer(dealer_id: response["buylead_id"] as! String,tag: sender.tag)
            },
            cancelAction: {
                print("Cancelled")
            }
        )
    }
    
    func deleteDealer(dealer_id : String,tag : Int)
    {
        let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
            let parameters = [
                               "api_id":"cteolx2024v1.0",
                                 "device_id":Constant.uuid!,
                                 "action":"archivebuylead",
                                 "buylead_id":dealer_id,
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
                                if  let dic = data["data"] as? NSDictionary{
                                    self.customAlert(title: "Success", message: dic["message"]! as! String, confirmTitle: "OK", cancelTitle: "")
                                    self.Buyleads.removeObject(at: tag)
                                    self.tableView.reloadData()
                                }
                            }
                            else{
                                self.customAlert(title: "Failed", message: data["error"] as! String, confirmTitle: "OK", cancelTitle: "")
                            }
                        }
                        else{
                            let dic = data
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                        }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.loadingView.hide()

                        self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                    }
                }
            }
    }
    func deleteDealerCar(carid : String,buyLead_id:String,tag : Int)
    {
        self.loadingView.show(in: self.view, withText: "")
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
                        self.loadingView.hide()
                        if  let dic = data["data"] as? NSDictionary{
                            if(data["status"] as! String == "success"){
                                self.view.showCustomAlert(image: "",
                                    title: "Success",
                                    message: data["details"] as! String,
                                    confirmTitle: "Ok", // Optional, defaults to "OK"
                                    cancelTitle: "", // Optional, defaults to "CANCEL"
                                    confirmAction: {
                                        print("Deleted")
                                       self.fetchBuyLeads()
                                    },
                                    cancelAction: {
                                        print("Cancelled")
                                    }
                                )
                            }
                            else{
                                self.customAlert(title: "Failed", message: dic["error"] as! String, confirmTitle: "Ok", cancelTitle: "Cancel")
                            }
                        }
                        else{
                            let dic = data
                            if(dic["error"] as! String == "INVALID_TOKEN")
                            {
                               // self.refreshToken()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.loadingView.hide()
                        self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                    }
                }
            }
    }
    
    //redirect to edit page
    @objc func editBuylead(sender : UIButton)
    {
        let response = Buyleads[sender.tag] as! NSDictionary
        UserDefaults.standard.set(response["buylead_id"]!, forKey: "buylead_id")
        let editVC = OLXBuyLead_Edit()
        editVC.items = response
        editVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    @objc func calltoBuyLead(sender : UITapGestureRecognizer){
        
        if(UserDefaults.standard.string(forKey: "show_archieve") == "y"){
            self.customAlert(title: "Message..!", message: "To make call, please restore the lead", confirmTitle: "Ok", cancelTitle: "")
        }
        else{
            let response = self.Buyleads[sender.view!.tag] as! NSDictionary
            self.selectionBuyLead = self.Buyleads[sender.view!.tag] as! [String:Any]
//            UserDefaults.standard.set(response["buylead_id"]!, forKey: "buylead_id")
//            self.selectionitems = self.selectionBuyLead as NSDictionary
//            self.appCameBackFromCall()
            self.phoneClicked(dic: self.selectionBuyLead as NSDictionary)

          
//                let actionSheet = UIAlertController(title: "Call \(response["mobile"]! as! String)?", message: nil, preferredStyle: .actionSheet)
//                let callAction = UIAlertAction(title: "Call", style: .default) { _ in
//                    self.phoneClicked(dic: response)
//                    if let phoneURL = URL(string: "tel://\(response["mobile"]! as! String)"),
//                       UIApplication.shared.canOpenURL(phoneURL) {
//                        UIApplication.shared.open(phoneURL)
//                    } else {
//                        print("📵 Calling not supported on this device")
//                    }
//                }
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                actionSheet.addAction(callAction)
//                actionSheet.addAction(cancelAction)
//                self.present(actionSheet, animated: true, completion: nil)
          
        }
    }
    
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
           if call.hasEnded {
               print("📞 Call ended")
               DispatchQueue.main.async {
                   self.phoneCallEnded(dic: self.selectionBuyLead as NSDictionary)
               }
               // Handle end of call safely here
           } else if call.isOutgoing && !call.hasConnected {
               print("📞 Dialing...")
               self.appCameBackFromCall()

           } else if call.hasConnected && !call.hasEnded {
               print("📞 Call connected")
           }
       }
   
    func convertDateToString(_ date: NSDate, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date as Date)
    }
    func phoneClicked(dic : NSDictionary)
    {
        let response = dic
        UserDefaults.standard.set(response["buylead_id"]!, forKey: "buylead_id")
        selectionitems = response as! [String : Any] as NSDictionary
            self.noleadView.isHidden = true
            let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
        
            let parameters = [
                    "action":"submitbuyleadphoneclicksv1",
                    "dealer_id":MyPodManager.user_id,
                    "api_id": "cteolx2024v1.0",
                    "buylead_id":response["buylead_id"]!,
                    "name":response["contact_name"]!,
                    "start_time":convertDateToString(Date() as NSDate),
                    "mobile":response["mobile"]!,
                    "date_app":response["addeddate"]!,
                    "status_text":response["status_text"]!,
                    "device_id":Constant.uuid!
            ] as! [String:Any]
            let api = ApiServices()
            api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                switch result {
                case .success(let data):
                    print("Response Data: \(data)")
                    DispatchQueue.main.async {
                        self.loadingView.hide()
                        if  let dic = data["data"] as? NSDictionary{
                            self.buylead_click_id = "\(dic["buylead_click_id"] as! CVarArg)"
                            if(data["status"] as! String == "success"){
                                if let phoneURL = URL(string: "tel://\(response["mobile"]! as! String)"),
                                   UIApplication.shared.canOpenURL(phoneURL) {
                                    UIApplication.shared.open(phoneURL)
                                } else {
                                    print("📵 Calling not supported on this device")
                                }
                                self.callObserver = CXCallObserver()
                                self.callObserver?.setDelegate(self, queue: self.callQueue)
                            }
                            else{
                            }
                        }
                        else{
                            if(data["error"] as! String == "INVALID_TOKEN")
                            {
                             //   self.refreshToken()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.loadingView.hide()
                        self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")

                    }
                }
            }
    }
    func phoneCallEnded(dic : NSDictionary)
    {
            let response = dic
       // UserDefaults.standard.set(response["buylead_id"]!, forKey: "buylead_id")
        selectionitems = response as! [String : Any] as NSDictionary
            self.noleadView.isHidden = true
            let headers = ["x-origin-Panamera":"dev","Api-Version":"155","Client-Platform":"web","Client-Language":"en-in","Authorization":"Bearer \(MyPodManager.access_token)","Http-User-agent":"postman"] as! [String:String]
            let parameters = [
                "api_id": "cteolx2024v1.0",
                  "app_type": "olx",
                  "device_id": MyPodManager.user_id,
                "mobile":response["mobile"],
                "end_time":convertDateToString(NSDate()),
                  "buylead_id": response["buylead_id"],
                  "action": "submitbuyleadphoneclicksv1",
                "buylead_click_id":self.buylead_click_id,
                  "dealer_id": Constant.uuid!
            ] as! [String:Any]
            let api = ApiServices()
            api.sendRawDataWithHeaders(parameters: parameters, headers: headers,url: Constant.OLXApi) { result in
                switch result {
                case .success(let data):
                    print("Response Data: \(data)")
                    DispatchQueue.main.async {
                        self.loadingView.hide()
                        if  let dic = data["data"] as? NSDictionary{
                           // self.appCameBackFromCall()
                        }
                        else{
                            if(data["error"] as! String == "INVALID_TOKEN")
                            {
                             //   self.refreshToken()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.loadingView.hide()
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                   // self.appCameBackFromCall()
                    DispatchQueue.main.async {
                        self.loadingView.hide()
                      //  self.customAlert(title: "Error", message: error.localizedDescription, confirmTitle: "OK", cancelTitle: "")
                    }
                }
            }
    }
    func collectionViewCellDidSelect(item: String) {
        print("Selected item from collectionView: \(item)")
          // Perform action (e.g., navigate to another screen)
        let userInfo_host: [String: Any] = [
            "olx_buyer_id": item,
            "user_id": MyPodManager.user_id
        ]
        MyPodManager.navigatetoHost(userinfo: userInfo_host)
      }
    
    func chatwithDealer(item: String,tag : Int) {
        
        let response =  Buyleads[tag] as! [String : Any]
        print("Selected item from collectionView: \(item)")
          // Perform action (e.g., navigate to another screen)
        let userInfo_host: [String: Any] = [
            "olx_buyer_id": response["olx_buyer_id"]!,
            "ad_id": item,
            "user_id": MyPodManager.user_id
        ]
        MyPodManager.navigatetoHost(userinfo: userInfo_host)
    }
    
    func customAlert(title: String, message: String, confirmTitle: String, cancelTitle: String)
    {
        self.view.showCustomAlert(image: "",
            title: title,
            message: message,
            confirmTitle: confirmTitle, // Optional, defaults to "OK"
            cancelTitle: cancelTitle, // Optional, defaults to "CANCEL"
            confirmAction: {
                print("Deleted")
            },
            cancelAction: {
                print("Cancelled")
            }
        )
    }
    //delete car
    func deleteCar(item: [String : Any], tag: Int) {
        
        let response =  Buyleads[tag] as! [String : Any]
        let cars = response["cars"] as! NSArray
        if(cars.count > 1){
            self.view.showCustomAlert(image: "delete_alert",
                                      title: "Remove Car",
                                      message: "Do you want to remove this \(item["make"] ?? "") \(item["model"] ?? "")\(item["year"] ?? "")?",
                                      confirmTitle: "DELETE", // Optional, defaults to "OK"
                                      cancelTitle: "CANCEL", // Optional, defaults to "CANCEL"
                                      confirmAction: {
                print("Deleted")
                self.deleteDealerCar(carid: item["id"] as! String,buyLead_id:  response["buylead_id"] as! String,tag : tag)
            },
            cancelAction: {
                print("Cancelled")
            }
            )
        }
    }
    
    @objc func navigateToHostVC(sender : UITapGestureRecognizer) {
        let popup = SendSMSPopupViewController()
        popup.items = Buyleads[sender.view!.tag] as! [String : Any]
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        present(popup, animated: true)
      }
    @objc func visitingStatus(sender:UITapGestureRecognizer)
    {
        let response = Buyleads[sender.view!.tag] as! NSDictionary
        if((response["customer_visited"]! as! String).count != 0){
          //  self.showPopup(title: "Message!", message: "Customer Visited On: \n \(response["customer_visited"]! as! String)")
            self.customAlert(title: "Customer Visited On", message: "\(response["customer_visited"]! as! String)", confirmTitle: "OK", cancelTitle: "")
        }
    }
    func showPopup(title: String, message: String) {
//        let popup = CustomView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
//        popup.center = self.view.center
//        popup.configure(title: title, message: message)
//        self.view.addSubview(popup)
    }
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let customCell = cell as? OnlineBuyLeads_collection {
            customCell.configure(with: data)  // Call your method to update UI
        }
    }
  
}
