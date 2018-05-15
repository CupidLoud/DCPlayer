
//
//  ToolsDefine.swift
//  工具集
//
//  Created by LakesMac on 16/4/6.
//  Copyright © 2016年 Daen. All rights reserved.
//

import UIKit

class DCToolsDefine: NSObject {
    @objc class func ocFromUtf8ToStr(str: String) -> String {
        return str.fromUtf8ToStr
    }
}
//MARK:-核心
func __curVersion() -> String {
    let infoDictionary = Bundle.main.infoDictionary
    let majorVersion = infoDictionary!["CFBundleShortVersionString"]!//主程序版本号
    return majorVersion as! String
}

func __lastLastVC() -> UIViewController! {
    let vcs = __CurVC().navigationController?.viewControllers
    if vcs!.count >= 3 {
        return vcs![vcs!.count-3] as! UIViewController
    }
    return nil
}

func __lastVC() -> UIViewController! {
    let vcs = __CurVC().navigationController?.viewControllers
    if vcs!.count >= 2 {
        return vcs![vcs!.count-2] as! UIViewController
    }
    return nil
}

func __CurVC() -> UIViewController! {//有UITabBarController和UINavigationController
    let appDele = UIApplication.shared.delegate as! AppDelegate
    let window = appDele.window
    
    if let rootVC = window?.rootViewController {
        if rootVC.isKind(of: UITabBarController.self) {
            let curSelectedNavVC = (rootVC as! UITabBarController).selectedViewController as! UINavigationController
            return curSelectedNavVC.viewControllers.last
        }
        if rootVC.isKind(of: UINavigationController.self) {
            return (rootVC as! UINavigationController).viewControllers.last
        }
    }
    return UIViewController()
}
//MARK:-控制
func _actionSheet(title: String, names: [String], detail: String, handle: ((String)->())?) {
    
    let alertController = UIAlertController(title: title, message: detail,
                                            preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    for str in names {
        let action1 = UIAlertAction.init(title: str, style: .default, handler: { (act) in
            handle?(str)
        })
        alertController.addAction(action1)
    }
    __CurVC().present(alertController, animated: true, completion: nil)
}
func _sureAlertV(title: String, detail: String, cancel: String, okStr: String, isRed: Bool, isSure: ((Bool)->())?) {
    let alert = UIAlertController.init(title: title, message: detail, preferredStyle: .alert)
    
    let action1 = UIAlertAction.init(title: cancel == "" ? "取消" : cancel, style: .default) { (act) in
        isSure?(false)
    }
    let action2 = UIAlertAction.init(title: okStr == "" ? "确定" : okStr, style: .destructive) { (action) in
        isSure?(true)
    }
    alert.addAction(action1)
    alert.addAction(action2)
    __CurVC().present(alert, animated: true, completion: nil)
}
//MARK:-数据
func __attStringH(_ string: NSAttributedString, maxW: CGFloat, font: CGFloat) -> CGFloat {//富文本高度
    let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: maxW, height: 1))
    lab.attributedText = string
    lab.numberOfLines = 0
    lab.font = UIFont.systemFont(ofSize: font)
    let size = lab.sizeThatFits(CGSize.init(width: lab.frame.width, height: 20000))
    let opt = string.attributes(at: 0, effectiveRange: nil)
    if let paragraph = opt[NSAttributedStringKey.paragraphStyle] as? NSMutableParagraphStyle {
        print(paragraph)
        if size.height < (font+paragraph.lineSpacing)*2 {
            return size.height-paragraph.lineSpacing
        }
        return size.height
    }
    return 0
}
public func __StringFrame(_ string: String, maxSize: CGSize, font: UIFont) -> CGRect {
    let _string = NSString(string: string)
    return _string.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [
        NSAttributedStringKey.font: font
        ], context: nil)
}

