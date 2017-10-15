//
//  MessagesModel.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 15.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import Foundation
import Firebase
import JSQMessagesViewController

protocol MessagesProtocol {
    func load(_ sender: JSQMessagesViewController)
    func createSearchBar(_ sender: JSQMessagesViewController) -> UISearchBar
    func noAvatars(_ sender: JSQMessagesViewController)
    func removeObservers()
    func messageBubble(_ indexPath: IndexPath) -> JSQMessageBubbleImageDataSource
    func bubbleColor(_ indexPath: IndexPath) -> UIColor
    func bubbleAttributedText(_ indexPath: IndexPath) -> NSAttributedString?
}

class MessagesModel: MessagesProtocol {
    var senderId = ""
    var messages = [JSQMessage]()
    var heapRef: DatabaseReference = Database.database().reference().child("heap")
    private lazy var messageRef: DatabaseReference = self.heapRef.child("messages")
    private lazy var userIsTypingRef: DatabaseReference = self.heapRef.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery = self.heapRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private var newMessageRefHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var isInSearch: Bool = false
    
    func load(_ sender: JSQMessagesViewController) {
        senderId = (Auth.auth().currentUser?.uid)!
        sender.senderId = senderId
        // hide add item button
        sender.inputToolbar.contentView.leftBarButtonItem = nil
        sender.senderDisplayName = userName()
        noAvatars(sender)
        observeMessages(sender)
    }
    
    func createSearchBar(_ sender: JSQMessagesViewController) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск по тексту в сообщении..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        sender.view.addSubview(searchBar)
        
        let views = ["searchBar" : searchBar]
        searchBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[searchBar(44)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        sender.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[searchBar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        sender.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: sender.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        return searchBar
    }
    
    func searchBarTextDidChange(_ text: String, sender: JSQMessagesViewController) -> Bool {
        if text == "" {
            isInSearch = false
            observeMessages(sender)
            return true
        } else {
            isInSearch = true
            findMessages(text, sender: sender)
            return false
        }
    }
    
    func noAvatars(_ sender: JSQMessagesViewController) {
        sender.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        sender.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    func removeObservers() {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func messageBubble(_ indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    func bubbleColor(_ indexPath: IndexPath) -> UIColor {
        let message = messages[indexPath.item]
        return message.senderId == senderId ? UIColor.white : UIColor.black
    }
    
    func bubbleAttributedText(_ indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    // MARK: - Firebase related methods -
    func observeMessages(_ sender: JSQMessagesViewController) {
        messageRef = heapRef.child("messages")
        
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                sender.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    func findMessages(_ searchText: String, sender: JSQMessagesViewController) {
        messages.removeAll()
        messageRef = heapRef.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                if (text.containsIgnoringCase(searchText)) {
                    self.addMessage(withId: id, name: name, text: text)
                    sender.finishReceivingMessage()
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    func observeTyping(_ sender: JSQMessagesViewController) {
        let typingIndicatorRef = heapRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // Are there others typing?
            sender.showTypingIndicator = data.childrenCount > 0
            sender.scrollToBottom(animated: true)
        }
    }
    
    func didPressSend(_ text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        isTyping = false
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    // MARK: - UI and User Interaction -
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // MARK: - Private methods -
    // set user's name
    private func userName() -> String {
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "userName") {
            return name
        }
        return "Аноним"
    }
    
    func clearUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userName")
    }
}
