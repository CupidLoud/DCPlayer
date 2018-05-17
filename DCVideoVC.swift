//
//  DCVideoVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/15.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCVideoVC: DCVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        loadStart()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    deinit {
        print("\(type(of: self))控制器释放 \(String(describing: navigationItem.title))")
    }
    //MARK:-核心
    override var shouldAutorotate : Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    override var prefersStatusBarHidden: Bool {//控制状态栏是否隐藏
        if videoV == nil {
            return false
        }
        return videoV.isHiddenStatusBar
    }
    
    //MARK:-控制

    //MARK:-数据
    func loadStart() {
        
        if videoV == nil {//初始化播放控件
            
            //完整初始化
            //            videoV = DCPlayerV.setPlayerWith(URL.init(string: "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4")!, normalFrame: nil, isPlayNow: true, playingBlock: { [weak self] (currentTime, totalTime) in
            //                print("currentTime: \(currentTime), totalTime: \(totalTime)")
            //                }, fineBlock: { [weak self] in
            //                    print("剧终")
            //            }, errorBlock: { [weak self] in
            //                print("错误❌")
            //            })
            
            //简单初始化
//            videoV = DCPlayerV.setPlayerWith(URL.init(string: "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4")!, normalFrame: nil, isPlayNow: true)
            videoV = DCPlayerV.setPlayerWith(URL.init(string: "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4")!, normalFrame: CGRect.init(x: 10, y: 200, width: 300, height: 500), isPlayNow: true)
            //并单独设置Block操作
            videoV.playingBlock = { [weak self] (currentTime, totalTime) in
                print("currentTime: \(currentTime), totalTime: \(totalTime)")
            }
            videoV.fineBlock = { [weak self] in
                print("剧终")
            }
            videoV.errorBlock = { [weak self] in
                print("错误❌")
            }
            
            //设置全屏frame, 其他参数都可以单独设置
            //videoV.fullScreenFrame = CGRect.init(x: 10, y: 20, width: 500, height: 300)
            
            view.addSubview(videoV)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.5) {//10秒后测试调用更换视频URL
            self.videoV.changeVideo(URL.init(string: "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4")!)
        }
    }
    //MARK:-UI
    func setUI() {
        view.backgroundColor = UIColor.white
    }
    
    var videoUrl = ""
    weak var videoV: DCPlayerV!

}
