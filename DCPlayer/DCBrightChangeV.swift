//
//  DCBrightChangeV.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/16.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCBrightChangeV: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect.init(x: 0, y: 0, width: 155, height: 155)
        self.layer.cornerRadius  = 10
        self.layer.masksToBounds = true
        
        // 使用UIToolbar实现毛玻璃效果，简单粗暴，支持iOS7+
        let toolbar = UIToolbar.init(frame: self.bounds)
        toolbar.alpha = 0.97
        self.backgroundColor = UIColor.init(red: 221/255, green: 222/255, blue: 250/255, alpha: 1.0)
        self.addSubview(toolbar)
        
        self.backImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 79, height: 76))
        self.backImage.image = UIImage.init(named: "DCPlayer_brightness".BundleImgStr)
        self.backImage.center = self.center
        self.addSubview(backImage)
        
        self.title = UILabel.init(frame: CGRect.init(x: 0, y: 5, width: self.bounds.size.width, height: 30))
        self.title.font = UIFont.boldSystemFont(ofSize: 16)
        self.title.textColor = UIColor.init(red: 0.25, green: 0.22, blue: 0.21, alpha: 1.0)
        self.title.textAlignment = .center
        self.title.text = "亮度"
        self.addSubview(title)
        
        self.longView = UIView.init(frame: CGRect.init(x: 13, y: 132, width: self.bounds.size.width - 26, height: 7))
        self.longView.backgroundColor = UIColor.init(red: 0.25, green: 0.22, blue: 0.21, alpha: 1.0)
        self.addSubview(longView)
        
        createTips()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        UIScreen.main.addObserver(self, forKeyPath: "brightness", options: .new, context: nil)

        self.alpha = 0.0
        __keyWindow.addSubview(self)
        self.center = __keyWindow.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createTips() {
        self.tipArray = NSMutableArray.init(capacity: 16)
        
        let tipW = (self.longView.bounds.size.width - 17) / 16
        let tipH:CGFloat = 5
        let tipY:CGFloat = 1
        
        for i in 0..<16 {
            let tipX = CGFloat(i) * (tipW + 1) + 1;
            let image = UIImageView.init(frame: CGRect.init(x: tipX, y: tipY, width: tipW, height: tipH))
            image.backgroundColor = UIColor.white
            self.longView.addSubview(image)
            tipArray.add(image)
        }
        updateLongView(UIScreen.main.brightness)
    }
    func updateLongView(_ sound: CGFloat) {
        let stage: CGFloat = 1 / 15.0
        let level = Int(sound / stage)
        
        for i in 0..<tipArray.count {
            let img = self.tipArray[i]
            (img as! UIImageView).isHidden = i>level
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let new = change {
            let brightNess = new[NSKeyValueChangeKey.newKey] as! CGFloat
            showBrightV()
            updateLongView(brightNess)
        }
    }
    @objc func orientationDidChange() {//方向改变
        self.center = __keyWindow.center
    }
    
    func showBrightV() {
        if self.alpha == 0.0 {
            self.alpha = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
                self.disapperV()
            }
        }
    }
    func disapperV() {
        self.animatDisaper(0.8)
    }
        
    var backImage: UIImageView!
    var title: UILabel!
    var longView: UIView!
    var tipArray: NSMutableArray!

}
