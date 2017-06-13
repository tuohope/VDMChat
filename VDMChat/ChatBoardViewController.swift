//
//  ChatBoardViewController.swift
//  VDMChat
//
//  Created by Tuo on 2017-06-12.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit
import FirebaseDatabase


class ChatBoardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextViewDelegate  {
    
    
    @IBOutlet weak var inputViewHeight: NSLayoutConstraint!
    @IBOutlet weak var inputViewSpaceToBtm: NSLayoutConstraint!
    @IBOutlet weak var msgTable: UITableView!
    @IBOutlet weak var msgInputView: UITextView!

    var messages:[ChatMessage] = [];

    override func viewDidLoad() {
        super.viewDidLoad()

        self.msgTable.dataSource = self;
        self.msgTable.delegate = self;
        
        msgInputView.delegate = self;
        msgInputView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        msgTable.estimatedRowHeight = 44
        msgTable.rowHeight = UITableViewAutomaticDimension

        
        let rootRef = Database.database().reference(withPath: "messages");

        rootRef.observe(DataEventType.value, with: {snapshot in
            guard let snapshotValue = snapshot.value as? [String: AnyObject] else{
                return;
            }
            
            self.messages.removeAll()
            
            for i in snapshotValue{
                var value = i.value as! [String:Any];
                print(value)
                
                let msg = value["message"] as! String
                let name = value["nickname"] as! String
                let time = value["time"] as! Double
                self.messages.append(ChatMessage.init(msg: msg, nickname: name, time: time))
            }
            self.messages.sort(by:<);
            self.msgTable.reloadData();
            self.msgTable.scrollToBottom();
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self);
    }
    
    @IBAction func SendPressed(_ sender: Any) {
        guard let msg = msgInputView.text, !msg.isEmpty  else{
            print("input is empty");
            return;
        }
        print(msg);
        msgInputView.text = "";
        textViewDidChange(self.msgInputView);
        
        let rootRef = Database.database().reference(withPath: "messages");

        let msgRef = rootRef.childByAutoId()
        
        guard let nickname = AppManager.sharedInstance.nickname, !nickname.isEmpty else {
            let value = ["message":msg,"time":Date().timeIntervalSince1970,"nickname":"Anonymous"] as Any;
            msgRef.setValue(value);
            return;
        }
        
        let value = ["message":msg,"time":Date().timeIntervalSince1970,"nickname":nickname] as Any;
        msgRef.setValue(value);
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let msg = messages[indexPath.row];
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell")!

        let cellTextLabel = cell.viewWithTag(1) as! UILabel;
        cellTextLabel.text = msg.nickname + " : " + msg.message
        
        return cell;
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        let layoutManager:NSLayoutManager = msgInputView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var numberOfLines = 0
        var index = 0
        var lineRange:NSRange = NSRange()
        
        while (index < numberOfGlyphs) {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines = numberOfLines + 1
        }

        if (numberOfLines <= 1){
            inputViewHeight.constant = 30;
        }else if (numberOfLines >= 8){
            inputViewHeight.constant = CGFloat(13 + (8 * 17));
        }else {
            inputViewHeight.constant = CGFloat(13 + (numberOfLines * 17));
        }
        var frame = textView.frame;
        frame.size.height = self.inputViewHeight.constant;
        textView.frame = frame;
        self.msgInputView.contentOffset = CGPoint.init(x: 0, y: textView.contentSize.height - textView.bounds.size.height)
    }
    


    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.inputViewSpaceToBtm.constant = keyboardSize.height;
                self.view.layoutIfNeeded()
            },completion: nil)

        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: {
            self.inputViewSpaceToBtm.constant = 0;
            self.view.layoutIfNeeded()
        },completion: nil)
    }
}

extension UITableView {
    func scrollToBottom() {
        let sections = numberOfSections-1
        if sections >= 0 {
            let rows = numberOfRows(inSection: sections)-1
            if rows >= 0 {
                let indexPath = IndexPath(row: rows, section: sections)
                DispatchQueue.main.async { [weak self] in
                    self?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
}
