//
//  HsuAssetGridViewController.swift
//  SystemAlbum
//
//  Created by Bruce on 2017/4/4.
//  Copyright © 2017年 Bruce. All rights reserved.
//

/// See a photo album, all the images in the folder

import UIKit
import Photos
struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}
typealias HandlePhotos = ([PHAsset], [UIImage]) -> Void
class HandleSelectionPhotosManager: NSObject {
    static let share = HandleSelectionPhotosManager()
    
    var maxCount: Int = 0
    var callbackPhotos: HandlePhotos?
    
    private override init() {
        super.init()
    }
    
    func getSelectedPhotos(with count: Int, callback completeHandle: HandlePhotos? ) {
        // 限制长度
        maxCount = count < 1 ? 1 : (count > 9 ? 9 : count)
        self.callbackPhotos = completeHandle
    }
}
class HsuAssetGridViewController: UIViewController {
    
    // MARK: - 👉Properties
    fileprivate var collectionView: UICollectionView!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    
    // Display select number
    fileprivate var countView: UIView!
    fileprivate var countLabel: UILabel!
    fileprivate var countButton: UIButton!
    fileprivate let countViewHeight: CGFloat = 50
    fileprivate var isShowCountView = false
    
    
    // If only one choice, if it is, the choice of ICONS to each of the pictures don't show
    fileprivate var isOnlyOne = true
    // Choose picture number
    fileprivate var count: Int = 0
    // Select the callback
    fileprivate var handlePhotos: HandlePhotos?
    // callback Asset
    fileprivate var selectedAssets = [PHAsset]() {
        willSet {
            updateCountView(with: newValue.count)
        }
    }
    // callback Image
    fileprivate var selectedImages = [UIImage]()
    
    // select identfienter
    fileprivate var flags = [Bool]()
    
    // itemSize
    fileprivate let shape: CGFloat = 3
    fileprivate let numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat? {
        return (UIScreen.main.bounds.width - (numbersInSingleLine - 1) * shape) / numbersInSingleLine
    }

    // MARK: - 👉Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // set callback
        count = HandleSelectionPhotosManager.share.maxCount
        handlePhotos = HandleSelectionPhotosManager.share.callbackPhotos
        isOnlyOne = count == 1 ? true : false
        
        setupUI()
        
        //Add a number of views
        addCountView()
        
        // Monitoring data source
        if fetchAllPhtos == nil {
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchAllPhtos = PHAsset.fetchAssets(with: allOptions)
            collectionView.reloadData()
        }
        
        (0 ..< fetchAllPhtos.count).forEach { _ in
            flags.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Define the cache photo size
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
//      thumnailSize =  CGSize(width: SCREEN_WIDTH, height:SCREEN_HEIGHT)
        // collectionView 滑动到最底部
//        guard fetchAllPhtos.count > 0 else { return }
//        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
//        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update
        updateCachedAssets()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    // MARK: - 👉Public
    // all photos
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    // A single photo album
    internal var assetCollection: PHAssetCollection!
    
    // MARK: - 👉Private
    
    /// show UI
    private func setupUI() {
        
        UINavigationBar.appearance().tintColor = .white
//        let gradientLayer = getGradientColorGradientLayer(view: UINavigationBar.appearance())
//        UINavigationBar.appearance().layer.insertSublayer(gradientLayer, at: 0)
//        UINavigationBar.appearance().backgroundColor = UIColor.colorWithHexString("2f5e7b")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 1.0), NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
    
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64), collectionViewLayout: cvLayout)
        view.addSubview(collectionView)
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: GridViewCell.cellIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        addCancleItem()
    }
    
    /// count
    private func addCountView() {
        countView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: countViewHeight))
        countView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        view.addSubview(countView)
        
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        countLabel.backgroundColor = .green
        countLabel.layer.masksToBounds = true
        countLabel.layer.cornerRadius = countLabel.bounds.width / 2
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 17)
        countLabel.center = CGPoint(x: countView.bounds.width / 2, y: countView.bounds.height / 2)
        countView.addSubview(countLabel)
        
        countButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: countViewHeight))
        countButton.center = CGPoint(x: countView.bounds.width / 2, y: countView.bounds.height / 2)
        countButton.backgroundColor = .clear
        countButton.addTarget(self, action: #selector(selectedOverAction), for: .touchUpInside)
        countView.addSubview(countButton)
    }
    
    
    /// Photo to choose end
    func selectedOverAction() {
        handlePhotos?(selectedAssets, selectedImages)
        dismissAction()
    }
    
    
    /// According to dynamic display CountView choose photos
    ///
    /// - Parameter photoCount: photoCount description
    private func updateCountView(with photoCount: Int) {
        countLabel.text = String(describing: photoCount)

        if isShowCountView && photoCount != 0 {
            return
        }
        
        if photoCount == 0 {
            isShowCountView = false
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
                self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y - self.countViewHeight)
            })
        } else {
            isShowCountView = true
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.countViewHeight)
                self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y + self.countViewHeight)
            })
        }
    }
    
    /// add cancel button
    private func addCancleItem() {
        let barItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissAction))
        navigationItem.rightBarButtonItem = barItem
    }
    func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // Select number of views

    
    // MARK: PHAsset Caching
    
    /// Reset the image cache
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// Update the image cache Settings
    fileprivate func updateCachedAssets() {
        // Update the view can be accessed
        guard isViewLoaded && view.window != nil else {
            return
        }
        
        //Preload view is the height of the view of two times, so when the sliding wouldn't have blocked
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Only visible and preload views have clearly not at the same time, to be updated
        let delta = abs(preheatRect.maxY - previousPreheatRect.maxY)
        guard delta > view.bounds.height / 3 else {
            return
        }
        
        
        //Calculate the assets used to begin and end the cache
        let (addedRects, removeRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect)}
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        let removedAssets = removeRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        
        // Update image cache
        imageManager.startCachingImages(for: addedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        
        // 保存最新的预加载尺寸用来和后面的对比
        previousPreheatRect = preheatRect
    }
    
    
    /// Calculate the difference between the old and new position
    ///
    /// - Parameters:
    ///   - old: old description
    ///   - new: new description
    /// - Returns: return value description
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        
        // New old intersection
        if old.intersects(new) {
            
            // The added value
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if new.minY < old.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            
            // remove value
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if new.minY > old.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            
            return (added, removed)
        }
        
        // There is no intersection
        return ([new], [old])
    }
    
}

