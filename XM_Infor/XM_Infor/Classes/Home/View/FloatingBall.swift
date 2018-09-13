//
//  FloatingBall.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
@objc
protocol FloatingBallDelegate:NSObjectProtocol {
    @objc optional func FloatingBallClicked(isClick:Bool,isHome:Bool)
}
class FloatingBall: UIButton {
    // singleton
   static let shared = FloatingBall()
   var isClick = false
//   var isHome = true
   weak var delegate:FloatingBallDelegate?
    override private init(frame: CGRect) {
        super.init(frame: frame)
        self.setBackgroundImage(UIImage(named:"addBtn"), for: .normal)
        self.frame =  CGRect(x: SCREEN_WIDTH - getLength(leng: 85), y: SCREEN_HEIGHT - getLength(leng: 85), width: 45, height: 45)
        addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func btnAction() {
        isClick = !isClick
        self.setBackgroundImage(UIImage(named:(isClick ? "closeBtn" : "addBtn")), for: .normal)
        delegate?.FloatingBallClicked!(isClick: isClick, isHome: false)
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for anyObject in touches {
//            let offset = anyObject.location(in: self.superview)
//            self.center = CGPoint(x: offset.x, y: offset.y)
//            isClick = true
//        }
//        
//    }
    
}
