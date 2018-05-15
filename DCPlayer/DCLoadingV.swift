//
//  DCLoadingV.swift
//  
//
//  Created by nn on 2017/10/24.
//
//

import UIKit

let loadingV = Bundle.main.loadNibNamed("DCLoadingV", owner: nil, options: nil)?.last as! DCLoadingV//转圈
let topMesV = Bundle.main.loadNibNamed("DCLoadingV", owner: nil, options: nil)?.last as! DCLoadingV//主要用于显示提示, 不会受loadingV.disapear()的影响

class DCLoadingV: UITableViewCell {
    /*
     loadingV.showing() 显示加载中视图
     loading.showMes(mes, after: 1.5)  显示提示信息, 1.5秒后自动隐藏, 可实现loadingV.disapear()的隐藏
     loadingV.disapear() 隐藏加载中视图
     */
    
    func showingNo() {//加载时不能操作
        self.showing()
        self.contentView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
    }
    
    func showing() {//加载时能操作
        if self.alpha == 1 {
            return
        }
        
        self.contentView.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            self.blurV.alpha = 0
            self.hudV.alpha = 1
            self.nameL.alpha = 0
            self.frame = __keyWindow.bounds
            
            self.baseShow()
        }
    }
    
    func showMes(_ mes: String, after: Double) {
        loadingV.disapear()
        
        if mes != "" {
            self.nameL.font = UIFont.boldSystemFont(ofSize: 15)
            self.nameL.text = mes
            let rect = __StringFrame(mes, maxSize: CGSize(width: __MainScreenWidth * 0.8, height: __MainScreenHeight * 0.8), font: UIFont.boldSystemFont(ofSize: 15))
            
            DispatchQueue.main.async {
                self.frame = CGRect(x: 0, y: 0, width: (rect.width + 30)/0.9, height: (rect.height + 30)/0.9)
                self.blurV.frame = self.frame
                
                self.hudV.alpha = 0
                self.blurV.alpha = 1
                self.nameL.alpha = 1
                
                self.baseShow()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
                    self.mesDisapear(mes)
                }
            }
        }else{
            topMesV.disapear()
        }
    }
    
    func showMes(_ mes: String) {
        self.showMes(mes, after: 1.5)
    }
    
    func mesDisapear(_ mes: String) {
        if mes == self.nameL.text {
            self.disapear()
        }
    }
    
    func baseShow() {
        __keyWindow.endEditing(true)
        __keyWindow.addSubview(self)
        self.alpha = 1
        self.center = __keyWindow.center
    }
    
    func disapearAfter() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.disapear()
        }
    }
    func disapear() {
        self.alpha = 0
        self.removeFromSuperview()
    }
    
    @objc class func ocShowMes(_ mes: String) {//oc中使用, 统一oc和swift中的使用
        topMesV.showMes(mes, after: 1.5)
    }
    @objc class func ocShowingNo() {
        loadingV.showingNo()
    }
    @objc class func ocDisapear() {
        loadingV.disapear()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.alpha = 0
        blurV.decotate(textC: nil, cornerR: 5, borderC: nil, borderW: nil)
        blurV.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    @IBOutlet weak var blurV: UIVisualEffectView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var hudV: UIActivityIndicatorView!
}

//func pushShow() {//转场动画显示毛玻璃效果
//    __keyWindow.endEditing(true)
//    DispatchQueue.main.async(execute: { () -> Void in
//        __keyWindow.bringSubview(toFront: self)
//
//        self.frame = __keyWindow.bounds
//        self.blurV.frame = __keyWindow.bounds
//
//        self.nameL.alpha = 0
//        self.hudV.alpha = 0
//        self.alpha = 1
//    })
//}

