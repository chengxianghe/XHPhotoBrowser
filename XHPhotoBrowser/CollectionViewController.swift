//
//  CollectionViewController.swift
//  XHPhotoBrowser
//
//  Created by chengxianghe on 16/8/23.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit

var caption = ["",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen bookLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen bookremaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
               "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
               "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
               "It has survived not only five centuries, but also the leap into electronic typesetting",
               "remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
]

var imageurls: [[String : String]] = {
    return NSArray.init(contentsOfFile: Bundle.main.path(forResource: "imagesModels", ofType: "plist")!) as! [[String : String]]
}()

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private final let screenBound = UIScreen.main.bounds
    private var screenWidth: CGFloat { return screenBound.size.width }
    private var screenHeight: CGFloat { return screenBound.size.height }
        
    @IBOutlet public weak var collectionView: UICollectionView!
    fileprivate var images = [ImageModel]()
    let switcher = UISwitch()
    let leftsSwitcher = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        switcher.isOn = true
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: switcher), UIBarButtonItem.init(title: "虚化", style: UIBarButtonItemStyle.plain, target: nil, action: nil)]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(customView: leftsSwitcher), UIBarButtonItem.init(title: "下标", style: UIBarButtonItemStyle.plain, target: nil, action: nil)]
        
        DispatchQueue.global().async {
            for dict in imageurls {
                let model = ImageModel()
//                model.setValuesForKeys(dict)
                model.big = dict["big"] ?? ""
                model.middle = dict["middle"] ?? ""
                model.small = dict["small"] ?? ""
                //                model.caption = caption[random()%10]
                
                self.images.append(model)
                
                if self.images.count == 30 {
                    break
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
    }
    
    private func setupTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exampleCollectionViewCell", for: indexPath) as? ExampleCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setInfo(url: self.images[indexPath.row].small)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //启动图片浏览器
        let vc = self
        
        let currentPage = indexPath.row
        
        let v = XHPhotoBrowser()
        
        print(self.collectionView.contentOffset.y)
        v.thumbViewIsCell = true
        v.contentOffSetY = self.collectionView.contentOffset.y
        v.delegate = self
        v.dataSource = self
        v.showDeleteButton = true
        v.showCloseButton = false
        v.toolBarShowStyle = leftsSwitcher.isOn ? .show : .hide
        v.fromItemIndex = currentPage
        v.blurEffectBackground = self.switcher.isOn
        v.show(inContaioner: vc.tabBarController!.view, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: screenWidth/2.0 - 5, height: 300)
        } else {
            return CGSize(width: screenWidth/3.0 - 10, height: screenWidth/3 - 10)
        }
    }
    
    func shouldClippedToTop(view: UIView?) -> Bool {
        if (view != nil) {
            if (view!.layer.contentsRect.size.height < 1) {
                return true;
            }
        }
        return false;
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
}

class MYPhotoGroupItem: XHPhotoItem {
    override var thumbImage: UIImage? {
        get {
            if self.thumbView != nil {
                return (self.thumbView as! ExampleCollectionViewCell).exampleImageView.image
            }
            return nil
        }
    }
}

extension CollectionViewController: XHPhotoBrowserDataSource {
    
    func xh_numberOfImages(in photoBrowser: XHPhotoBrowser) -> Int {
        return self.images.count
    }
    
    func xh_photoBrowser(_ photoBrowser: XHPhotoBrowser, photoAt index: Int) -> XHPhotoProtocol {
        let item = MYPhotoGroupItem()
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexP in indexPaths {
            if index == indexP.row {
                item.thumbView = self.collectionView(self.collectionView, cellForItemAt: indexP) as! ExampleCollectionViewCell
                break
            }
        }
        
        item.caption = self.images[index].caption
        item.largeImageURL = URL(string: self.images[index].big)!
        if item.thumbView != nil {
            item.shouldClipToTop = self.shouldClippedToTop(view: (item.thumbView as! ExampleCollectionViewCell).exampleImageView)
        } else {
            item.shouldClipToTop = false
        }
//        item.shouldClipToTop = self.shouldClippedToTop(item.thumbView)
        return item
    }
}


