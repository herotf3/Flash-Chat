//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

class Message {
    
    //MARK: Props
    var messageBody=""
    var sender=""
    init(msg:String,sender:String) {
        self.messageBody=msg
        self.sender=sender
    }
    
    
    
}
