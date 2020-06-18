//
//  ChatViewController.swift
//  Jacob Chat App
//
//  Created by FDC Jacob on 6/16/20.
//  Copyright © 2020 FDC Jacob. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextViewDelegate {

    /// MARK: - visible outlets
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var txtViewChat: UITextView!
    @IBOutlet weak var txtViewChatHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblTxtViewChatPlaceholder: UILabel!
    @IBOutlet weak var viewMessageContainerBottom: NSLayoutConstraint!
    
    /// MARK: - public variables
    private var initialAdd = true
    var messages = [ChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.layer.cornerRadius = 8
        btnLogout.layer.cornerRadius = 8
        txtViewChat.delegate = self
        textViewDidChange(txtViewChat)
        initializeTable()
        self.autoHideKeyboard(cancelTouchesInView: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            viewMessageContainerBottom.constant = keyboardFrame.height - self.getSafeMargins().bottom
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func willHideKeyboard() {
        viewMessageContainerBottom.constant = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func initializeTable() {
        tblChat.delegate = self
        tblChat.dataSource = self
        
        let cell = UINib.init(nibName: "ChatMessageTableViewCell", bundle: nil)
        tblChat.register(cell, forCellReuseIdentifier: "ChatMessageTableViewCell")
        
        initialAdd = true
        
        DataManager.shared.ref.child("messages").queryOrderedByKey().queryLimited(toLast: 20).observe(.childAdded, with: { snapshot in
            let dict = snapshot.value as? NSDictionary ?? [:]
            let sender = dict["sender"] as? String ?? ""
            let message = dict["message"] as? String ?? ""
            let isOwn = sender == DataManager.shared.getUsernameAsId()
            
            let chatMessage = ChatMessage(sender: sender, message: message, isOwn: isOwn)
            self.messages.append(chatMessage)
            
            if (!self.initialAdd) {
                self.tblChat.reloadData()
                if self.tblChat.contentOffset.y >= (self.tblChat.contentSize.height - self.tblChat.frame.size.height) {
                    self.tblChat.layoutIfNeeded()
                    let height = self.tblChat.contentSize.height
                    self.tblChat.scrollRectToVisible(CGRect(x: 0, y: height - 1, width: 1, height: 1) , animated: true)
                }
            }
        })
        
        DataManager.shared.ref.child("messages").observeSingleEvent(of: .value, with: { snapshot in
            self.tblChat.reloadData()
            self.initialAdd = false
            self.tblChat.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0) , at: .top, animated: false)
        })
    }
    
    /// MARK: - textview delegate
    let maxTextViewHeight: CGFloat = 150
    func textViewDidChange(_ textView: UITextView) {
        if textView == txtViewChat {
            // - get the estimated height
            let size = CGSize(width: textView.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            var constant: CGFloat = 35
            
            // - text view post height
            if estimatedSize.height <= 35 {
                constant = 35
            } else if estimatedSize.height >= maxTextViewHeight {
                constant = maxTextViewHeight
            } else if estimatedSize.height < maxTextViewHeight {
                constant = estimatedSize.height
            }
            
            // - hide shows placeholder
            lblTxtViewChatPlaceholder.isHidden = !textView.text.isEmpty
            txtViewChatHeight.constant = constant
            
            // - apply size
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func doLogout(_ sender: UIButton) {
        if let del = UIApplication.shared.delegate as? AppDelegate {
            del.redirectToSignupPage()
        }
    }
    
    var isSending = false
    @IBAction func sendMessageAction(_ sender: UIButton) {
        let msg = txtViewChat.text ?? ""
        if msg.isEmpty || isSending {
            return
        }
      
        // - set to true, to disable sending new message while there's still ongoing request
        isSending = true
        
        DataManager.shared.sendChat(message: msg)
        .done { response in
            self.txtViewChat.text = ""
        }
        .catch { error in
        }
        .finally {
            self.isSending = false
            self.textViewDidChange(self.txtViewChat)
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageTableViewCell", for: indexPath) as? ChatMessageTableViewCell else {
            return UITableViewCell()
        }
        var chatMessage = messages[indexPath.row]
        cell.chatMessage = chatMessage
        return cell
    }
}

extension UIViewController {
    func getSafeMargins() -> UIEdgeInsets {
        // - initialize insets
        var curSafeInsets = UIEdgeInsets.init()
        
        // - declare safe frame for iphone x
        if #available(iOS 11.0, *){
            let window = UIApplication.shared.keyWindow
            
            // - check if window has insets
            if let _ = window?.safeAreaInsets {
                curSafeInsets = (window?.safeAreaInsets)!
            }
        }
        
        // - return safe insets
        return curSafeInsets
    }
}
