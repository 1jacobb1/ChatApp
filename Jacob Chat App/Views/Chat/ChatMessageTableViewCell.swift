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
    @IBOutlet weak var viewTriangle: Triangle!
    @IBOutlet weak var triangleLeading: NSLayoutConstraint!
    @IBOutlet weak var triangleTrailing: NSLayoutConstraint!
    
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
        viewTriangle.backgroundColor = .clear
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
            
            viewTriangle.transform = CGAffineTransform(scaleX: 1, y: 1)
            NSLayoutConstraint.activate([triangleTrailing])
            NSLayoutConstraint.deactivate([triangleLeading])
            
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
            viewTriangle.transform = CGAffineTransform(scaleX: -1, y: 1)
            lblSender.textAlignment = .left
            
            NSLayoutConstraint.activate([triangleLeading])
            NSLayoutConstraint.deactivate([triangleTrailing])
        }
    }
}

struct ChatMessage {
    var sender = ""
    var message = ""
    var isOwn = true
}

class Triangle: UIView {
    var fillColor = UIColor.init(hex: "89E307")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        debugPrint("triangle: frame: \(frame)")
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        debugPrint("triangle: draw: \(rect)")
        let height = rect.height
        let width = rect.width
        let path = UIBezierPath()
        let p1 = CGPoint(x: 0, y: 0)
        path.move(to: p1)
        let p2 = CGPoint(x: 0, y: height)
        path.addLine(to: p2)
        let p3 = CGPoint(x: width, y: height/2)
        path.addLine(to: p3)
        let p4 = CGPoint(x: 0, y: 0)
        path.addLine(to: p4)
        fillColor.setFill()
        path.close()
        path.fill()
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
