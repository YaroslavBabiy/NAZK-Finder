//
//  SearchPeopleCell.swift
//  NAZK Finder
//
//  Created by Yaroslav Babiy on 28.08.2021.
//

import UIKit

class SearchPeopleCell: UITableViewCell {

    static let identifier = "SearchPeopleCell"
    
    static func nib()-> UINib{
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var starBtn: UIButton!
    
    var person: SearchPerson?
    var delegate: SearchDelegate!
    var isMarked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    public func configureSearch() {
        commentLabel.isHidden = true
    }
    
    public func configureFavorited() {
        commentLabel.isHidden = false
        if person != nil {
            commentLabel.text = person?.comment
            commentLabel.sizeToFit()
        }
    }
    
    public func configure(with person: SearchPerson){
        
        self.person = person
        self.nameLabel.text = person.lastname + " " + person.firstname
        self.post.text = person.workPost
        post.sizeToFit()
        
        isMarked = ListViewController.favoritedPeople.contains(where: { $0.id == person.id })
        if isMarked {
            starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    @IBAction func viewDeclarationTapped(_ sender: UIButton) {
        if person != nil {
            delegate.viewDeclaration(person: person!)
        }
    }
    
    @IBAction func addToFavoritedTapped(_ sender: UIButton) {
        if person != nil {
            if isMarked {
                starBtn.setImage(UIImage(systemName: "star"), for: .normal)
                delegate.removeFromFavorited(person: person!)
            } else {
                starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                delegate.addToFavorited(person: person!)
            }
        }
    }
}
