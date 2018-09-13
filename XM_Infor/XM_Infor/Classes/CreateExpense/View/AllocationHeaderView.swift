//
//  AllocationHeaderView.swift
//  XM_Infor
//
//  Created by Robin He on 07/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
@objc
protocol AllocationHeaderViewDelegate:NSObjectProtocol {
    
   @objc optional func AllocationHeaderAmountSwitch(switch:UISwitch?)
    
}

class AllocationHeaderView: UIView {

    var subPerLabelitems = [UILabel]() // percentBar subviews
    
    var subPerLabelFrameitems = [String]()
    
    var subPerLabelColorStrItems = [String]()
    
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    weak var delegate:AllocationHeaderViewDelegate?
    @IBOutlet weak var percentBvar: UIView!
   
    
    let subPercentLabel = UILabel()
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.insertSublayer(getGradientColorGradientLayer(w: 375, h: 200, view: self), at: 0)
        percentBvar.backgroundColor = UIColor.darkGray
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePercentBvar), name: NSNotification.Name(rawValue: "amountTextfieldEndEditing"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEditingPercentBvar), name: NSNotification.Name(rawValue: "amountTextfieldEditingDelete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePushPercentBvar), name: NSNotification.Name(rawValue: "amountTextfieldPushEditing"), object: nil)

    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

}

extension AllocationHeaderView{
    
    func updatePushPercentBvar(noti:NSNotification)  {
        
        subPerLabelFrameitems = (noti.userInfo! as NSDictionary).object(forKey: "SubPerLabItems") as! [String]
        subPerLabelColorStrItems = (noti.userInfo! as NSDictionary).object(forKey: "colorStrItems") as! [String]

        for (i,str) in subPerLabelFrameitems.enumerated() {
            let lab = UILabel()
            let rec = CGRectFromString(str)
            lab.frame = rec
            lab.backgroundColor = UIColor.randomRGBWithRGBStr(subPerLabelColorStrItems[i])
            UIView.animate(withDuration: 0.5, animations: {
                self.percentBvar.addSubview(lab)
            })

            subPerLabelitems.append(lab)
        
        }
    }
    
    
    func updatePercentBvar(noti:NSNotification) {
      
        let subPerLabel = UILabel()
        subPerLabel.backgroundColor = (noti.userInfo! as NSDictionary).object(forKey: "markLabColor") as? UIColor
        let textAcountItems = (noti.userInfo! as NSDictionary).object(forKey: "amountTextfieldItems") as! NSMutableArray
        let creatAmount = (noti.userInfo! as NSDictionary).object(forKey: "totalMoney") as! String
        let str = NSString(string:creatAmount)
        if textAcountItems.count > subPerLabelitems.count  {
             subPerLabelitems.append(subPerLabel)
        }
        for (i,Label) in subPerLabelitems.enumerated() {
            Label.x = 0
            Label.x += subPercentLabel.x + subPercentLabel.width
            Label.y = 0
            Label.width = CGFloat((textAcountItems[i] as AnyObject).floatValue) * CGFloat(300.0 / str.floatValue)
            Label.height = percentBvar.height
            subPercentLabel.x = Label.x
            subPercentLabel.width = Label.width
            UIView.animate(withDuration: 0.5, animations: {
                 self.percentBvar.addSubview(Label)
            })
        
        }
        subPercentLabel.x = 0
        subPercentLabel.width = 0
    
    }
 
    // delete cell
    func updateEditingPercentBvar(noti:NSNotification) {

        let textAcountItems = (noti.userInfo! as NSDictionary).object(forKey: "amountTextfieldItems") as! NSMutableArray
        let creatAmount = (noti.userInfo! as NSDictionary).object(forKey: "totalMoney") as! String
        
        let str = NSString(string:creatAmount)
        
        if (noti.userInfo! as NSDictionary).object(forKey: "isDelete") as! Bool == true {
            let inPRow = (noti.userInfo! as NSDictionary).object(forKey: "indexPRow") as! Int
            subPerLabelitems.remove(at: inPRow)
            percentBvar.subviews[inPRow].removeFromSuperview()
        }
        
        for (i,Label) in subPerLabelitems.enumerated() {
            Label.x = 0
            Label.x += subPercentLabel.x + subPercentLabel.width
            Label.y = 0
            Label.width = CGFloat((textAcountItems[i] as AnyObject).floatValue) * CGFloat(300.0 / str.floatValue)
            Label.height = percentBvar.height
            subPercentLabel.x = Label.x
            subPercentLabel.width = Label.width
            UIView.animate(withDuration: 0.5, animations: {
                self.percentBvar.addSubview(Label)
            })
            
        }
        subPercentLabel.x = 0
        subPercentLabel.width = 0

    }
    
    func switchClick(swit:UISwitch) {
        
        delegate?.AllocationHeaderAmountSwitch?(switch: swit)
    }


}
