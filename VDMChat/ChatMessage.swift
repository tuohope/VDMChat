//
//  ChatMessage.swift
//  VDMChat
//
//  Created by Tuo on 2017-06-12.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class ChatMessage: NSObject, Comparable {
    let message:String;
    let nickname:String;
    let time:Date;
    
    init(msg: String, nickname: String, time: Double) {
        self.message = msg
        self.nickname = nickname
        self.time = Date(timeIntervalSince1970: time);
    }
    
    
    static func < (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time < rhs.time;
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.time == rhs.time;
    }
}
