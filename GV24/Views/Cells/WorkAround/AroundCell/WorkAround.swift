//
//  WorkAround.swift
//  GV24
//
//  Created by HuyNguyen on 6/2/17.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit

protocol changeSliderDelegate:class {
    func change(slider:UISlider)
}
class WorkAround: xibView {
    weak var delegate:changeSliderDelegate?
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var space: UILabel!
    @IBOutlet weak var maxDictance: UILabel!
    @IBOutlet weak var minDictance: UILabel!
    @IBOutlet weak var sliderMax: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        space.text = "distance".localize
        minDictance.text = "\(0)km"
        maxDictance.text = "\(10)km"
        sliderMax.text = "\(2)km"
    }
    func setupView()  {
    }
    @IBAction func changeAction(_ sender: Any) {
        delegate?.change(slider: slider)
    }
}
