//
//  BlurredLabel.swift
//
//  Created by Davide Ceresola on 13/08/2020.
//  Copyright © 2020 Davide Ceresola. All rights reserved.
//

import UIKit

/// The BlurLabel class
public class BlurLabel: UILabel {
    
    // MARK: - Public properties
    public var isBlurEnabled: Bool = true {
        didSet {
            animateBlur(blurred: isBlurEnabled)
        }
    }
    
    private var isBlurred: Bool = true
    
    public var blurRadius = 8 {
        didSet {
            animateBlur(blurred: isBlurred)
        }
    }
    
    private lazy var blurLayer: CALayer = {
        
        let blurLay = CALayer()
        blurLay.backgroundColor = UIColor.white.cgColor
        blurLay.contentsGravity = .center
        layer.addSublayer(blurLay)
        
        return blurLay
        
    }()
    
    // MARK: - Functions
    private func animateBlur(blurred: Bool) {
        
        if blurred {
            setBlur()
        } else {
            setUnblur()
        }
        
        isBlurred = blurred
        
    }
    
    private func setBlur() {
        
        let generated = generateImage()
        blurLayer.contents = generated
        alpha = 0.7
        blurLayer.isHidden = false
        
    }
    
    private func setUnblur() {
        
        alpha = 1.0
        blurLayer.isHidden = true
        
    }
    
    private func generateImage() -> CGImage? {
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContext(layer.bounds.size)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        layer.draw(in: ctx) // do not use render, we only want to display the top level layer
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        guard let img = image, let cgImage = img.cgImage else {
            return nil
        }
        let inputImage = CIImage(cgImage: cgImage)
        
        guard let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        gaussianBlurFilter.setDefaults()
        gaussianBlurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        gaussianBlurFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = gaussianBlurFilter.outputImage else { return nil }
        
        let ciContext = CIContext(options: nil)
        
        let rect = outputImage.extent
        
        guard let cgImgOutput = ciContext.createCGImage(outputImage, from: rect) else {
            return nil
        }
        
        return cgImgOutput
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        blurLayer.frame = bounds
    }
    
    public override var attributedText: NSAttributedString? {
        didSet {
            animateBlur(blurred: isBlurred)
        }
    }
    
    public override var text: String? {
        didSet {
            animateBlur(blurred: isBlurred)
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        blurLayer.backgroundColor = UIColor.white.cgColor
        animateBlur(blurred: isBlurred)
    }
    
}
