//
//  BigImageBrowserPC.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/9/4.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class BigImageBrowserPC: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    var scrow:UIScrollView?
    var pageCon = UIPageControl()
    
    var phoneItems = [UIImage]()
    
    var currentImageV = UIImageView()
    var currentImage:UIImage?
    var currenctIndex = 0
    var tapgest = UITapGestureRecognizer()
    var imageViewItems:NSMutableArray = []
    var selectCurrentClosure:((UIImage,Int,UIScrollView,Bool,UIImageView) ->())?
    var isSelectPhoto = false
    var oldFrame:CGRect?
    var collectView:UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
            initView()
            initData()
            addTapGestureRecognizer()
    }
    
    func addTapGestureRecognizer(){
        tapgest.addTarget(self, action: #selector(tapgestClick))
        currentImageV.isUserInteractionEnabled = true
        currentImageV.addGestureRecognizer(tapgest)
    }
    
    
    deinit {
        print("BigImageBrowserPC--deinit")
    }
    
    func tapgestClick() {
        self.removeFromParentViewController()
        UIView.animate(withDuration: 0.5, animations: {
            self.currentImageV.frame = CGRect(x:20 + CGFloat(self.pageCon.currentPage) * SCREEN_WIDTH, y: 84, width: 70, height: 70)
            self.currentImageV.y = SCREEN_HEIGHT == 812 ? 108 : 84

            self.pageCon.removeFromSuperview()
        }) { (bo) in
            self.view.backgroundColor = UIColor.clear
            self.view.removeFromSuperview()
            self.selectCurrentClosure!(self.phoneItems[self.pageCon.currentPage],self.pageCon.currentPage,self.scrow!,self.isSelectPhoto,self.currentImageV)
        }

    }
   
    func initView(){
        
        view.backgroundColor = UIColor.black

        scrow = UIScrollView()
        scrow?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        scrow?.contentSize = CGSize(width:CGFloat(phoneItems.count) * SCREEN_WIDTH, height: 0)
        scrow?.isPagingEnabled = true
        scrow?.showsHorizontalScrollIndicator = false
        scrow?.bounces = false
        scrow?.delegate = self
        view.addSubview(scrow!)
        scrow?.setContentOffset(CGPoint(x:CGFloat(currenctIndex) * SCREEN_WIDTH,y:0), animated: true)
        
        pageCon.frame = CGRect(x: 0, y: 450, width: SCREEN_WIDTH, height: 30)
        pageCon.isUserInteractionEnabled = false
        pageCon.numberOfPages = phoneItems.count
        pageCon.pageIndicatorTintColor = UIColor.lightGray
        pageCon.currentPageIndicatorTintColor = UIColor.white
        view.addSubview(pageCon)
        
        let deleteBtn = UIButton()
        deleteBtn.frame = CGRect(x: SCREEN_WIDTH - 70, y: 25, width: 60, height: 30)
        deleteBtn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        deleteBtn.setTitle("delete", for: [])
        view.addSubview(deleteBtn)

    }
    
    func btnClick() {
        
        
        
    }
    
    
    func initData(){
        for _ in phoneItems {
            imageViewItems.add(UIImageView())
        }
      let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = phoneItems[currenctIndex]
        imageView.frame = CGRect(x:20 + CGFloat(currenctIndex) * SCREEN_WIDTH, y: 84, width: 70, height: 70)
        imageView.y = SCREEN_HEIGHT == 812 ? 108 : 84
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        scrow?.addSubview(imageView)
        currentImageV = imageView
        imageViewItems.replaceObject(at: currenctIndex, with: imageView)
        for i in 0..<phoneItems.count {
            if i == currenctIndex {
                continue
            }
            let imageV = UIImageView()
            imageV.isUserInteractionEnabled = true
            imageV.image = phoneItems[i]
            imageV.contentMode = .scaleAspectFill
            imageV.clipsToBounds = true
            let newWidth = SCREEN_WIDTH
            let newHeight = newWidth / (phoneItems[i].size.width * 1.0 / phoneItems[i].size.height)
            let yPosition = (SCREEN_HEIGHT - newHeight) / 2.0
            imageV.frame = CGRect(x: SCREEN_WIDTH * CGFloat(i), y: yPosition, width: newWidth, height: newHeight)
            scrow?.addSubview(imageV)
            imageViewItems.replaceObject(at: i, with: imageV)
        }
    }
  
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCon.currentPage = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
        
        currentImageV = imageViewItems[pageCon.currentPage] as! UIImageView

        tapgest.addTarget(self, action: #selector(tapgestClick))
        currentImageV.isUserInteractionEnabled = true
        currentImageV.addGestureRecognizer(tapgest)
    }
    
    
    func presentViewControllerAnimated(curentImgView:UIImageView, animated:Bool) {
        
        UIApplication.shared.keyWindow?.addSubview(self.view)
        self.pageCon.currentPage = self.currenctIndex
        
        currentImage = curentImgView.image

        UIView.animate(withDuration: 0.5) {
            let newWidth = SCREEN_WIDTH
            let newHeight = newWidth / ((self.currentImage?.size.width)! * 1.0 / (self.currentImage?.size.height)!)
            let yPosition = (SCREEN_HEIGHT - newHeight) / 2.0
        
            self.currentImageV.frame = CGRect(x:  SCREEN_WIDTH * CGFloat(self.currenctIndex), y: yPosition, width: newWidth, height: newHeight)
        }

        
    }

}

extension BigImageBrowserPC{

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phoneItems.count
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: SCREEN_WIDTH, height: 300)
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectCollectionViewCell", for: indexPath) as! SelectCollectionViewCell

        cell.backgroundColor = UIColor.yellow
        cell.selectImageV?.image = phoneItems[indexPath.row]
        cell.selectImageV?.isUserInteractionEnabled = true
        
        let newWidth = SCREEN_WIDTH
        let newHeight = newWidth / (phoneItems[indexPath.row].size.width * 1.0 / phoneItems[indexPath.row].size.height)
        
        
        cell.selectImageV?.frame = CGRect(x: SCREEN_WIDTH * CGFloat(indexPath.row), y: 0, width: SCREEN_WIDTH, height: newHeight)

        
        
        return cell
    }




}


