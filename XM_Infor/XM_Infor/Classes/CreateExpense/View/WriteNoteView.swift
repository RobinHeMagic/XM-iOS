//
//  WriteNoteView.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/7/8.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class WriteNoteView: UIView{
    var placeholderLabel:UILabel?
    var callBack:((String)->())?
    @IBOutlet weak var myTextView: UITextView!
    @IBAction func returnBtn(_ sender: Any) {
        callBack!("")
    }
    @IBOutlet weak var cancelTopConsttaint: NSLayoutConstraint!
    @IBOutlet weak var addNoteTopConstrant: NSLayoutConstraint!
    
    class func loadXibWriteNoteView() -> WriteNoteView {
        return Bundle.main.loadNibNamed("WriteNoteView", owner: self, options: nil)?.last as! WriteNoteView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        load_init()
    }
}

extension WriteNoteView:UITextViewDelegate{
    func load_init() {
        myTextView.becomeFirstResponder()
        myTextView.backgroundColor = UIColor.white
        myTextView.frame = CGRect(x:0,y:88,width:UIScreen.main.bounds.size.width,height:UIScreen.main.bounds.size.height - 455)
        myTextView.textAlignment = .left
        myTextView.textColor = UIColor.red
        myTextView.font = UIFont(name: "GillSans", size: 15.0)
      
        myTextView.tintColor = UIColor.green
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.isScrollEnabled = true
        myTextView.showsHorizontalScrollIndicator = true
        myTextView.showsVerticalScrollIndicator = true
        myTextView.delegate = self
        myTextView.keyboardType = .webSearch
        myTextView.returnKeyType = .done
      
        if SCREEN_HEIGHT != 812 {
            cancelTopConsttaint.constant = 20
            addNoteTopConstrant.constant = 20
        }
        
        let accessoryview = UIButton(frame: CGRect(x:0.0, y:0.0, width:self.bounds.width, height:60.0))
//        accessoryview.backgroundColor = UIColor.init(patternImage: UIImage(named: "navigationBarBG")!)
        accessoryview.setTitle("done", for: .normal)
        accessoryview.addTarget(self, action: #selector(doneClick), for:.touchUpInside)
        myTextView.inputAccessoryView = accessoryview
        placeholderLabel = UILabel()
        placeholderLabel?.frame = CGRect(x:140 , y:100, width:UIScreen.main.bounds.size.width - 10, height:20)
        placeholderLabel?.font = UIFont.systemFont(ofSize: 13)
        placeholderLabel?.text = "Please write a note..."
        myTextView.addSubview(self.placeholderLabel!)
    }
    
    func doneClick() {
        
        postNotificationName(name: "WriteDoneNotification", andUserInfo: ["text":myTextView.text])
        
         callBack!("")
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("1 textViewShouldBeginEditing")
        placeholderLabel?.isHidden = true
        return true
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
////        print("2 textViewDidBeginEditing")
//        // doNothing
//    }
//
//
//    func textViewDidChange(_ textView: UITextView) {
////        print("3 textViewDidChange")
//        // doNothing
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("4 textView")
        print("text：\(textView.text) length = \(String(describing: textView.text?.characters.count))")
    
        if text == "\n"
        {
            textView.resignFirstResponder()
            return true
        }
        return true
    }
    
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//
////        print("5 textViewShouldEndEditing")
//
//        return true
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
      placeholderLabel?.isHidden = !textView.text.isEmpty
//
//        if textView.text.isEmpty {
//
//            placeholderLabel?.isHidden = false
//        }
//        else{
//            placeholderLabel?.isHidden = true
//        }
//
//        print("6 textViewDidEndEditing")
    }

}