public func __StringWidth(_ string: String, height: CGFloat, systemFontSize: CGFloat) -> CGFloat {
    return __StringFrame(string, maxSize: CGSize(width: 10000, height: height), font: UIFont.systemFont(ofSize: systemFontSize)).size.width
}

func __strReplace(_ str: String, markStr: String, needStr: String) -> String {
    var str1 = str
    if str1.contains(markStr) {
        let range = (str1 as NSString).range(of: markStr)
        //        print((str1 as NSString).substringToIndex(range.location))
        //        print((str1 as NSString).substringFromIndex(range.location+range.length))
        str1 = (str1 as NSString).substring(to: range.location) + needStr + (str1 as NSString).substring(from: range.location+range.length)
        //        print(str1)
        str1 = __strReplace(str1, markStr: markStr, needStr: needStr)
    }
    return str1
}
func __strGetToMark(_ str: String, markStr: String) -> String {
    var str1 = str
    if str1.contains(markStr) {
        let range = (str1 as NSString).range(of: markStr)
        str1 = (str1 as NSString).substring(to: range.location)
    }
    return str1
}
func __strCutMarkStr(_ str: String, markStr: String) -> String {//去掉markStr
    var str1 = str
    while str1.contains(markStr) {
        let range = (str1 as NSString).range(of: markStr)
        
        let str2 = (str1 as NSString).substring(to: range.location)
        let str3 = (str1 as NSString).substring(from: range.location + range.length)
        
        str1 = str2 + str3
    }
    return str1
}

func __strMarkStrAddNewStr(_ str: String, markStr: String, newStr: String) -> String {
    
    var tempStr = str
    print(tempStr)
    
    var dealedStr = ""
    
    while tempStr.contains(markStr) {
        let range = (tempStr as NSString).range(of: markStr)
        
        let str2 = (tempStr as NSString).substring(to: range.location+range.length).replacingOccurrences(of: markStr, with: markStr+newStr)
        let str3 = (tempStr as NSString).substring(from: range.location+range.length)
        
        dealedStr += str2
        tempStr = str3
    }
    if !tempStr.contains(markStr) {
        dealedStr += tempStr
    }
    return dealedStr
}
func __strFromMarkToEnd(_ str: String, markStr: String) -> String {
    
    var str1 = str
    if str1.contains(markStr) {
        let range = (str as NSString).range(of: markStr)
        //        print(range)
        str1 = (str1 as NSString).substring(from: range.location+range.length)
        //        print(str1)
    }
    return str1
}
func __strCutChar(_ str: String, markStr: String) -> String {
    
    var strArr = [String]()
    for char in str.characters {
        if String(char) != markStr {
            strArr += [String(char)]
        }
    }
    let arrayStr = strArr.joined(separator: "")
    return arrayStr
}

func _strToCGFloat(str: String) -> CGFloat {
    if let doubleValue = Double(str) {
        return CGFloat(doubleValue)
    }
    return 0
}
public func __MakeString(_ array: [String]) -> String {
    return (array.map { "\($0)" } as [String]).joined(separator: ",")
}

func _ImageSizeH(imgName: String) -> CGFloat {//图片高度
    let imgV = UIImageView.init(image: UIImage.init(named: imgName))
    return imgV.frame.height
}

func __getStrInfo(_ key: String) -> String {
    return key.StrInUD
}
public func jsonStr(_ anyData: Any) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: anyData, options: [])
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
        return string as String
    } catch let error as NSError {
        print ("Error: \(error.domain)")
    }
    return ""
}
public func __ArrIn(_ object: Any, for key: String) -> [Any] {
    return key.ArrIn(object)
}
public func __DictionaryIn(_ object: Any, for key: String) -> [String: Any] {
    return key.DictIn(object)
}
public func __StringIn(_ object: Any, for key: String) -> String {
    return key.StrIn(object)
}
public func __IntIn(_ object: Any, for key: String) -> Int {
    return key.IntIn(object)
}
extension String {
    
