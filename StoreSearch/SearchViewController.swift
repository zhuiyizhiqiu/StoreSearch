//
//  ViewController.swift
//  StoreSearch
//
//  Created by 彭军涛 on 2019/3/25.
//  Copyright © 2019 彭军涛. All rights reserved.
//

import UIKit
func < (lhs: SearchResult,rhs: SearchResult) -> Bool{
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var hasSearched = false
    var isLoading = false

    var searchResults = [SearchResult]()
    
    struct TableViewCelllIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCelllIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCelllIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCelllIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCelllIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCelllIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCelllIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK:- Private Methods
    func iTunesURL(searchText: String) -> URL{
        let endcodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limt=200", endcodedText)
        let url = URL(string: urlString)
        return url!
    }

    func performStoreRequest(with url: URL) -> Data?{
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        do{
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch{
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops.....", message: "There was an error accessing the iTunes Store." + "Please try again", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }

}

extension SearchViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            isLoading = true
            tableView.reloadData()

            hasSearched = true
            searchResults = []
            
            let queue = DispatchQueue.global()
            let url = iTunesURL(searchText: searchBar.text!)
            queue.async {
                print("URL:\(url)")
                if let data = self.performStoreRequest(with: url){
                    self.searchResults = self.parse(data: data)
                    self.searchResults.sort(by: <)
                    self.searchResults.sort { (result1, result2) -> Bool in
                        return result1.type.localizedStandardCompare(result2.type) == .orderedAscending
                    }
                    print("searchResult: \(self.searchResults)")
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.tableView.reloadData()
                }
            }

//            isLoading = false
//            tableView.reloadData()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched{
            return 0
        }else if searchResults.count == 0{
            return 1
        }else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCelllIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableViewCelllIdentifiers.nothingFoundCell, for: indexPath)
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCelllIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.trackName.isEmpty{
                cell.artistNameLabel.text = "Unknow"
            }else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName!, searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }else{
            return indexPath
        }
    }
}
