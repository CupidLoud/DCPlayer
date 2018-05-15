//
//  DCVideoVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/15.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCVideoVC: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(type(of: self))", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        loadStart()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    deinit {
        topMesV.showMes("\(type(of: self)) \(String(describing: navigationItem.title))")
    }
    //MARK:-核心
    //MARK:-控制
    @objc func orientationDidChange() {//方向改变
        if videoV == nil {
            return
        }
        let ttt = UIDevice.current.orientation
        if ttt == .landscapeLeft || ttt == .landscapeRight {
            videoV.isFullScreen = true
        }
        if ttt == .portrait {
            videoV.isFullScreen = false
        }
    }
    //MARK:-数据
    func loadStart() {
        if videoV == nil {
            videoV = Bundle.main.loadNibNamed("DCPlayerV", owner: self, options: nil)?.last as! DCPlayerV
            view.addSubview(videoV)
            
            videoV.playingTimeBlock = { [weak self] (currentTime, totalTime) in
                if self == nil {
                    return
                }
                //播放中操作, 每秒
            }
            
            videoV.playFineBlock = { [weak self] in
                //播完的操作
            }
            
        }
        videoV.loadStart(haq: myHaq)
        videoV.isFullScreen = false
    }
    //MARK:-UI
    func setUI() {
        
    }
    
    var myHaq = DCHaqi()
    weak var videoV: DCPlayerV!

}