    var hexColor: UIColor {
        /** 如果传入的字符串为空 */
        if self.isEmpty {
            return UIColor.lightGray
        }
        
        /** 传进来的值。 去掉了可能包含的空格、特殊字符， 并且全部转换为大写 */
        let set = CharacterSet.whitespacesAndNewlines
        var hHex = self.trimmingCharacters(in: set).uppercased()
        
        /** 如果处理过后的字符串少于6位 */
        if hHex.count < 6 {
            return UIColor.clear
        }
        
        /** 开头是用0x开始的 */
        if hHex.hasPrefix("0X") {
            hHex = (hHex as NSString).substring(from: 2)
        }
        /** 开头是以＃开头的 */
        if hHex.hasPrefix("#") {
            hHex = (hHex as NSString).substring(from: 1)
        }
        /** 开头是以＃＃开始的 */
        if hHex.hasPrefix("##") {
            hHex = (hHex as NSString).substring(from: 2)
        }
        
        /** 截取出来的有效长度是6位， 所以不是6位的直接返回 */
        if hHex.count != 6 {
            return UIColor.clear
        }
        
        /** R G B */
        var range = NSMakeRange(0, 2)
        
        /** R */
        let rHex = (hHex as NSString).substring(with: range)
        
        /** G */
        range.location = 2
        let gHex = (hHex as NSString).substring(with: range)
        
        /** B */
        range.location = 4
        let bHex = (hHex as NSString).substring(with: range)
        
        /** 类型转换 */
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        
        Scanner(string: rHex).scanHexInt32(&r)
        Scanner(string: gHex).scanHexInt32(&g)
        Scanner(string: bHex).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }

    func creatQRCodeImgV(sizeLong: CGFloat, qrImg: UIImage?) -> UIImageView {
        
        let codeImage = self.creatQRImg(sizeLong: sizeLong)
        let codeImgV = UIImageView.init(image: codeImage)
        
        if let iconImg = qrImg {//二维码定制logo
            let long = codeImage.size.width/4
            let whiteLong = long/12
            
            let contV = UIView.init(frame: CGRect(x: long/2*3, y: long/2*3, width: long, height: long))
            contV.backgroundColor = UIColor.white
            contV.decotate(textC: nil, cornerR: whiteLong/2, borderC: nil, borderW: nil)
            codeImgV.addSubview(contV)
            
            let iconImgV = UIImageView.init(frame: CGRect.init(x: whiteLong, y: whiteLong, width: long-whiteLong*2, height: long-whiteLong*2))
            iconImgV.image = iconImg
            contV.addSubview(iconImgV)
        }
        return codeImgV
    }
    
