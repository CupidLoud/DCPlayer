//
//  DCHomeVC.swift
//  DCPlayer
//
//  Created by JunWin on 2018/5/15.
//  Copyright © 2018年 freeWorld2018. All rights reserved.
//

import UIKit

class DCHomeVC: DCVC, UITableViewDelegate, UITableViewDataSource {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "\(type(of: self))", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    deinit {
        print("\(type(of: self))控制器释放 \(String(describing: navigationItem.title))")
    }
    //MARK:-核心
    //MARK:-控制
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DCVideoVC()
        vc.videoUrl = videoUrl
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK:-数据
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = videoUrl
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
    
    @IBOutlet weak var tv: UITableView!
    let videoUrl = "http://chuangqiyun.oss-cn-shenzhen.aliyuncs.com/2018-05-11/87C4DMG4rB.mp4"
}
