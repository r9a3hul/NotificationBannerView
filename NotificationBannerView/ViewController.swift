//
//  ViewController.swift
//  NotificationBannerView
//
//  Created by Chhetri, Rahul on 31/01/20.
//  Copyright © 2020 Chhetri, Rahul. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var timer: Timer? = nil
    var banner: NotificationBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showClicked(_ sender: Any) {
        let msg = "This webpage will reload after"
        var time = 8
        banner = NotificationBannerView()
        // these are the customisations available
//        banner.textColor
//        banner.bgColor
//        banner.font
//        banner.closeImage
//        banner.showsCloseImage
        banner.show(message: "\(msg) \(time) sec", in: self, animated: true) { [unowned self] shown in
            // banner is shown, start timer
            if shown {
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                        print("timer ticking")
                        time -= 1
                        self.banner.text = "\(msg) \(time) sec"
                        if time < 1 {
                            self.banner.dismiss(animated: true)
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                    }
                }
            }
        }
        banner.dismissHandler = { [unowned self] in
            print("in vc after banner view dismissed")
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
