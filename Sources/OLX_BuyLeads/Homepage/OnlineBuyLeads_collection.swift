//
//  OnlineBuyLeads_collection.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 01/04/25.
//

import Foundation
import UIKit

protocol collectionCellDelegate: AnyObject {
    func selectedCellitem(item: Int)
    func deselectedCellitem(item: Int)

}


class OnlineBuyLeads_collection : UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    weak var delegate: collectionCellDelegate?  // ✅ Delegate Reference

    var keyvalues =  ["All","hotleads","Inventory",
                      "show_archieve","show_apptfixed"] as! [String]
    static let identifier = "CustomTableViewCell"
    
    public let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Scroll horizontally
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    var items: [Any] = [] // Sample data
    var selectionitems: [Any] = [] // Sample data

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        contentView.backgroundColor = .white
        contentView.addSubview(collectionView)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OnlineBuyLeads_collectioncell.self, forCellWithReuseIdentifier: OnlineBuyLeads_collectioncell.identifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 70) // Set a fixed height
        ])
    }
    
    func configure(with items: [Any]) {
        self.items = items
        collectionView.reloadData()
    }

    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnlineBuyLeads_collectioncell.identifier, for: indexPath) as! OnlineBuyLeads_collectioncell
        cell.configure(title: "\(items[indexPath.item] as! String)")
        cell.contentView.isUserInteractionEnabled = true
        if(indexPath.row == 0){
            cell.checkBox.isHidden = true
            cell.bottomArrow.isHidden = false
        }
        else{
            cell.checkBox.isHidden = false
            cell.bottomArrow.isHidden = true
        }
        if selectionitems.contains(where: { ($0 as? String) == (items[indexPath.row] as! String) }) {
            cell.checkBox.setImage(UIImage.named("check"), for: .normal)
        }
        else{
            cell.checkBox.setImage(UIImage.named("uncheck"), for: .normal)
        }
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(self, action: #selector(selectionCheck), for: .touchUpInside)
        return cell
    }

    @objc func selectionCheck(sender : UIButton)
    {
        if selectionitems.contains(where: { ($0 as? String) == (items[sender.tag] as! String) }) {
            print("Item exists in the array")
            if let index = selectionitems.firstIndex(where: { ($0 as? String) == (items[sender.tag] as! String) }) {
                selectionitems.remove(at: index)
            }
            UserDefaults.standard.set("n", forKey: keyvalues[sender.tag] )
            delegate?.deselectedCellitem(item: sender.tag)
        }
        else{
            UserDefaults.standard.set("y", forKey: keyvalues[sender.tag] )
            selectionitems.append(items[sender.tag] as! String)
            delegate?.selectedCellitem(item: sender.tag)
        }
        self.collectionView.reloadData()
    }
    // MARK: - UICollectionView Delegate FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let text = items[indexPath.item] as! String
        if(indexPath.row > 2){
               let spacing: CGFloat = 20
               let totalSpacing = spacing // Only 1 spacing between 2 cells in a row
               let width = (collectionView.bounds.width - totalSpacing) / 2
               return CGSize(width: width, height: 30)
        }
        let spacing: CGFloat = 5
        let totalSpacing = spacing * 2 + spacing * 2  // left + right + inter-item spacing * 2
        let cellwidth = (collectionView.frame.width - totalSpacing) / 3
        return CGSize(width: cellwidth, height: 30)

        
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            delegate?.selectedCellitem(item: indexPath.row)
        }
        else{
            if selectionitems.contains(where: { ($0 as? String) == (items[indexPath.row] as! String) }) {
                print("Item exists in the array")
                if let index = selectionitems.firstIndex(where: { ($0 as? String) == (items[indexPath.row] as! String) }) {
                    selectionitems.remove(at: index)
                }
                UserDefaults.standard.set("n", forKey: keyvalues[indexPath.row])
                delegate?.deselectedCellitem(item: indexPath.row)
            }
            else{
                UserDefaults.standard.set("y", forKey: keyvalues[indexPath.row])
                selectionitems.append(items[indexPath.row] as! String)
                delegate?.selectedCellitem(item: indexPath.row)
            }
            self.collectionView.reloadData()
        }
    }
}
