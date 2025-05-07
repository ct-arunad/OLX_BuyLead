//
//  LoadingView.swift
//  OLX_BuyLeads
//
//  Created by Aruna on 04/04/25.
//

import Foundation
import UIKit

public class LoadingView: UIView {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 10

        addSubview(activityIndicator)
        addSubview(loadingLabel)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 15),

            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }

    public func show(in view: UIView, withText text: String) {
        loadingLabel.text = text
        frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        center = view.center
        view.addSubview(self)
        activityIndicator.startAnimating()
    }

    public func hide() {
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
}