    func creatQRImg(sizeLong: CGFloat) -> UIImage {
        let stringData = self.data(using: .utf8, allowLossyConversion: false)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!// 创建一个二维码的滤镜
        qrFilter.setValue(stringData, forKey: "inputMessage")
        qrFilter.setValue(sizeLong<=150 ? "L" : "H", forKey: "inputCorrectionLevel")
        let qrCIImage = qrFilter.outputImage
        
        let colorFilter = CIFilter(name: "CIFalseColor")!// 创建一个颜色滤镜,黑白色
        colorFilter.setDefaults()
        colorFilter.setValue(qrCIImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        
        let scale = sizeLong/colorFilter.outputImage!.extent.size.width
        
        let codeImage = UIImage(ciImage: colorFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: scale, y: scale)))// 返回二维码img
        return codeImage
    }
    
    var strTimeFromNow: String {
        if self == "" {
            return "火星时间25:00"
        }
        let forma = DateFormatter.init()
        forma.dateFormat = "yyyy-MM-dd HH:mm"
        let gregorian = Calendar.init(identifier: Calendar.Identifier.gregorian)
        
        if let dateresult = forma.date(from: (self as NSString).substring(to: 16)) {
            let result = (gregorian as NSCalendar).components([.hour, .year, .month, .minute, .day], from: dateresult, to: Date(), options: NSCalendar.Options.init(rawValue: 0))
            
            forma.dateFormat = "yyyy-MM-dd"
            if result.year! > 0 {
                return forma.string(from: dateresult)//"\(result.year!)年前"
            }else if result.month! > 0 {
                return forma.string(from: dateresult)//"\(result.month!)月前"
            }else if result.day! == 1 {
                return "昨天"
            }else if result.day! == 2 {
                return "前天"
            }else if result.day! > 2 {
                return "\(result.day!)天前"
            }else if result.day! > 15 {
                return forma.string(from: dateresult)
            }else if result.hour! > 0 {
                return "\(result.hour!)小时前"
            }else if result.minute! > 1 {
                return "\(result.minute!)分钟前"
            }else {
                return "刚刚"
            }
        }else{
            return ""
        }
    }
    var timeStr: String {
        if let str = Double(self) {
            return str.timeStr
        }
        return "00:00"
    }
    var intTimeToStr: String {
        if let timeInt = Int(self) {
            print(timeInt)
            let hour = timeInt/60%24
            let min = timeInt%60
            if hour == 0 && min != 0 {
                return "\(min)分钟"
            }
            if hour != 0 && min == 0 {
                return "\(hour)小时"
            }
            if hour != 0 && min != 0 {
                return "\(hour)小时 \(min)分钟"
            }
            return "0分钟"
        }
        return "0分钟"
    }
    var getDigitsOnly: String {//过滤掉数字以外的
        var result = ""
        for char in self.characters {
            if "0123456789".contains("\(char)") {
                result += "\(char)"
            }
        }
        return result
    }
    var isOnlyNumber: Bool {
        for idx in 0..<self.count {
            let oneStr = (self as NSString).substring(with: NSRange.init(location: idx, length: 1))
            print(oneStr)
            if !"0123456789".contains(oneStr) {
                return false
            }
        }
        return true
    }
    var isNumberAndABC: Bool {
        for idx in 0..<self.count {
            let oneStr = (self as NSString).substring(with: NSRange.init(location: idx, length: 1))
            print(oneStr)
            if !"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(oneStr) {
                return false
            }
        }
        return true
    }
    func strHeightByLab(maxW: CGFloat, font: UIFont) -> CGFloat {
        if !self.isNoNilStr {
            return 0
        }
        let lab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: maxW, height: 1))
        lab.text = self
        lab.numberOfLines = 0
        lab.font = font
        let size = lab.sizeThatFits(CGSize.init(width: lab.frame.width, height: 20000))
        return size.height
    }
    
    var isTrue: Bool {
        return "1 true True 是".contains(self)
    }
    var BoolInUD: Bool? {
        print(self)
        let str = __UserDefault.value(forKey: self)
        if str == nil {
            return nil
        }else{
            if str is NSNumber {
                return (str as! Int) == 1 ? true : false
            }
            if str is String {
                return (str as! String).isTrue
            }
            return str as? Bool
        }
    }
    var StrInUD: String {
        print(self)
        let str = __UserDefault.value(forKey: self)
        if str == nil {
            if "studyTime studyNumber studyDay".contains(self) {
                return "--"
            }
            return "0"
        }else{
            if str is NSNumber {
                return "\(str!)"
            }
            print(str as! String)
            return str as! String
        }
    }
    
    var isNoNilStr: Bool {//有字
        return __strCutMarkStr(self, markStr: " ") != ""
    }
    var isPhoneNum: Bool {
        let phoneRegex: String = "^(0|86|17951)?(13[0-9]|15[012356789]|16[6]|19[89]]|17[01345678]|18[0-9]|14[579])[0-9]{8}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    var doubleStr: String {
        if self.isNoNilStr {
            if let doubleVal = Double(self) {
                return String.init(format: "%.2f", doubleVal)
            }
            return self
        }
        return "0.00"
    }
    var htmlAttributedString: NSAttributedString! {
        do {
            return try NSAttributedString(data: self.data(using: String.Encoding.utf16)!,
                                          options: [.documentType: NSAttributedString.DocumentType.html],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    var html2String: String {
        return htmlAttributedString?.string ?? ""
    }
    var fromUtf8ToStr: String{//解码为utf8字符, 包括空格
        let codeStr = __strReplace(self, markStr: "+", needStr: "%20")
        return (codeStr as NSString).replacingPercentEscapes(using: String.Encoding.utf8.rawValue)!
    }
    
    func DictIn(_ object: Any) -> [String: Any] {
        let dic = (object as AnyObject).value(forKey: self)
        if dic == nil {
            print("[Dictionary]can not found the value of key:\(self)")
            return [:]
        }
        if dic is NSNull {
            return [:]
        }
        if dic is String {
            return [:]
        }
        if dic is NSArray {
            return [:]
        }
        return dic as! [String: Any]
    }
    
    func ArrIn(_ object: Any) -> [Any] {
        let array = (object as AnyObject).value(forKey: self)
        if array == nil {
            print("[Array]can not found the value of key:\(self)")
            return []
        }
        if array is NSNull {
            return []
        }
        if array is NSDictionary {
            return []
        }
        if array is String {
            return []
        }
        return array as! [Any]
    }
    
    func StrIn(_ object: Any) -> String {
        
        if object is String {
            return ""
        }
        let string = (object as AnyObject).value(forKey: self)
        
        if string == nil {
            print("[String]can not found the value of key:\(self)")
            return ""
        }
        if string is NSNumber {
            return "\(string!)"
        }
        if string is NSNull {
            return ""
        }
        return string as! String
    }
    
    func IntIn(_ object: Any) -> Int {
        let string = (object as AnyObject).value(forKey: self)
        if string == nil {
            print("[Int]can not found the value of key:\(self)")
            return 0
        }
        if string is NSNull {
            return 0
        }
        if string is String {
            return Int(string as! String)!
        }
        return string as! Int
    }
}
extension UILabel {
    
    var labWidth: CGFloat {
        let size = self.sizeThatFits(CGSize.init(width: 10000, height: self.frame.height))
        return size.width
    }
    
    var labHeight: CGFloat {
        let size = self.sizeThatFits(CGSize.init(width: self.frame.width, height: 10000))
        return size.height
    }
    
    func changeSpace(lineSpace: CGFloat?, wordSpace: CGFloat?) {//改变字间距和行间距
        if self.text == nil || self.text == "" {
            return
        }
        var attributedString = NSMutableAttributedString.init(string: self.text!)
        if let wordS = wordSpace {
            attributedString = NSMutableAttributedString.init(string: self.text!, attributes: [NSAttributedStringKey.kern: wordS])
        }
        let paragraphStyle = NSMutableParagraphStyle()
        if let lineS = lineSpace {
            paragraphStyle.lineSpacing = lineS
        }
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: (self.text?.count)!))
        self.attributedText = attributedString
        self.sizeToFit()
    }
}
extension UIView {
    
