//
//  MovieQuotesTableViewController.swift
//  MovieQuotes
//
//  Created by FengYizhi on 2018/3/29.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import UIKit
import Firebase

class MovieQuotesTableViewController: UITableViewController {
    
    var quoteRef: CollectionReference!
    var quoteListener: ListenerRegistration!
    
    let movieQuoteCellIdentifier = "MovieQuoteCell"
    let noMovieQuoteCellIdentifier = "NoMovieQuoteCell"
    let showDetailSegueIdentifier = "ShowDetailSegue"
    var movieQuotes = [MovieQuote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(showAddDialog))
        
        //        movieQuotes.append(MovieQuote(quote: "I'll be back", movie: "The Terminator"))
        //        movieQuotes.append(MovieQuote(quote: "Yo Adrian!", movie: "Rocky"))
        quoteRef = Firestore.firestore().collection("quotes")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quoteListener = quoteRef.order(by: "created", descending: true).limit(to: 50)
            .addSnapshotListener({ (querySnapshot, error) in
                guard let snapshot = querySnapshot else {
                    print("Error fetching quotes.  error: \(error!.localizedDescription)")
                    return
                }
                snapshot.documentChanges.forEach({ (docChange) in
                    if docChange.type == .added {
                        print("New quote: \(docChange.document.data())")
                        self.quoteAdded(docChange.document)
                    } else if docChange.type == .modified {
                        print("Modified quote: \(docChange.document.data())")
                        self.quoteUpdated(docChange.document)
                    } else if docChange.type == .removed {
                        print("Removed quote: \(docChange.document.data())")
                        self.quoteRemoved(docChange.document)
                    }
                })
                self.movieQuotes.sort(by: { (mq1, mq2) -> Bool in
                    return mq1.created > mq2.created
                })
                self.tableView.reloadData()
            })
    }
    
    func quoteAdded(_ document: DocumentSnapshot) {
        let newMovieQuote = MovieQuote(documentSnapshot: document)
        movieQuotes.append(newMovieQuote)
    }
    
    func quoteUpdated(_ document: DocumentSnapshot) {
        let modifiedMovieQuote = MovieQuote(documentSnapshot: document)
        for movieQuote in movieQuotes {
            if movieQuote.id == modifiedMovieQuote.id {
                movieQuote.quote = modifiedMovieQuote.quote
                movieQuote.movie = modifiedMovieQuote.movie
                break
            }
        }
    }
    
    func quoteRemoved(_ document: DocumentSnapshot) {
        for i in 0..<movieQuotes.count {
            if movieQuotes[i].id == document.documentID {
                movieQuotes.remove(at: i)
                break
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quoteListener.remove()
    }
    
    @objc func showAddDialog() {
        let alertController = UIAlertController(title: "Create a new movie quote",
                                                message: "",
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Quote"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Movie Title"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        let createQuoteAction = UIAlertAction(title: "Create Quote",
                                              style: .default)
        { (action) in
            let quoteTextField = alertController.textFields![0]
            let movieTextField = alertController.textFields![1]
            let movieQuote = MovieQuote(quote: quoteTextField.text!,
                                        movie: movieTextField.text!)
            self.quoteRef.addDocument(data: movieQuote.data)
            //            self.movieQuotes.insert(movieQuote, at:0)
            //            if self.movieQuotes.count == 1 {
            //                self.tableView.reloadData()
            //                self.setEditing(false, animated: true)
            //            } else {
            //                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            //            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createQuoteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        if movieQuotes.count == 0 {
            super.setEditing(false, animated: animated)
        } else {
            super.setEditing(editing, animated: animated)
        }
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(movieQuotes.count, 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if movieQuotes.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: noMovieQuoteCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: movieQuoteCellIdentifier, for: indexPath)
            cell.textLabel?.text = movieQuotes[indexPath.row].quote
            cell.detailTextLabel?.text = movieQuotes[indexPath.row].movie
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return movieQuotes.count > 0
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            movieQuotes.remove(at: indexPath.row)
            if movieQuotes.count == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)}
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == showDetailSegueIdentifier {
            // Pass the selected movie quote to the detail view controller.
            if let indexPath = tableView.indexPathForSelectedRow {
                (segue.destination as! MovieQuoteDetailViewController).movieQuote = movieQuotes[indexPath.row]
                //                if let detailVC = segue.destination as? MovieQuoteDetailViewController {
                //                    detailVC.movieQuote = movieQuotes[indexPath.row]
                //                }
            }
        }
    }
    
}