extension CollectionViewController: XHPhotoBrowserDelegate {
    
    func xh_photoBrowserWillMove(toSuperView photoBrowser: XHPhotoBrowser) {
        let viscells = self.collectionView.visibleCells
        let viscellIndexs = self.collectionView.indexPathsForVisibleItems
        let index = photoBrowser.fromItemIndex
        for (i, indexPath) in viscellIndexs.enumerated() {
            if indexPath.item == index {
                viscells[i].isHidden = true
                break
            }
        }

    }
    
    func xh_photoBrowserWillRemove(fromSuperView photoBrowser: XHPhotoBrowser) {
        let viscells = self.collectionView.visibleCells
        viscells.forEach({$0.isHidden = false})

//        let viscellIndexs = self.collectionView.indexPathsForVisibleItems()
//        let index = photoBrowser.currentPage
//        for (i, indexPath) in viscellIndexs.enumerate() {
//            if indexPath.item == index {
//                viscells[i].hidden = false
//                break
//            }
//        }

    }
    
    func xh_photoBrowser(_ photoBrowser: XHPhotoBrowser, didDisplayingImageAt index: Int, from fromIndex: Int) {
        print("正在展示第 \(index) 页 , fromIndex:\(fromIndex)")
        
        let viscells = self.collectionView.visibleCells
        let viscellIndexs = self.collectionView.indexPathsForVisibleItems
        
        for (i, indexPath) in viscellIndexs.enumerated() {
            if indexPath.item == index {
               viscells[i].isHidden = true
                break
            }
        }

        if fromIndex != NSNotFound {
            for (i, indexPath) in viscellIndexs.enumerated() {
                if indexPath.item == fromIndex {
                    viscells[i].isHidden = false
                    break
                }
            }
        }

    }
}




class ExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var exampleImageView: UIImageView!
    
    func setInfo(url: String) {
        let imageView = self.exampleImageView

        imageView?.layer.removeAnimation(forKey: "contents")
        imageView?.yy_setImage(with: NSURL(string: url)! as URL, placeholder: UIImage(named: "whiteplaceholder"), options: YYWebImageOptions.avoidSetImage, progress: nil, transform: nil, completion: {[weak imageView] (image, url, from, stage, error) in
                
                // if (image != nil && stage == YYWebImageStage.Finished) {
                //     imageView.image = image;
                // }
                guard let imageView = imageView else {
                    return
                }
                
                if (error != nil || image == nil) {
                    imageView.image = UIImage(named: "whiteplaceholder")
                    return ;
                }
                
                imageView.image = image;
                
                let width = image!.size.width * UIScreen.main.scale
                let height = image!.size.height * UIScreen.main.scale
                //
                let scale = (height / width) / (imageView.bounds.size.height / imageView.bounds.size.width);
                if (scale < 0.99 || scale.isNaN) { // 宽图把左右两边裁掉
                    imageView.contentMode = UIViewContentMode.scaleAspectFill
                    
                    imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                } else { // 高图只保留顶部
                    imageView.contentMode = UIViewContentMode.scaleToFill;
                    imageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: width / height)
            }
            
                if (from != YYWebImageFromType.memoryCacheFast) {
                    let transition = CATransition()
                    transition.duration = 0.15;
                    transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
                    transition.type = kCATransitionFade;
                    imageView.layer.add(transition, forKey: "contents")
                }
                
            })

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        exampleImageView.image = nil
        exampleImageView.contentMode = UIViewContentMode.scaleAspectFill
//        layer.cornerRadius = 25.0
//        layer.masksToBounds = true
    }
    
//    override func prepareForReuse() {
//        exampleImageView.image = nil
//    }
}