    var cutImage: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return  theImage!
    }
    
    func decotate(textC: UIColor?, cornerR: CGFloat?, borderC: UIColor?, borderW: CGFloat?) {
        self.layer.masksToBounds = true
        if textC != nil {
            if self.isKind(of: UIButton.self) {
                (self as! UIButton).setTitleColor(textC, for: .normal)
            }
        }
        if cornerR != nil {
            self.layer.cornerRadius = cornerR!
        }
        if borderC != nil {
            self.layer.borderColor = borderC!.cgColor
        }
        if borderW != nil {
            self.layer.borderWidth = borderW!
        }
    }
    
    func isShowingView(isShow: Bool) {
        if isShow {
            self.animatShow()
        }else{
            self.animatDisaper()
        }
    }
    
    func animatShow() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func animatDisaper() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        }
    }
    func animatDisaper(_ time: Double) {
        UIView.animate(withDuration: time) {
            self.alpha = 0
        }
    }
}
extension Int {
    var allAspectLong: CGFloat {//全屏幕保持比例
        return CGFloat(self).allAspectLong
    }
    var size5sLong: CGFloat {//适配5s
        return CGFloat(self).size5sLong
    }
    var navbarLong: CGFloat {
        return CGFloat(self).navbarLong
    }
}
extension CGFloat {
    var allAspectLong: CGFloat {//全屏幕保持比例
        if __MainScreenHeight == 568 {
            return self*568/667
        }
        if __MainScreenHeight == 667 {
            return self
        }
        if __MainScreenHeight == 736 {
            return self*736/667
        }
        return self
    }
    var size5sLong: CGFloat {//适配5s
        if __MainScreenWidth == 320 {
            return self*320/375
        }
        return self
    }
    var navbarLong: CGFloat {
        if UIDevice.current.isX() {
            return self-24
        }
        return self
    }
}
extension Double {
    var timeStr: String {
        let miniter = Int(self/60)
        let second = Int(self.truncatingRemainder(dividingBy: 60))
        return "\(miniter < 10 ? "0" : "")\(miniter):\(second < 10 ? "0" : "")\(second)"
    }
}
extension UIButton {
    func toTopLow() {
        let btnW = self.frame.size.width
        let labelH = self.titleLabel?.font.pointSize
        let imageWith = self.imageView!.frame.size.width
        let imageH = self.imageView!.frame.size.height
        
        self.imageEdgeInsets = UIEdgeInsetsMake(-labelH!-5, (btnW-imageWith)/2, 0, 0)
        self.titleEdgeInsets = UIEdgeInsetsMake(imageH-5, -imageWith, 0, 0)
    }
    func toLeftRight() {
        let btnW = self.frame.size.width
        let imageWith = self.imageView!.frame.size.width
        self.imageEdgeInsets = UIEdgeInsetsMake(0, (btnW-imageWith), 0, 0)
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith-10, 0, 0)
    }
}

