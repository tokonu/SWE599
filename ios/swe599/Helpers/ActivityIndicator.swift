//
//  ActivityIndicator.swift
//  swe599
//
//  Created by Onur on 13.05.2019.
//  Copyright © 2019 Cemal Onur Tokoglu. All rights reserved.
//

import UIKit

class ActivityIndicator {
    
    private static var indicatorView: UIView?
    
    static func show(on view: UIView){
        indicatorView?.removeFromSuperview()
        indicatorView = UIView()
        indicatorView?.frame.size = view.frame.size
        indicatorView?.backgroundColor  = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
        indicatorView?.center = view.center
        
        let activityView = UIActivityIndicatorView(style: .gray)
        indicatorView?.addSubview(activityView)
        activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityView.center = indicatorView!.center
        activityView.startAnimating()
        view.addSubview(indicatorView!)
    }
    
    static func hide(){
        indicatorView?.removeFromSuperview()
        indicatorView = nil
    }
    
}
