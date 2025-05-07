import UIKit
import Foundation

class TreeListModel: NSObject {
    // MARK: - Properties
    private var sections: [[NSMutableDictionary]] = []
    private var selectedIndexPath: IndexPath?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    func itemForRowAtIndexPath(_ indexPath: IndexPath) -> NSMutableDictionary? {
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].count else {
            return nil
        }
        return sections[indexPath.section][indexPath.row]
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].count
    }
    
    func itemsInSection(_ section: Int) -> [[String: Any]]? {
        guard section < sections.count else { return nil }
        return sections[section].map { $0 as! [String: Any] }
    }
    
    func setSelectedIndexPath(_ indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func getSelectedIndexPath() -> IndexPath? {
        return selectedIndexPath
    }
    
    // MARK: - Helper Methods
    func updateSections(_ newSections: [[NSMutableDictionary]]) {
        sections = newSections
    }
    
    func updateItem(at indexPath: IndexPath, with value: String) {
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].count else {
            return
        }
        sections[indexPath.section][indexPath.row]["text"] = value
    }
    
    func getItem(with key: String) -> NSMutableDictionary? {
        for section in sections {
            if let item = section.first(where: { ($0["key"] as? String) == key }) {
                return item
            }
        }
        return nil
    }
    
    func getAllItems() -> [[NSMutableDictionary]] {
        return sections
    }
} 
