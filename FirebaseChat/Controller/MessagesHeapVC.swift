//
//  MessagesHeapVC.swift
//  FirebaseChat
//
//  Created by Stanly Shiyanovskiy on 14.10.17.
//  Copyright © 2017 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

final class MessagesHeapVC: JSQMessagesViewController, UISearchBarDelegate {
    
    // MARK: - Properties -
    var searchBar: UISearchBar!
    var model = MessagesModel()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        model.load(self)
        searchBarCustom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topContentAdditionalInset = 22.0
        // animates the receiving of a new message on the view
        finishReceivingMessage()
        model.observeTyping(self)
    }
    
    deinit {
        model.removeObservers()
    }
    
    // MARK: - Collection view data source (and related) methods -
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return model.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return model.messageBubble(indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = model.bubbleColor(indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        return model.bubbleAttributedText(indexPath)
    }
    
    // MARK: - SearchBar -
    func searchBarCustom() {
        searchBar = model.createSearchBar(self)
        searchBar.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let result = model.searchBarTextDidChange(searchText, sender: self)
        if result {
            searchBar.endEditing(true)
        }
        collectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        model.didPressSend(text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
        finishSendingMessage()
    }
    
    // MARK: - UITextViewDelegate methods -
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        model.isTyping = textView.text != ""
    }
    
    // MARK: - Actions -
    @IBAction func exit(_ sender: UIButton) {
        model.clearUser()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        self.present(vc, animated: true, completion: nil)
    }
}
