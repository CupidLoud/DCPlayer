//
//  DCPlayerV.swift
//  CloudClassroom
//
//  Created by JunWin on 2018/5/2.
//  Copyright © 2018年 freeWorld2018. All rights reserved.

/*
 使用Xcode9.2 swift4基于AVPlayer封装的轻量视频播放控件
 支持常用手势操作, 左右滑动控制播放进度, 上下滑动控制音量和亮度
 支持切换倍速播放
 支持真实全屏播放
 
 所有变量和方法都是public, 可以自定义封装初始化方法
 如果引用 pod 'DCPlayer'  请下载gitHub完整工程参考https://github.com/CupidLoud/DCPlayer
 */

import UIKit
import MediaPlayer

open class DCPlayerV: UIView {
    
    deinit {
        print("播放控件已释放 \(type(of: self))")
        releasePlayer()
        brightV.removeFromSuperview()
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            videoPause(true)
            cancelWillDisaperControlV()
        }
    }
    
    //MARK:-核心
    public func releasePlayer() {//释放
        if videoItem != nil {
            playerState = .notSetURL
            NotificationCenter.default.removeObserver(self)
            videoItem.removeObserver(self, forKeyPath: "status")
            videoItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            videoItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            videoItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            dcPlayer!.removeTimeObserver(timeObserver)
            cancelWillDisaperControlV()
            videoItem = nil
            dcPlayer = nil
        }
    }
    
    public func initPlayer() {//初始化
        releasePlayer()
        
        videoItem = AVPlayerItem.init(url: videoUrl)//初始化AVPlayerItem
        //各种状态监听
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(finishPlay), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoItem)
        videoItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        videoItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        videoItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        videoItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        
        dcPlayer = AVPlayer.init(playerItem: videoItem)//初始化AVPlayer
        dcVideoLayer.player = dcPlayer//设置AVPlayer的显示layer
        dcVideoLayer.frame = bounds
        
        //播放中时间监听
        timeObserver = dcPlayer!.addPeriodicTimeObserver(forInterval: CMTime.init(value: CMTimeValue(1), timescale: CMTimeScale(1)), queue: DispatchQueue.main) { [weak self] curTime in
            
            self!.isShowBuffV = false
            self!.leftTimeL.text = CMTimeGetSeconds(curTime).timeStr
            self!.sliderV.setValue(Float(CMTimeGetSeconds(curTime)/self!.totalTime), animated: true)
            self!.playingBlock?(CMTimeGetSeconds(curTime), self!.totalTime)
        }
    }

    public var playerState = DCPlayerState.notSetURL {//播放控件所处状态
        willSet {
            if newValue == .notSetURL {
                hudL.animatDisaper()
            }
            if newValue == .startToPlay {//手动开始播放
                initPlayer()
                isShowBuffV = true
            }
            if newValue == .readyToPlay {//系统加载完开始的一段视频 准备好了播放
                totalTime = CMTimeGetSeconds(videoItem.duration)
                if playerState != .playing {//如果不处于播放状态
                    startOrBtnDo(playCenterBtn)
                }
                if !videoGesImaV.isHidden && isShowGestImgV {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.controlVDisaper()
                        UIView.animate(withDuration: 3, animations: {
                            self.videoGesImaV.alpha = 1
                            self.videoGesImaV.alpha = 0.5
                        }, completion: { (finish) in
                            self.videoGesImaV.alpha = 0
                            self.videoGesImaV.isHidden = true//隐藏手势图, 一次生命周期只显示一次
                        })
                    }
                }
            }
            if newValue == .playing {//播放视频
                dcPlayer!.play()
                rePlayBtn.alpha = 0
                playCenterBtn.setImage("DCPlayer_pause".img, for: .normal)
                bigImgV.animatDisaper()
                isHandOn = false
            }
            if newValue == .paused {//暂停视频
                isShowBuffV = false
                playCenterBtn.setImage("DCPlayer_play".img, for: .normal)
                dcPlayer!.pause()
            }
            if newValue == .playedToTheEnd {
                hudL.animatDisaper()
            }
            if newValue == .buffering {
                isShowBuffV = true
            }
            if newValue == .error {
                isShowBuffV = false
                errorBlock?()
                //                showPlayerMes(":( 视频不见了\n请重试或联系客服", autoDisaper: false)
            }
        }
    }
    
    @objc func orientationDidChange() {//方向改变
        if videoItem == nil {
            return
        }
        let ttt = UIDevice.current.orientation
        if ttt == .landscapeLeft || ttt == .landscapeRight {
            isFullScreen = true
        }
        if ttt == .portrait {
            isFullScreen = false
        }
    }
    
    //MARK:-控制
    @IBAction func startOrBtnDo(_ sender: UIButton) {
        isHandOn = true
        if playerState == .notSetURL {
            playerState = .startToPlay
            playerState = .playing
        }else if playerState == .playing {
            playerState = .paused
        }else{
            playerState = .playing
        }
    }
    
    @IBAction func rePlayBtnDo(_ sender: Any) {//重播
        showControlVAfter(7)
        seek(0, isPlay: true)
    }
    
    @objc func finishPlay() {//播完
        fineBlock?()
        rePlayBtn.alpha = 1
        playCenterBtn.alpha = 0
    }
    
    @IBAction func backBtnDo(_ sender: Any) {
        if isFullScreen {
            fullBtnDo(fullBtn)
        }else{
            __CurVC().navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func fullBtnDo(_ sender: UIButton) {//全屏控制
        isFullScreen = !isFullScreen
        DispatchQueue.main.async {
            UIDevice.current.setValue(self.isFullScreen ? UIInterfaceOrientation.landscapeRight.rawValue : UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = self.isFullScreen ? .landscapeRight : .portrait
        }
    }
    
    @IBAction func rateBtnDo(_ sender: UIButton) {//速率
        print(sender.currentTitle!)
        if let idx = rates.index(of: sender.currentTitle!) {
            print(idx)
            sender.setTitle(rates[(idx+1)%rates.count], for: .normal)
            dcPlayer.rate = Float(sender.currentTitle!)!
        }
        showControlVAfter(7)
    }
    
    @IBAction func sliderChange(_ sender: UISlider) {//拖动进度条中
        sliderChangeTime = Double(sliderV.value)*totalTime
        isPanVertical = true
    }
    
    @IBAction func sliderEnd(_ sender: UISlider) {//拖动进度条完成
        seek(Double(sliderV.value)*totalTime, isPlay: true)
        isPanVertical = false
    }
    
    public func seek(_ toTime: Double, isPlay: Bool) {//调到time播放
        isShowBuffV = true
        sliderV.setValue(Float(toTime/totalTime), animated: true)
        dcPlayer!.seek(to: CMTime.init(seconds: toTime, preferredTimescale: CMTimeScale(1)))
        if isPlay {
            playerState = .playing
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath {//KVO播放控件状态
            if let _ = change {
                switch keyPath {
                case "status":
                    switch dcPlayer!.currentItem!.status {
                    case .readyToPlay:
                        playerState = .readyToPlay
                    default:
                        playerState = .error
                    }
                case "loadedTimeRanges"://视频数据加载进度
                    let timeRange = videoItem.loadedTimeRanges.last?.timeRangeValue
                    let loadTime = CMTimeAdd(timeRange!.start, timeRange!.duration)
                    progressV.setProgress(Float(CMTimeGetSeconds(loadTime)/totalTime), animated: true)
                case "playbackBufferEmpty":
                    playerState = .buffering
                case "playbackLikelyToKeepUp":
                    playerState = .bufferFinished
                    if !isHandOn {//如果不是手动暂停, 那么自动继续播放
                        playerState = .playing
                    }
                default:
                    return
                }
            }
        }
    }
    
    @objc func tapGuestDo(_ tapG: UITapGestureRecognizer) {//单击
        if lowControlV.alpha == 1 {
            controlVDisaper()
        }else{
            showControlVAfter(playerState == .playing ? 7 : 999)
        }
    }
    
    @objc func panGuestDo(_ panG: UIPanGestureRecognizer) {//拖动手势
        
        let location = panG.location(in: controlV)
        let velocityPoint = panG.velocity(in: self)
        let x = fabs(velocityPoint.x)
        let y = fabs(velocityPoint.y)
        
        switch panG.state {
        case .changed:
            if x/y>5 {//水平
                sliderV.setValue(sliderV.value + Float(velocityPoint.x/50000), animated: true)
                sliderChange(sliderV)
            }else if x/y<0.1 {//垂直
                location.x>frame.width/2 ? (volumeSlider.value -= Float(velocityPoint.y/10000)) : (UIScreen.main.brightness -= velocityPoint.y/10000)
            }
        case .ended:
            if isPanVertical {
                sliderEnd(sliderV)
            }
        default:
            return
        }
    }
    
    public func videoPause(_ byHand: Bool) {//暂停 是否手动
        if videoItem != nil {
            isHandOn = byHand
            playerState = .paused
            showControlVAfter(999)
        }
    }
    
    //MARK:-数据 几种初始化视频播放控件的方法 更改视频URL
    public class func setPlayerWith(_ videoUrl: URL, normalFrame: CGRect?, isPlayNow: Bool, playingBlock: ((Double, Double)->())?, fineBlock: (()->())?, errorBlock: (()->())?) -> DCPlayerV! {
        
        let playerV = Bundle.init(for: DCPlayerV.self).loadNibNamed("DCPlayerV", owner: nil, options: nil)!.last as! DCPlayerV
        if let frame = normalFrame {
            playerV.normalFrame = frame
        }
        DispatchQueue.main.async {
            playerV.frame = playerV.normalFrame
            playerV.dcVideoLayer.frame = playerV.bounds
        }
        
        playerV.playingBlock = playingBlock
        playerV.fineBlock = fineBlock
        playerV.errorBlock = errorBlock
        
        playerV.videoUrl = videoUrl
        playerV.nameL.text = "轻量视频播放控件"
        if isPlayNow {
            playerV.playerState = .startToPlay
            playerV.playerState = .playing
        }
        
        return playerV
    }

    /*
     可变型变量: normalFrame默认为normalFrame; playingBlock fineBlock errorBlock默认为nil
     */
    public class func setPlayerWith(_ videoUrl: URL, normalFrame: CGRect?, isPlayNow: Bool) -> DCPlayerV! {
        return setPlayerWith(videoUrl, normalFrame: normalFrame, isPlayNow: isPlayNow, playingBlock: nil, fineBlock: nil, errorBlock: nil)
    }
    
    public func changeVideo(_ videoUrl: URL) {
        self.videoUrl = videoUrl
        playerState = .startToPlay
        playerState = .playing
    }
    //MARK:-UI
    public func setUI() {//初始化界面
        leftGesImgV.image = "DCBrightness".img
        centerGesImgV.image = "DCSchedule".img
        rightGesImgV.image = "DCVolume".img
        backBtn.setImage("DCPlayer_back".img, for: .normal)
        playCenterBtn.setImage("DCPlayer_play".img, for: .normal)
        fullBtn.setImage("DCPlayer_fullscreen".img, for: .normal)

        sliderV.setThumbImage("DCPlayer_slider_thumb".img, for: UIControlState())
        lowControlV.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        progressV.progressTintColor = UIColor.white.withAlphaComponent(0.6)
        progressV.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        nameLL.constant = isX() ? 15 : 0//适配iPhone X
        for view in MPVolumeView().subviews {//获取音量控制
            if let slider = view as? UISlider {
                volumeSlider = slider
            }
        }
        
        dcVideoLayer = AVPlayerLayer()
        layer.insertSublayer(dcVideoLayer, at: 0)
        layer.backgroundColor = UIColor.black.cgColor
        
        controlV.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panGuestDo(_:))))
        controlV.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGuestDo(_:))))
    }
    
    public func showPlayerMes(_ mes: String, autoDisaper: Bool) {//播放控件内提示
        hudL.alpha = 1
        hudL.text = mes
        if autoDisaper {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.hudL.animatDisaper()
            }
        }
    }
    
    @objc public func controlVDisaper() {//隐藏控制界面
        topControlV.animatDisaper()
        if rePlayBtn.alpha == 0 && bufferingV.alpha == 0 {
            playCenterBtn.animatDisaper()
        }
        lowControlV.animatDisaper()
        isHiddenStatusBar = isFullScreen
    }
    
    public func controlVShow() {//显示控制界面
        nameL.alpha = 1
        topControlV.animatShow()
        if rePlayBtn.alpha == 0 && bufferingV.alpha == 0 {
            playCenterBtn.animatShow()
        }
        lowControlV.animatShow()
        isHiddenStatusBar = false
    }
    
    public func showControlVAfter(_ time: Double) {//显示控制界面 并自动消失
        if videoItem != nil {
            controlVShow()
            cancelWillDisaperControlV()
            perform(#selector(controlVDisaper), with: nil, afterDelay: time)
        }
    }
    
    public func cancelWillDisaperControlV() {//释放控制界面自动消失任务  不取消可能会导致播放控件无法释放
        if videoItem != nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controlVDisaper), object: nil)
        }
    }
    
    public func isX() -> Bool {//是否iPhone X
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
    
    //MARK:-变量
    public var isFullScreen: Bool = false {//是否全屏
        didSet {
            
            fullBtn.setImage(isFullScreen ?  "DCPlayer_portialscreen.png".img : "DCPlayer_fullscreen.png".img, for: .normal)
            __CurVC().navigationController?.interactivePopGestureRecognizer?.isEnabled = !isFullScreen
            DispatchQueue.main.async {
                self.frame = self.isFullScreen ? self.fullScreenFrame : self.normalFrame
                self.dcVideoLayer.frame = self.bounds
            }
        }
    }
    
    public var isHiddenStatusBar = false {//是否隐藏状态栏
        didSet {
            UIView.animate(withDuration: 0.3) {
                __CurVC().setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    public var totalTime: Double = 999 {//总时间
        didSet {
            rightTimeL.text = totalTime.timeStr
        }
    }
    
    public var isShowBuffV: Bool = false {//是否显示视频加载中界面
        didSet {
            if isShowBuffV {
                playCenterBtn.alpha = 0
                bufferingV.animatShow()
            }else{
                bufferingV.animatDisaper()
            }
        }
    }
    
    public var sliderChangeTime: Double = 0 {
        didSet {
            leftTimeL.text = sliderChangeTime.timeStr
            videoPause(true)
            rePlayBtn.alpha = 0
        }
    }
    
    public var videoUrl: URL!
    public var playingBlock: ((Double, Double)->())?//播放中每秒调用一次
    public var fineBlock: (()->())?//播完
    public var errorBlock: (()->())?//播放出错

    @IBOutlet public weak var controlV: UIView!//控制界面
    @IBOutlet public weak var topControlV: UIView!//控制界面上部分
    @IBOutlet public weak var backBtn: UIButton!
    @IBOutlet public weak var nameL: UILabel!
    @IBOutlet public weak var nameLL: NSLayoutConstraint!//nameL距离相对下界面距离
    @IBOutlet public weak var rateBtn: UIButton!//切换速率
    @IBOutlet public weak var bigImgV: UIImageView!//视频图片
    @IBOutlet public weak var playCenterBtn: UIButton!//播放暂停
    @IBOutlet public weak var rePlayBtn: UIButton!//重播
    @IBOutlet public weak var bufferingV: UIActivityIndicatorView!//加载中界面
    @IBOutlet public weak var hudL: UILabel!//提示lab
    @IBOutlet public weak var lowControlV: UIView!//控制界面下部分
    @IBOutlet public weak var leftTimeL: UILabel!
    @IBOutlet public weak var sliderV: UISlider!//播放控制进度条
    @IBOutlet public weak var progressV: UIProgressView!//加载进度条
    @IBOutlet public weak var rightTimeL: UILabel!//总时间
    @IBOutlet public weak var fullBtn: UIButton!
    @IBOutlet public weak var videoGesImaV: UIView!
    @IBOutlet public weak var leftGesImgV: UIImageView!//视频图片
    @IBOutlet public weak var centerGesImgV: UIImageView!//视频图片
    @IBOutlet public weak var rightGesImgV: UIImageView!//视频图片

    public var videoItem: AVPlayerItem!
    public var dcPlayer: AVPlayer!
    public var dcVideoLayer: AVPlayerLayer!
    var timeObserver: Any!//播放中时间监听者
    let rates = ["0.8", "1.0", "1.5", "2.0", "2.5", "3.0"]
    let brightV = DCBrightChangeV()//亮度调节界面
    var volumeSlider: UISlider!//音量调节界面
    
    var isPanVertical = false//是否水平拖动手势
    public var isHandOn = true//是否手动操作
    public var isShowGestImgV = true//是否显示手势图
    public var normalFrame = CGRect.init(x: 0, y: 0, width: _ScreenW, height: _ScreenW/16*9)//正常frame
    public var fullScreenFrame = CGRect.init(x: 0, y: 0, width: _ScreenH, height: _ScreenW)//全屏frame
}

@objc public enum DCPlayerState: Int {
    case notSetURL          //未设置URL
    case startToPlay         //允许开始播放
    case readyToPlay        //系统加载完开始一段视频 准备好了播放
    case playing               //播放中
    case paused               //暂停中
    case playedToTheEnd  //播放结束
    case buffering             //缓冲中
    case bufferFinished     //缓冲完毕
    case error                  //出现错误
}

//MARK:-一些工具
func __CurVC() -> UIViewController! {//获取当前所在VC 有UITabBarController和UINavigationController
    if let rootVC = __keyWindow.rootViewController {
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

let __keyWindow = UIApplication.shared.delegate!.window!!
let _ScreenBounds = UIScreen.main.bounds
let _ScreenSize   = _ScreenBounds.size
let _ScreenW  = _ScreenSize.width
let _ScreenH = _ScreenSize.height

extension UIView {
    
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

extension Double {
    var timeStr: String {
        let miniter = Int(self/60)
        let second = Int(truncatingRemainder(dividingBy: 60))
        return "\(miniter < 10 ? "0" : "")\(miniter):\(second < 10 ? "0" : "")\(second)"
    }
}

extension String {
    var img: UIImage {
        return UIImage.init(named: self, in: Bundle.init(url: Bundle.init(for: DCPlayerV.self).url(forResource: "PlayerImgs", withExtension: "bundle")!)!, compatibleWith: nil)!
    }
}
