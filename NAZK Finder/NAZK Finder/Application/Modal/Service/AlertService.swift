//
//  AlertService.swift
//  NAZK Finder
//
//  Created by Yaroslav Babiy on 28.08.2021.
//

import Foundation
import UIKit

class AlertService {
    private init() {}
    
    static func addCommentAlert(rootVC: UIViewController, person: SearchPerson, completion: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: "Add a coment", message: "Comment", preferredStyle: .alert)
        
        let alertOkAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            
            let textField = alertController.textFields![0] as UITextField
            
            if let row = ListViewController.favoritedPeople.firstIndex(where: {$0.id == person.id}) {
                ListViewController.favoritedPeople[row].comment = textField.text
            }
            
            completion(true)
        })
        alertController.addAction(alertOkAction)
        
        alertController.addTextField { commentTF in
            commentTF.placeholder = "Your comment"
        }
        
        rootVC.present(alertController, animated: true, completion: nil)
    }
}
