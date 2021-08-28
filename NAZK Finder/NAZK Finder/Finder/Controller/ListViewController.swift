//
//  ListViewController.swift
//  NAZK Finder
//
//  Created by Yaroslav Babiy on 28.08.2021.
//

import UIKit
import SafariServices

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    static var favoritedPeople = [SearchPerson]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTableView()
        tableView.reloadData()
    }
    
    func setupTableView(){
        
        tableView.frame = self.view.bounds
        tableView.register(UINib(nibName: SearchPeopleCell.identifier, bundle: nil), forCellReuseIdentifier: SearchPeopleCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListViewController.favoritedPeople.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchPeopleCell.identifier, for: indexPath) as! SearchPeopleCell
        
        var person: SearchPerson
        
        cell.delegate = self
        person = ListViewController.favoritedPeople[indexPath.item]
        cell.configure(with: person)
        cell.configureFavorited()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let person = ListViewController.favoritedPeople[indexPath.item]
        AlertService.addCommentAlert(rootVC: self, person: person) { [weak self] status in
            self?.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.isUserInteractionEnabled = false
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}

extension ListViewController: SearchDelegate, SFSafariViewControllerDelegate {
    
    func viewDeclaration(person: SearchPerson) {
        
        let url = URL(string: "https://public-api.nazk.gov.ua/v2/documents/\(person.id)")!
        let controller = SFSafariViewController(url: url)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    func addToFavorited(person: SearchPerson) {
        
        AlertService.addCommentAlert(rootVC: self, person: person) { [weak self] status in
            self?.tableView.reloadData()
        }
        ListViewController.favoritedPeople.append(person)
    }
    
    func removeFromFavorited(person: SearchPerson) {
        ListViewController.favoritedPeople =  ListViewController.favoritedPeople.filter(){$0.id != person.id}
        tableView.reloadData()
    }
}
