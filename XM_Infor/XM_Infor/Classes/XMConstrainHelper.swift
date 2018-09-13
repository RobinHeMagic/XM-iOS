//
//  XMConstrainHelper.swift
//  XM_Infor
//
//  Created by Robin He on 14/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class XMConstrainHelper: NSObject {

    class func setView(aview:UIView,fullAsSuperView asuperView:UIView) {
    
        setView(view: aview, fullAsSuperView: asuperView, andEdgeInsets:.zero)
    }
    
    class func setView(view:UIView,fullAsSuperView superView:UIView,andEdgeInsets Insets:UIEdgeInsets) {
       
        view.translatesAutoresizingMaskIntoConstraints = false
        var metrics = [String:Any]()
        metrics["hLeftEdge"] = Insets.left
        metrics["hRightEdge"] = Insets.right
        metrics["vTopEdge"] = Insets.top
        metrics["vBottomEdge"] = Insets.bottom
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(hLeftEdge)-[aview]-(hRightEdge)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["aview":view]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(vTopEdge)-[aview]-(vBottomEdge)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["aview":view]))
        
        
    }
    
   
}
