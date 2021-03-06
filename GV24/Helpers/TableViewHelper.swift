//
//  TableViewHelper.swift
//  GV24
//
//  Created by Macbook Solution on 6/15/17.
//  Copyright © 2017 admin. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper: NSObject {
    
    func emptyMessage(message: String, size:CGSize) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width:size.width, height: size.height))
        label.text = message
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.red
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "TrebuchetMS", size: 17)
        label.sizeToFit()
        return label
    }
    
    func noData(frame: CGRect) -> UIView {
        let image = UIImage(named: "icon_nodata")
        let imgView = UIImageView(image: image)
        imgView.frame = CGRect(x: 10, y: 0, width: 80, height: 100)
        let view = UIView(frame: frame)
        //view.backgroundColor = UIColor.red
        view.addSubview(imgView)
        let text = UILabel()
        text.text = "SoonUpdate".localize
        text.textColor = UIColor.colorWithRedValue(redValue: 109, greenValue: 108, blueValue: 113, alpha: 1)
        text.frame = CGRect(x: 0, y: 110, width: 70, height: 20)
        view.addSubview(text)
        text.sizeToFit()
        return view
    }
}
