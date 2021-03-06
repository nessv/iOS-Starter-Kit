//
//  SecondViewController.swift
//  iOS Starter Kit
//
//  Created by nessvaldez on 12/14/17.
//  Copyright © 2017 Sodep. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let GITHUBAPI = "https://api.github.com/repos/googlesamples/android-RuntimePermissions/issues"

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var number: UILabel!
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var data = [Item]()
    var currentSelectedCell: Int?
    var refresher: UIRefreshControl!
    @IBOutlet weak var openSideMenu: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noItemView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        openSideMenu.target = self.revealViewController()
        openSideMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        revealViewController().rearViewRevealWidth = 250
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.getTableData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        tableView.tableFooterView = UIView()
        getTableData()

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ItemTableViewCell
        cell?.title!.text = data[indexPath.row].title
        cell?.number!.text = data[indexPath.row].number
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.backgroundView = noItemView
        } else {
            tableView.backgroundView = nil
        }
        return data.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedCell = indexPath.row
        performSegue(withIdentifier: "showBodySegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BodyViewController {
            // swiftlint:disable:next line_length
            let text = data[currentSelectedCell!].body == "" ? "No hay descripción para este issue" : data[currentSelectedCell!].body
            let titleText = data[currentSelectedCell!].title == "" ? "Sin titutlo" : data[currentSelectedCell!].title
            destination.bodyText = text
            destination.issueTitle = titleText
        }
    }
    @objc func getTableData() {
        Alamofire.request(GITHUBAPI).responseJSON { (response) in
            if response.result.isSuccess {
                let githubJSON: JSON = JSON(response.result.value!)
                self.updateTableData(json: githubJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    func updateTableData(json: JSON) {
        data.removeAll()

        if let numberOfElements = (json.array?.count), numberOfElements != 0 {
            for i in 0...numberOfElements - 1 {
                let cellData = Item()
                cellData.title = json[i]["title"].stringValue
                cellData.body = json[i]["body"].stringValue
                cellData.number = ("#"+json[i]["number"].stringValue)
                data.append(cellData)
            }
        }
        refresher.endRefreshing()
        tableView.reloadData()
    }
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {}
}
