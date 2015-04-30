//
//  EventTableViewCell.swift
//  Zazu Screens
//
//  Created by Gokul Raghuraman on 3/26/15.
//  Copyright (c) 2015 Zazu Labs. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var creatorImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder)
    {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

    func setCell(eventNameText: String, status: String, eventTimeText: String, eventAttendeesText: String, eventCreatorName: String, eventCreatorImage: String)
    {
        self.titleLabel.text = eventNameText
        self.timeLabel.text = eventTimeText
        self.attendeesLabel.text = eventAttendeesText
        self.creatorLabel.text = "created by " + eventCreatorName
        if status == "0"
        {
            statusImageView.hidden = true
        }
        else
        {
            self.statusImageView.image = UIImage(named: "\(status)")
        }
        var profilePic = "\(eventCreatorName).jpg"
        self.creatorImageView.image = UIImage(named: "\(profilePic)")
        self.creatorImageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
}
