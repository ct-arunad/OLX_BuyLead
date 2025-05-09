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
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor),
            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    public func show(in view: UIView, withText text: String) {
        loadingLabel.text = text
        frame = view.frame
       // center = view.center
        view.addSubview(self)
        activityIndicator.startAnimating()
    }

    public func hide() {
        activityIndicator.stopAnimating()
        removeFromSuperview()
    }
}
