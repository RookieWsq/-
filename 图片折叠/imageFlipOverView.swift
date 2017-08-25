//
//  imageFlipOverView.swift
//  图片折叠
//
//  Created by 翁胜琼 on 2017/8/23.
//  Copyright © 2017年 翁胜琼. All rights reserved.
//

import UIKit

class imageFlipOverView: UIView {

    var startPoint : CGPoint!
    // 真正在旋转的 view
    var flipOverImageView : UIImageView!
    // 阴影渲染视图
    var shadowLayer : CAGradientLayer!
    
    lazy var topImageView : UIImageView = {
        let image = #imageLiteral(resourceName: "image")
        let imageVIew = UIImageView(image: image)
        imageVIew.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2)
        imageVIew.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 0.5)
        imageVIew.layer.position = CGPoint(x: self.frame.width/2, y: self.bounds.height/2)
        imageVIew.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        return imageVIew
    }()
    lazy var bottomImageView : UIImageView = {
        let image = #imageLiteral(resourceName: "image")
        let imageVIew = UIImageView(image: image)
        imageVIew.frame = CGRect(x: 0, y: self.bounds.height/2, width: self.bounds.width, height: self.bounds.height/2)
        imageVIew.layer.contentsRect = CGRect(x: 0, y: 0.5, width: 1, height: 0.5)
        imageVIew.layer.position = CGPoint(x: self.frame.width/2, y: self.bounds.height/2)
        imageVIew.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        return imageVIew
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        setupImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
    }

    func setupImage(){
        self.addSubview(bottomImageView)
        self.addSubview(topImageView)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.addGestureRecognizer(pan)
    }
    
    func pan(_ pan : UIPanGestureRecognizer){
        let location = pan.location(in: self)
        
        // 设置3D 转动效果
        var transform = CATransform3DIdentity
        transform.m34 = -1/800
        
        // 判断手势是否在 self 上  如果不在 self 上则复原翻转
        if !((location.x > 0 && location.y > 0) &&
            (location.x < self.bounds.width && location.y < self.bounds.height)){
            
            flipAnimation(topImageView, transform: transform)
            flipAnimation(bottomImageView, transform: transform)
            
            return
        }
        
        switch pan.state {
        case .began:
            startPoint = location
            // 判断需要翻转的是topImage 还是 BottomImage
            if location.y<self.bounds.height/2{
                flipOverImageView = topImageView
                self.bringSubview(toFront: topImageView)
                // 阴影出现在下半视图
                setupShadowLayer(bottomImageView)
            }else{
                flipOverImageView = bottomImageView
                self.bringSubview(toFront: bottomImageView)
                // 阴影出现在上半视图
                setupShadowLayer(topImageView)
            }
            
        case .changed:
            
            let angle = -(location.y - startPoint.y)/self.bounds.height *  CGFloat.pi
            flipOverImageView.layer.transform = CATransform3DRotate(transform, angle, 1, 0, 0)
            
            // 计算阴影透明度  最高是0.8的透明度
            let opacity = (location.y - startPoint.y)/self.bounds.height*0.8
            shadowLayer.opacity = Float(opacity)
            // 阴影的位置
            shadowLayer.locations = [0,NSNumber(value: Float(1-opacity))]
            
        case .ended:
            
            flipAnimation(flipOverImageView, transform: transform)
            
        case .cancelled:
            
            flipAnimation(flipOverImageView, transform: transform)

        default:
            break
        }
        
        
    }
    // 结束翻转的动画
    func flipAnimation(_ flipOverView : UIImageView,transform : CATransform3D){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            flipOverView.layer.transform = CATransform3DRotate(transform, 0, 1, 0, 0)
            self.shadowLayer.opacity = 0
        },  completion: { (_) in
//            self.shadowLayer = nil
        })
       
    }
    
    func setupShadowLayer(_ inView : UIImageView){
        shadowLayer = CAGradientLayer()
        shadowLayer.frame = inView.bounds
        shadowLayer.opacity = 0
        shadowLayer.colors = [UIColor.clear.cgColor,UIColor.black.cgColor]  // 需要设置 location 才能够有很好的阴影效果
//        shadowLayer.colors = [UIColor.clear.cgColor,UIColor(patternImage: inView.image!).cgColor]  // 不需要设置 location 就可以有很好的阴影效果
        shadowLayer.locations = [0.7,1]
        inView.layer.addSublayer(shadowLayer)
    }
}
