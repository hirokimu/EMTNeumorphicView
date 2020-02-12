//
//  TableViewController.swift
//
//  Created by Hironobu Kimura on 2020/01/20.
//  Copyright © 2020 Emotionale. All rights reserved.
//

import UIKit
import EMTNeumorphicView

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                UINavigationControllerDelegate {

    private var table: UITableView?
    var rowData: [[String: Any]] = [
        [
            "depthType": EMTNeumorphicLayerDepthType.concave,
            "rows": ["cornerType = .all"],
            "edged": true
        ],
        [
            "depthType": EMTNeumorphicLayerDepthType.convex,
            "rows": ["cornerType = .topRow", "cornerType = .middleRow", "cornerType = .middleRow", "cornerType = .bottomRow"],
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(RGB: 0xF0EEEF)
        let table = UITableView(frame: CGRect(), style: .grouped)
        view.insertSubview(table, at: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            table.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        table.clipsToBounds = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return rowData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rows = rowData[section]["rows"] as? [String] else { return 0 }
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 360 : 0
    }
 
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = UIView()
            
            let button0 = EMTNeumorphicButton(type: .custom)
            header.addSubview(button0)
            button0.setImage(UIImage(named: "heart-outline"), for: .normal)
            button0.setImage(UIImage(named: "heart-solid"), for: .selected)
            button0.contentVerticalAlignment = .fill
            button0.contentHorizontalAlignment = .fill
            button0.imageEdgeInsets = UIEdgeInsets(top: 26, left: 24, bottom: 22, right: 24)
            button0.translatesAutoresizingMaskIntoConstraints = false
            button0.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            // set parameters
            button0.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor ?? UIColor.white.cgColor
            button0.neumorphicLayer?.cornerRadius = 22.5

            let button1 = EMTNeumorphicButton(type: .custom)
            header.addSubview(button1)
            button1.setImage(UIImage(named: "heart-outline"), for: .normal)
            button1.setImage(UIImage(named: "heart-solid"), for: .selected)
            button1.contentVerticalAlignment = .fill
            button1.contentHorizontalAlignment = .fill
            button1.imageEdgeInsets = UIEdgeInsets(top: 26, left: 24, bottom: 22, right: 24)
            button1.translatesAutoresizingMaskIntoConstraints = false
            button1.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            // set parameters
            button1.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor ?? UIColor.white.cgColor
            button1.neumorphicLayer?.cornerRadius = 22.5
            button1.isSelected = true

            let button2 = EMTNeumorphicButton(type: .custom)
            header.addSubview(button2)
            button2.setImage(UIImage(named: "play"), for: .normal)
            button2.contentVerticalAlignment = .fill
            button2.contentHorizontalAlignment = .fill
            button2.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            button2.translatesAutoresizingMaskIntoConstraints = false
            // set parameters
            button2.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor ?? UIColor.white.cgColor
            button2.neumorphicLayer?.cornerRadius = 40

            NSLayoutConstraint.activate([
                button0.widthAnchor.constraint(equalToConstant: 100),
                button0.heightAnchor.constraint(equalToConstant: 100),
                button0.topAnchor.constraint(equalTo: header.topAnchor, constant: 64),
                button0.centerXAnchor.constraint(equalTo: header.centerXAnchor, constant: -50 - 16),
                button1.widthAnchor.constraint(equalToConstant: 100),
                button1.heightAnchor.constraint(equalToConstant: 100),
                button1.topAnchor.constraint(equalTo: header.topAnchor, constant: 64),
                button1.centerXAnchor.constraint(equalTo: header.centerXAnchor, constant: 50 + 16),
                button2.widthAnchor.constraint(equalToConstant: 80),
                button2.heightAnchor.constraint(equalToConstant: 80),
                button2.topAnchor.constraint(equalTo: button0.bottomAnchor, constant: 64),
                button2.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            ])
            return header
        }
        return nil
    }
    
    @objc func tapped(_ button: EMTNeumorphicButton) {
        button.isSelected = !button.isSelected
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var type: EMTNeumorphicLayerCornerType = .all
        let dict: [String: Any] = rowData[indexPath.section]
        let rows = dict["rows"] as? [String] ?? []
        if rows.count > 1 {
            if indexPath.row == 0 {
                type = .topRow
            }
            else if indexPath.row == rows.count - 1 {
                type = .bottomRow
            }
            else {
                type = .middleRow
            }
        }
        let cellId = String(format: "cell%d", type.rawValue)

        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = EMTNeumorphicTableCell(style: .default, reuseIdentifier: cellId)
        }
        if let cell = cell as? EMTNeumorphicTableCell {
            cell.neumorphicLayer?.cornerType = type
            cell.neumorphicLayer?.cornerRadius = 12
            cell.neumorphicLayer?.depthType = dict["depthType"] as? EMTNeumorphicLayerDepthType ?? .convex
            cell.neumorphicLayer?.edged = dict["edged"] as? Bool ?? false
            cell.neumorphicLayer?.elementBackgroundColor = view.backgroundColor?.cgColor ?? UIColor.white.cgColor
        }
        cell?.textLabel?.text = rows[indexPath.row]
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
