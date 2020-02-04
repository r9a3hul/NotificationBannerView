//
//  NotificationBannerView.swift
//  NotificationBannerView
//
//  Created by Chhetri, Rahul on 04/02/20.
//  Copyright © 2020 Chhetri, Rahul. All rights reserved.
//

import Foundation
import UIKit

final class NotificationBannerView: UIView {
    
    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet weak var closeButton: UIButton!
    
    private let bannerViewTag = 8494
    private var delay = 1.0
    private let height: CGFloat = 44.0
    private var topConstraint: NSLayoutConstraint!
    
    public var dismissHandler: (() -> Void)? = nil
    public var showsCloseImage = true {
        didSet {
            if showsCloseImage {
                closeImageView.isHidden = false
                closeButton.isHidden = false
                closeButton.isUserInteractionEnabled = true
            } else {
                closeImageView.isHidden = true
                closeButton.isHidden = true
                closeButton.isUserInteractionEnabled = false
            }
        }
    }
    
    // Customisation points
    public var text: String! {
        didSet {
            titleLabel.text = text
        }
    }
    public var font: UIFont! {
        didSet {
            titleLabel.font = font
        }
    }
    public var textColor: UIColor! {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    public var bgColor: UIColor! {
        didSet {
            backgroundColor = bgColor
        }
    }
    public var closeImage: UIImage! {
        didSet {
            closeImageView.image = closeImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed("\(NotificationBannerView.self)", owner: self)
        addSubview(view)
        // setup view
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        text = ""
        applyBlurEffect()
        if showsCloseImage {
            closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        }
        
        font = .systemFont(ofSize: 13.0, weight: .medium)
        textColor = UIColor.init(red: 255.0/255.0, green: 110.0/255.0, blue: 110.0/255.0, alpha: 1.0)
        bgColor = UIView().backgroundColor
        closeImage = UIImage(named: "close_16px")
        
        tag = bannerViewTag
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func applyBlurEffect() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            blurView.effect = UIBlurEffect(style: .dark)
        default:
            blurView.effect = UIBlurEffect(style: .extraLight)
        }
    }
    
    public func show(message: String,
                     in vc: UIViewController,
                     animated: Bool = true,
                     completion: @escaping (Bool)->Void = { _  in  }) {
        DispatchQueue.main.async { [unowned self] in
            // do not add banner view if already present in view heirarchy
            let subviews = vc.view.subviews
            for view in subviews {
                if view.tag == self.bannerViewTag {
                    completion(false)
                    return
                }
            }
            
            self.text = message
            self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.height)
            vc.view.addSubview(self)
            
            let safeGuide = vc.view.safeAreaLayoutGuide
            self.heightAnchor.constraint(equalToConstant: self.height).isActive = true
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor),
            ])
            vc.view.layoutIfNeeded()
            
            // save constraint for later use in animation
            self.topConstraint = self.topAnchor.constraint(equalTo: safeGuide.topAnchor)
            let block = {
                NSLayoutConstraint.activate([
                    self.topConstraint
                ])
                vc.view.layoutIfNeeded()
            }
            
            if animated {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                    block()
                }, completion: { _ in
                    completion(true)
                })
            } else {
                block()
                completion(true)
            }
        }
    }
    
    @objc public func close() {
        print("User tapped close image")
        delay = 0.0
        dismiss(animated: true)
    }
    
    public func dismiss(animated: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if self.topConstraint != nil {
                self.topConstraint.constant = -self.height
                if animated {
                    UIView.animate(withDuration: 0.3, delay: self.delay, options: [.curveEaseInOut], animations: {
                        self.superview?.layoutIfNeeded()
                    }, completion: { _ in
                        self.removeFromSuperview()
                        self.dismissHandler?()
                        print("Banner view dismissed")
                    })
                } else {
                    self.view.frame.origin.y = 0.0
                    self.removeFromSuperview()
                    self.dismissHandler?()
                    print("Banner view dismissed")
                }
            }
        }
    }
}
