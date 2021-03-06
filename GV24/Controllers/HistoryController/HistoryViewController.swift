//
//  HistoryViewController.swift
//  GV24
//
//  Created by HuyNguyen on 5/29/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class HistoryViewController: BaseViewController {
    
    var user:User?
    var workList: [Work] = []
    var myParent: ManagerHistoryViewController?
    var page: Int = 1
    var limit: Int = 10
    var startAtDate: Date? = nil
    var endAtDate: Date = Date()
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var fromDateContainer: UIView!
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        // configure
        indicator.hidesWhenStopped = true
       return indicator
    }()
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(HistoryViewController.updateOwnerList), for: UIControlEvents.valueChanged)
        return refresh
    }()
    
    lazy var emptyLabel: UILabel = {
        let label = TableViewHelper().emptyMessage(message: "", size: self.historyTableView.bounds.size)
        label.textColor = UIColor.colorWithRedValue(redValue: 109, greenValue: 108, blueValue: 113, alpha: 1)
        label.isHidden = true
        return label
    }()
    lazy var emptyDataView: UIView = {
        let emptyView = TableViewHelper().noData(frame: CGRect(x: self.view.frame.size.width/2 - 20, y: 50, width: 100, height: 150))
        emptyView.isHidden = true
        return emptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getWorkList(startAt: startAtDate, endAt: endAtDate)
        
        // add loading indicator at here
        setupLoadingIndicator()
        setupEmptyDataView()
        setupEmptyLabel()
    }
    
    func setupLoadingIndicator() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
    }
    
    func setupEmptyDataView() {
        view.addSubview(emptyDataView)
    }
    
    func setupEmptyLabel(){
        view.addSubview(emptyLabel)
    }
    
    func showLoadingIndicator() {
        if !self.refreshControl.isRefreshing {
            self.activityIndicatorView.startAnimating()
        }
    }
    
    func hideLoadingIndicator() {
        self.activityIndicatorView.stopAnimating()
    }
    
    func updateUI(status: ResultStatus) {
        switch status {
        case .Success:
//            self.historyTableView.isHidden = false
            self.emptyDataView.isHidden = true
            self.emptyLabel.isHidden = true
        case .EmptyData:
//            self.historyTableView.isHidden = true
            self.emptyDataView.isHidden = false
            self.emptyLabel.isHidden = true
            break
        case .LostInternet:
            self.emptyLabel.text = "NetworkIsLost".localize
//            self.historyTableView.isHidden = true
            self.emptyDataView.isHidden = true
            self.emptyLabel.isHidden = false
        default:
            self.emptyLabel.text = "TimeoutExpiredPleaseLoginAgain".localize
//            self.historyTableView.isHidden = true
            self.emptyDataView.isHidden = true
            self.emptyLabel.isHidden = false
            break
        }
        self.historyTableView.reloadData()
    }
    func setupTableView() {
        historyTableView.register(UINib(nibName: NibHistoryViewCell,bundle:nil), forCellReuseIdentifier: historyCellID)
//        self.automaticallyAdjustsScrollViewInsets = false
//        historyTableView.tableFooterView = UIView()
        self.historyTableView.refreshControl = self.refreshControl
//        self.historyTableView.addSubview(self.refreshControl)
        historyTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: historyTableView.bounds.size.width, height: 0.01))
//        self.historyTableView.backgroundColor = UIColor.red
        self.historyTableView.separatorStyle = .singleLine
    }
    
    func updateOwnerList() {
        self.refreshControl.beginRefreshing()
        self.page = 1
        self.getWorkList(startAt: startAtDate, endAt: endAtDate)
        self.refreshControl.endRefreshing()
    }
    
    override func decorate() {}
    
    override func setupViewBase() {}
    
    /* /maid/getHistoryTasks
     Params: startAt (opt), endAt (opt): ISO Date, page, limit: Number
     */
    func getWorkList(startAt: Date?, endAt: Date) {
        showLoadingIndicator()
        user = UserDefaultHelper.currentUser
        var params:[String:Any] = [:]
        if startAt != nil {
            params["startAt"] = "\(String.convertDateToISODateType(date: startAt!)!)"
        }
        params["endAt"] = "\(String.convertDateToISODateType(date: endAt)!)"
        params["page"] = self.page
        params["limit"] = self.limit
        let headers: HTTPHeaders = ["hbbgvauth": "\(UserDefaultHelper.getToken()!)"]
        HistoryServices.sharedInstance.getListWith(object: Work(), url: APIPaths().urlGetWorkListHistory(), param: params, header: headers) { (data, status) in
            
            let stat: ResultStatus = (self.net?.isReachable)! ? status : .LostInternet
            
            if stat == .Success {
                self.workList = data!
//                if self.page != 1 {
//                    self.workList.append(contentsOf: data!)
//                }else {
//                    self.workList = data!
//                }
            }
            DispatchQueue.main.async {
                self.updateUI(status: stat)
                self.hideLoadingIndicator()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "WorkHistory".localize//"Lịch sự công việc"
    }
    fileprivate func configureCell(cell: HistoryViewCell, indexPath: IndexPath) {
        let work = workList[indexPath.item]
        if let imageString = work.info?.workName?.image {
            let url = URL(string: imageString)
            cell.imageWork.kf.setImage(with: url, placeholder: UIImage(named: "nau an"), options: nil, progressBlock: nil, completionHandler: nil)
            cell.lbDeadline.isHidden = true
        }

        cell.lbDeadline.isHidden = true

        cell.workNameLabel.text = work.info?.title
        let startAt = work.workTime?.startAt
        let startAtString = String(describing: startAt!)
        let endAt = work.workTime?.endAt
        let endAtString = String(describing: endAt!)
        cell.timeWork.text = String.convertISODateToString(isoDateStr: startAtString, format: "HH:mm a")! + " - " + String.convertISODateToString(isoDateStr: endAtString, format: "HH:mm a")!
         cell.lbTimePost.text = "\(Date().dateComPonent(datePost: (work.workTime?.startAt)!))"
        cell.lbDist.text = "CompletedWork".localize
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.workList.count - 1 {
            self.page = self.page + 1
            //self.getWorkList(startAt: self.startAtDate, endAt: self.endAtDate)
        }
    }
}
extension HistoryViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: historyCellID, for: indexPath) as! HistoryViewCell
        self.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = FinishedWorkViewController()
        vc.work = workList[indexPath.item]
        _ = myParent?.navigationController?.pushViewController(vc, animated: true)
    }
}
extension HistoryViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
