//
//  ChatMessageTableViewCell.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/16/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class ChatMessageTableViewCell: UITableViewCell {

    ///MARK: - visible outlets and its constraints
    /// for message
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet var lblMessageTrailing: NSLayoutConstraint!
    @IBOutlet var lblMessageLeading: NSLayoutConstraint!
    @IBOutlet weak var lblMessageWidth: NSLayoutConstraint!
    @IBOutlet weak var viewMessageBubble: UIView!
    let messageMaxWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    
    /// for sender
    @IBOutlet weak var lblSender: UILabel!
    
    var chatMessage: ChatMessage! {
        didSet {
            lblMessage.text = self.chatMessage.message
            lblSender.text = self.chatMessage.sender
            messageOwn(isOwn: self.chatMessage.isOwn)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewMessageBubble.layer.cornerRadius = 10
    }
    
    func messageOwn(isOwn: Bool = true) {
        lblMessageWidth.constant = messageMaxWidth
        if isOwn {
            
            if lblMessageTrailing != nil {
                NSLayoutConstraint.activate([
                    lblMessageTrailing
                ])
            }

            if lblMessageLeading != nil {
                NSLayoutConstraint.deactivate([
                    lblMessageLeading
                ])
            }
            lblSender.textAlignment = .right
        } else {
            if lblMessageLeading != nil {
                NSLayoutConstraint.activate([
                    lblMessageLeading
                ])
            }

            if lblMessageTrailing != nil {
                NSLayoutConstraint.deactivate([
                    lblMessageTrailing
                ])
            }
            lblSender.textAlignment = .left
        }
    }
}

struct ChatMessage {
    var sender = ""
    var message = ""
    var isOwn = true
}
