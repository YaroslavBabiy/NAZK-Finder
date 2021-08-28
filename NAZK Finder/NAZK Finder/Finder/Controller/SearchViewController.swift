//
//  SearchViewController.swift
//  NAZK Finder
//
//  Created by Yaroslav Babiy on 27.08.2021.
//

import UIKit
import SafariServices

protocol SearchDelegate: AnyObject {
    func viewDeclaration(person: SearchPerson)
    func addToFavorited(person: SearchPerson)
    func removeFromFavorited(person: SearchPerson)
}

class SearchViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    
    let statusLabel = UILabel()
    let tableView = UITableView()
    
    var isEmptySearching = false
    
    var filteredNames = [SearchPerson]()
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        setupStatusLabel()
        
        setupObservers()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.text = nil
        statusLabel.center = view.center
        tableView.alpha = 0
        setupStartStatusLabel()
    }
    
    func setupObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
    }
    
    func setupTableView(){
        
        tableView.frame = self.view.bounds
        tableView.register(UINib(nibName: SearchPeopleCell.identifier, bundle: nil), forCellReuseIdentifier: SearchPeopleCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.alpha = 0
        
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if let info = notification.userInfo{
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            let h = UIApplication.shared.keyWindow!.safeAreaLayoutGuide.layoutFrame.size.height
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: rect.height, right: 0)
            UIView.animate(withDuration: 0.3,
                           animations: { [weak self] in
                            self?.statusLabel.frame.origin.y = (h - (rect.height + 40 - self!.navigationController!.navigationBar.frame.size.height)) / 2
                            self?.view.layoutIfNeeded()
                            self?.tableView.frame.origin.y = -40
                           })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        tableView.alpha = 0
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.statusLabel.center = self!.view.center
                        self?.view.layoutIfNeeded()
                       })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupStatusLabel() {
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .black
        statusLabel.font = statusLabel.font.withSize(16)
        view.addSubview(statusLabel)
        statusLabel.textAlignment = .center
        statusLabel.frame.size.width = UIScreen.main.bounds.width - 30
        statusLabel.frame.size.height = 20
        statusLabel.center = view.center
        statusLabel.text = "Enter the first or last name"
    }
    
    func setupStartStatusLabel() {
        statusLabel.text = "Enter the first or last name"
        statusLabel.alpha = 1
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        searchController.searchBar.tintColor = .lightGray
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension SearchViewController {
    
   
}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    fileprivate func requestCountry(_ text: String) {
        
        let txtAppend = (text).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://public-api.nazk.gov.ua/v2/documents/list?query=\(txtAppend!)")!
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            
            if error != nil, let error = error as NSError? {
                DispatchQueue.main.async {
                    self?.statusLabel.text = error.localizedDescription
                    self?.tableView.alpha = 0
                    self?.statusLabel.alpha = 1
                }
            }
            
            guard let data = data else { return }
            
            let response: PersonResponse = try! JSONDecoder().decode(PersonResponse.self, from: data)
            
            var searchPeople = [SearchPerson]()
            
            if response.error == nil {
                if response.data != nil {
                    if response.data!.count != 0 {
                        for person in response.data! {
                            searchPeople.append(SearchPerson(id: person.id, firstname: person.data.step_1.data.firstname, user_declarant_id: person.user_declarant_id, lastname: person.data.step_1.data.lastname, workPost: person.data.step_1.data.workPost, comment: nil))
                        }
                        
                        self?.filteredNames = searchPeople
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                                self?.tableView.alpha = 1
                                self?.tableView.frame.origin.y = -40
                                self?.statusLabel.alpha = 0
                                self?.tableView.reloadData()
                            })
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.statusLabel.text = "No results"
                            self?.tableView.alpha = 0
                            self?.statusLabel.alpha = 1
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func filterContentForSearchText(searchText: String){
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count > 3 {
            requestCountry(searchText)
        } else {
            setupStartStatusLabel()
            tableView.alpha = 0
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchPeopleCell.identifier, for: indexPath) as! SearchPeopleCell
        
        var person: SearchPerson
        
        cell.delegate = self
        if isFiltering {
            person = filteredNames[indexPath.item]
            cell.configure(with: person)
            cell.configureSearch()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchViewController: SearchDelegate, SFSafariViewControllerDelegate {
    
    func viewDeclaration(person: SearchPerson) {
        
        let url = URL(string: "https://public-api.nazk.gov.ua/v2/documents/\(person.id)")!
        let controller = SFSafariViewController(url: url)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
    }
    
    func addToFavorited(person: SearchPerson) {
        
        AlertService.addCommentAlert(rootVC: self, person: person) { [weak self] status in
            self?.statusLabel.center = self!.view.center
            self?.setupStartStatusLabel()
            self?.tableView.alpha = 0
            self?.searchController.searchBar.text = nil
        }
        ListViewController.favoritedPeople.append(person)
    }
    
    func removeFromFavorited(person: SearchPerson) {
        ListViewController.favoritedPeople =  ListViewController.favoritedPeople.filter(){$0.id != person.id}
    }
}