extension UIBarButtonItem {
    func decorate(font: UIFont, tintColor: UIColor) {
        self.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: tintColor], for: UIControlState())
        self.setTitleTextAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: tintColor], for: .highlighted)
    }
}
extension UIColor {
    convenience init(_ r:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
        self.init(red: r/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    var getColorRGB: (r: CGFloat, g: CGFloat, b: CGFloat)! {
        if self.cgColor.numberOfComponents == 4 {
            return ((r: self.cgColor.components?[0], g: self.cgColor.components?[1], b: self.cgColor.components?[2]) as! (r: CGFloat, g: CGFloat, b: CGFloat))
        }
        return nil
    }
}
extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}
extension NSNotification {
    
}
extension NotificationCenter {
    func addDCNotification(_ observer: Any, selector: Selector, name: String, object: Any?) {
        self.addObserver(observer, selector: selector, name: NSNotification.Name.init(name), object: object)
        notificationStrs += [name]
        if !notificationStrs.contains(name) {
            
        }
    }
    func removeDCNotification(_ observer: Any, name: String, object: Any?) {
        if notificationStrs.contains(name) {
            self.removeObserver(observer, name: NSNotification.Name.init(name), object: object)
            notificationStrs.remove(at: notificationStrs.index(of: name)!)
        }
    }
}
struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
let __keyWindow = UIApplication.shared.delegate!.window!!
let  __UserDefault = UserDefaults.standard
var __StoryBoard: UIStoryboard {
    get {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}
let bundleVersion = Bundle.main.infoDictionary![String(kCFBundleVersionKey)] as! String
public let __MainScreenBounds = UIScreen.main.bounds
public let __MainScreenSize   = __MainScreenBounds.size
public let __MainScreenWidth  = __MainScreenSize.width
public let __MainScreenHeight = __MainScreenSize.height
var notificationStrs = [String]()
