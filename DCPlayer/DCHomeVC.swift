//
//  DCHomeVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/15.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    deinit {
//        topMesV.showMes("\(type(of: self)) \(String(describing: navigationItem.title))")
    }
    //MARK:-核心
    //MARK:-控制
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let haq = myHaq.haqs[indexPath.row]
        let vc = DCVideoVC()
        vc.myHaq = haq
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK:-数据
    func loadStart() {

        let netHaq = DCHaqi()
        netHaq.videoUrl = "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4"
        netHaq.name = "网络视频"
        myHaq.haqs += [netHaq]
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myHaq.haqs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let haq = myHaq.haqs[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = haq.name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    //MARK:-UI
    func setUI() {
        self.title = "🌾"
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    var myHaq = DCHaqi()
    @IBOutlet weak var tv: UITableView!
}
