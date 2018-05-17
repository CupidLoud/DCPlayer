//
//  DCNavVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/16.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var shouldAutorotate : Bool {
        
        let vc = self.topViewController!
        if vc.isKind(of: DCVideoVC.self) && vc.responds(to: #selector(getter: self.shouldAutorotate)) {
            return vc.shouldAutorotate
        }
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let vc = self.topViewController!
        if vc.isKind(of: DCVideoVC.self) && vc.responds(to: #selector(getter: self.supportedInterfaceOrientations)) {
            return vc.supportedInterfaceOrientations
        }
        return UIInterfaceOrientationMask.portrait
    }
}
