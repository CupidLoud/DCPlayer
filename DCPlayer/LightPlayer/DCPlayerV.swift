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
 */

import UIKit
import MediaPlayer

class DCPlayerV: UIView {
    
    deinit {
        print("播放控件已释放 \(type(of: self))")
        releasePlayer()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
    }
    //MARK:-核心
    func releasePlayer() {//释放
        if videoItem != nil {
            playerState = .notSetURL
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: dcPlayer!.currentItem)
            dcPlayer!.currentItem?.removeObserver(self, forKeyPath: "status")
            dcPlayer!.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            dcPlayer!.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
            dcPlayer!.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            dcPlayer!.removeTimeObserver(timeObserver)
            cancelWillDisaperControlV()
            videoItem = nil
            dcPlayer = nil
            totalTime = 999
        }
    }
    
    func initPlayer() {//初始化
        releasePlayer()
        
        videoItem = AVPlayerItem.init(url: URL.init(string: videoUrl)!)//初始化AVPlayerItem
        //各种状态监听
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
//            if !__CurVC().isKind(of: DCVideoVC.self) {//如果不在播放界面就暂停
//                self!.videoPause(true)
//                return
//            }
            self!.isShowBuffV = false
            print("CMTimeGetSeconds(curTime): \(CMTimeGetSeconds(curTime))")
            self!.leftTimeL.text = CMTimeGetSeconds(curTime).timeStr
            self!.sliderV.setValue(Float(CMTimeGetSeconds(curTime)/self!.totalTime), animated: true)
            self!.playingTimeBlock?(CMTimeGetSeconds(curTime), self!.totalTime)
        }
    }
    //MARK:-控制
    @IBAction func startOrBtnDo(_ sender: UIButton) {
        isHandOn = true
        if playerState == .notSetURL {
            playerState = .startToPlay
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
        playFineBlock?()
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
    func seek(_ toTime: Double, isPlay: Bool) {//调到time播放
        isShowBuffV = true
        sliderV.setValue(Float(toTime/totalTime), animated: true)
        dcPlayer!.seek(to: CMTime.init(seconds: toTime, preferredTimescale: CMTimeScale(1)))
        if isPlay {
            playerState = .playing
        }
    }
    @IBAction func sliderChange(_ sender: UISlider) {//拖动进度条中
        sliderChangeTime = Double(sliderV.value)*totalTime
        isPanVertical = true
    }
    @IBAction func sliderEnd(_ sender: UISlider) {//拖动进度条完成
        seek(Double(sliderV.value)*totalTime, isPlay: true)
        isPanVertical = false
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
                case "loadedTimeRanges":
                    progressV.setProgress(Float(loadDataProgress), animated: true)
                case "playbackBufferEmpty":
                    playerState = .buffering
                case "playbackLikelyToKeepUp":
                    playerState = .bufferFinished
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
    
    func videoPause(_ byHand: Bool) {//暂停
        if videoItem != nil {
            isHandOn = byHand
            playerState = .paused
            showControlVAfter(999)
        }
    }
    //MARK:-数据
    func loadStart(_ videoStr: String) {
        videoUrl = videoStr
        nameL.text = "轻量视频播放控件"
        playerState = .startToPlay
    }
    //MARK:-UI
    func setUI() {//初始化界面
        sliderV.setThumbImage(#imageLiteral(resourceName: "Player_slider_thumb"), for: UIControlState())
        
        lowControlV.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        progressV.progressTintColor = UIColor.white.withAlphaComponent(0.6)
        progressV.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        
        nameLL.constant = UIDevice.current.isX() ? 15 : 0
        
        for view in MPVolumeView().subviews {
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
    func showPlayerMes(_ mes: String, autoDisaper: Bool) {//播放控件内提示
        hudL.alpha = 1
        hudL.text = mes
        if autoDisaper {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.hudL.animatDisaper()
            }
        }
    }
    @objc func controlVDisaper() {//隐藏控制界面
        topControlV.animatDisaper()
        if rePlayBtn.alpha == 0 && bufferingV.alpha == 0 {
            playCenterBtn.animatDisaper()
        }
        lowControlV.animatDisaper()
        isHiddenStatusBar = isFullScreen
    }
    func controlVShow() {//显示控制界面
        nameL.alpha = 1
        topControlV.animatShow()
        if rePlayBtn.alpha == 0 && bufferingV.alpha == 0 {
            playCenterBtn.animatShow()
        }
        lowControlV.animatShow()
        isHiddenStatusBar = false
    }
    func showControlVAfter(_ time: Double) {//显示控制界面 并自动消失
        if videoItem != nil {
            controlVShow()
            cancelWillDisaperControlV()
            perform(#selector(controlVDisaper), with: nil, afterDelay: time)
        }
    }
    func cancelWillDisaperControlV() {//释放控制界面自动消失任务  不取消可能会导致播放控件无法释放
        if videoItem != nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(controlVDisaper), object: nil)
        }
    }
    //MARK:-变量
    var playerState = DCPlayerState.notSetURL {//播放控件所处状态
        didSet {
            switch playerState {
            case .notSetURL:
                hudL.animatDisaper()
            case .readyToPlay://系统加载完开始一段视频 准备好了播放
                totalTime = CMTimeGetSeconds(videoItem.duration)
                
                startOrBtnDo(playCenterBtn)
                if !videoGesImaV.isHidden {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.controlVDisaper()
                        UIView.animate(withDuration: 3, animations: {
                            self.videoGesImaV.alpha = 1
                            self.videoGesImaV.alpha = 0.5
                        }, completion: { (finish) in
                            self.videoGesImaV.alpha = 0
                            self.videoGesImaV.isHidden = true
                        })
                    }
                }
            case .startToPlay://手动开始播放
                initPlayer()
                
                isShowBuffV = true
                self.playerState = .playing
            case .playing:
                dcPlayer!.play()
                rePlayBtn.alpha = 0
                playCenterBtn.setImage(#imageLiteral(resourceName: "Player_pause"), for: .normal)
                bigImgV.animatDisaper()
                isHandOn = false
            case .paused:
                isShowBuffV = false
                playCenterBtn.setImage(#imageLiteral(resourceName: "Player_play"), for: .normal)
                dcPlayer!.pause()
            case .buffering:
                isShowBuffV = true
            case .bufferFinished:
                if !isHandOn {
                    self.playerState = .playing
                }
            case .error:
                isShowBuffV = false
                showPlayerMes(":( 视频不见了\n请重试或联系客服", autoDisaper: false)
            default:
                return
            }
        }
    }
    
    var isFullScreen: Bool = false {//是否全屏
        didSet {
            fullBtn.setImage(isFullScreen ?  #imageLiteral(resourceName: "Player_portialscreen") :  #imageLiteral(resourceName: "Player_fullscreen"), for: .normal)
            __CurVC().navigationController?.interactivePopGestureRecognizer?.isEnabled = !isFullScreen
            DispatchQueue.main.async {
                self.frame = self.isFullScreen ? CGRect.init(x: 0, y: 0, width: __MainScreenHeight, height: __MainScreenWidth) : CGRect.init(x: 0, y: UIDevice.current.isX() ? 42 : 0, width: __MainScreenWidth, height: __MainScreenWidth/16*9)
                self.dcVideoLayer.frame = self.bounds
            }
        }
    }
    
    var isHiddenStatusBar = false {//是否隐藏状态栏
        didSet {
            UIView.animate(withDuration: 0.3) {
                __CurVC().setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    var totalTime: Double = 999 {//总时间
        didSet {
            rightTimeL.text = totalTime.timeStr
        }
    }
    var loadDataProgress: Double {//视频数据加载进度
        let timeRange = videoItem.loadedTimeRanges.last?.timeRangeValue
        let loadTime = CMTimeAdd(timeRange!.start, timeRange!.duration)
        return CMTimeGetSeconds(loadTime)/totalTime
    }
    
    var isShowBuffV: Bool = false {//是否显示视频加载中界面
        didSet {
            if isShowBuffV {
                playCenterBtn.alpha = 0
                bufferingV.animatShow()
            }else{
                bufferingV.animatDisaper()
            }
        }
    }

    var sliderChangeTime: Double = 0 {
        didSet {
            leftTimeL.text = sliderChangeTime.timeStr
            videoPause(true)
            rePlayBtn.alpha = 0
        }
    }
    
    var videoUrl = ""
    var playingTimeBlock: ((Double, Double)->())?//播放中每秒调用一次
    var playFineBlock: (()->())?//播完
    
    @IBOutlet weak var controlV: UIView!//控制界面
    @IBOutlet weak var topControlV: UIView!//控制界面上部分
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var nameLL: NSLayoutConstraint!//nameLab距离相对下界面距离
    @IBOutlet weak var rateBtn: UIButton!//切换速率
    @IBOutlet weak var bigImgV: UIImageView!//视频图片
    @IBOutlet weak var playCenterBtn: UIButton!//播放暂停
    @IBOutlet weak var rePlayBtn: UIButton!//重播
    @IBOutlet weak var bufferingV: UIActivityIndicatorView!//加载中界面
    @IBOutlet weak var hudL: UILabel!//提示lab
    @IBOutlet weak var lowControlV: UIView!//控制界面下部分
    @IBOutlet weak var leftTimeL: UILabel!
    @IBOutlet weak var sliderV: UISlider!//播放控制进度条
    @IBOutlet weak var progressV: UIProgressView!//加载进度条
    @IBOutlet weak var rightTimeL: UILabel!//总时间
    @IBOutlet weak var fullBtn: UIButton!
    @IBOutlet weak var videoGesImaV: UIView!
    
    var videoItem: AVPlayerItem!
    var dcPlayer: AVPlayer!
    var dcVideoLayer: AVPlayerLayer!
    var timeObserver: Any!//播放中时间监听者
    let rates = ["0.8", "1.0", "1.5", "2.0", "2.5", "3.0"]
    let brightV = DCBrightChangeV.sharedV//亮度调节界面
    var volumeSlider: UISlider!//音量调节界面

    var isHandOn = true//是否手动操作
    var isPanVertical = false//是否水平拖动手势
}

@objc public enum DCPlayerState: Int {
    case notSetURL          //未设置URL
    case readyToPlay        //系统加载完开始一段视频 准备好了播放
    case startToPlay        //开始播放
    case buffering              //缓冲中
    case bufferFinished     //缓冲完毕
    case playing                //播放中
    case paused             //暂停中
    case playedToTheEnd // 播放结束
    case error                  // 出现错误
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
let __MainScreenBounds = UIScreen.main.bounds
let __MainScreenSize   = __MainScreenBounds.size
let __MainScreenWidth  = __MainScreenSize.width
let __MainScreenHeight = __MainScreenSize.height

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}

extension UIView {
    
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

extension Double {
    var timeStr: String {
        let miniter = Int(self/60)
        let second = Int(self.truncatingRemainder(dividingBy: 60))
        return "\(miniter < 10 ? "0" : "")\(miniter):\(second < 10 ? "0" : "")\(second)"
    }
}
