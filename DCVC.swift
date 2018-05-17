//
//  DCVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/16.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCVC: UIViewController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self//侧滑返回

    }
    
}