extension HsuAssetGridViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchAllPhtos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridViewCell.cellIdentifier, for: indexPath) as! GridViewCell
        
        let asset = fetchAllPhtos.object(at: indexPath.item)
    
        cell.representAssetIdentifier = asset.localIdentifier
        // From the cache to retrieve images
        imageManager.requestImage(for: asset, targetSize: thumnailSize, contentMode: .aspectFill, options: nil) { img, _ in
        
            // Code execution here cell may already be reused, so set the logo to show
            if cell.representAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = img
                print(img!)
            }
        }
        
        //To prevent the repeat
        if isOnlyOne {
            cell.hiddenIcons()
        } else {
            cell.cellIsSelected = flags[indexPath.item]
            cell.handleSelectionAction = { isSelected in
                
                // Determine whether more than the maximum value
                if self.selectedAssets.count > self.count - 1 && !cell.cellIsSelected {
                    self.showAlert(with: "haha")
                    cell.selectedButton.isSelected = false
                    return
                }
                
                self.flags[indexPath.item] = isSelected
                cell.cellIsSelected = isSelected
                
                if isSelected {
                    self.selectedAssets.append(self.fetchAllPhtos.object(at: indexPath.item))
                    self.selectedImages.append(cell.thumbnailImage!)
                } else {
                    let deleteIndex1 = self.selectedAssets.index(of: self.fetchAllPhtos.object(at: indexPath.item))
                    self.selectedAssets.remove(at: deleteIndex1!)
                    
                    let deleteIndex2 = self.selectedImages.index(of: cell.thumbnailImage!)
                    self.selectedImages.remove(at: deleteIndex2!)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard isOnlyOne else {
//            return
//        }
    
        print(fetchAllPhtos.object(at: indexPath.item))
        let currentCell = collectionView.cellForItem(at: indexPath) as! GridViewCell
        handlePhotos?([fetchAllPhtos.object(at: indexPath.item)], [currentCell.thumbnailImage!])
        print([fetchAllPhtos.object(at: indexPath.item)], [currentCell.thumbnailImage!])
        dismissAction()
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func showAlert(with title: String) {
        let alertVC = UIAlertController(title: "最多只能选择 \(count) 张图片", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

// MARK: - 👉PHPhotoLibraryChangeObserver
extension HsuAssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
    }
}

// MARK: - 👉UICollectionView Extension
private extension UICollectionView {
    
    /// Obtain visible in the view of all the objects for more efficient refresh
    ///
    /// - Parameter rect: rect description
    /// - Returns: return value description
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// MARK: - 👉GridViewCell
class GridViewCell: UICollectionViewCell {
    
    // MARK: - 👉Properties
    private var cellImageView: UIImageView!
    private var selectionIcon: UIButton!
    var selectedButton: UIButton!
    
    private let slectionIconWidth: CGFloat = 20
    
    static let cellIdentifier = "GridViewCell-Asset"
    
    // MARK: - 👉LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - 👉Public
    var representAssetIdentifier: String!
    var thumbnailImage: UIImage? {
        willSet {
            cellImageView?.image = newValue
        }
    }
    
    var cellIsSelected: Bool = false {
        willSet {
            selectionIcon.isSelected = newValue
        }
    }
    
    
    /// Hide option buttons and ICONS
    func hiddenIcons() {
        selectionIcon.isHidden = true
        selectedButton.isHidden = true
    }
    
    // Click on the select callback
    var handleSelectionAction: ((Bool) -> Void)?
    
    // MARK: - 👉Private
    private func setupUI() {
        //
        cellImageView = UIImageView(frame: bounds)
        cellImageView?.clipsToBounds = true
        cellImageView?.contentMode = .scaleAspectFill
        contentView.addSubview(cellImageView!)
        
        // select icon
        selectionIcon = UIButton(frame: CGRect(x: 0, y: 0, width: slectionIconWidth, height: slectionIconWidth))
        selectionIcon.center = CGPoint(x: bounds.width - 2 - selectionIcon.bounds.width / 2, y: selectionIcon.bounds.height / 2)
        selectionIcon.setImage(#imageLiteral(resourceName: "iw_unselected"), for: .normal)
        selectionIcon.setImage(#imageLiteral(resourceName: "iw_selected"), for: .selected)
        
        contentView.addSubview(selectionIcon)
        
        // select button
        selectedButton = UIButton(frame: CGRect(x: 0, y: 0, width: bounds.width * 2 / 5, height: bounds.width * 2 / 5))
        selectedButton.center = CGPoint(x: bounds.width - selectedButton.bounds.width / 2, y: selectedButton.bounds.width / 2)
        selectedButton.backgroundColor = .clear
        contentView.addSubview(selectedButton)
        
        selectedButton.addTarget(self, action: #selector(selectionItemAction(btn:)), for: .touchUpInside)
    }
    
    @objc private func selectionItemAction(btn: UIButton) {
         btn.isSelected = !btn.isSelected
         handleSelectionAction?(btn.isSelected)
    }
}
