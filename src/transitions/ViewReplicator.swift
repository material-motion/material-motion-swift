/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License")
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit

public final class ViewReplicator {

  deinit {
    replicatedViews.forEach { $0.isHidden = false }
    replicaViews.forEach { $0.removeFromSuperview() }
  }

  public var containerView: UIView?

  /**
   Returns a replica of the provided view.

   The provided view will be hidden.
   */
  public func replicate(view: UIView) -> UIView {
    var copiedView: UIView
    switch view {
    case let imageView as UIImageView:
      copiedView = richReplica(of: imageView)
    case let label as UILabel:
      copiedView = richReplica(of: label)
    default:
      UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
      view.layer.render(in: UIGraphicsGetCurrentContext()!)
      let snapshot = UIGraphicsGetImageFromCurrentImageContext()
      copiedView = UIImageView(image: snapshot)
      UIGraphicsEndImageContext()
    }

    copiedView.layer.borderColor = view.layer.borderColor
    copiedView.layer.borderWidth = view.layer.borderWidth
    copiedView.layer.cornerRadius = view.layer.cornerRadius
    copiedView.layer.shadowColor = view.layer.shadowColor
    copiedView.layer.shadowOffset = view.layer.shadowOffset
    copiedView.layer.shadowOpacity = view.layer.shadowOpacity
    copiedView.layer.shadowPath = view.layer.shadowPath
    copiedView.layer.shadowRadius = view.layer.shadowRadius

    if let superview = view.superview, let containerView = containerView {
      copiedView.center = superview.convert(view.center, to: containerView)
    } else {
      copiedView.center = view.center
    }
    copiedView.bounds = view.bounds
    copiedView.transform = view.transform
    if let containerView = containerView {
      containerView.addSubview(copiedView)
    }
    view.isHidden = true

    replicatedViews.append(view)
    replicaViews.append(copiedView)

    return copiedView
  }

  private func richReplica(of imageView: UIImageView) -> UIView {
    let copiedImageView = UIImageView()

    copiedImageView.image = imageView.image
    copiedImageView.highlightedImage = imageView.highlightedImage

    copiedImageView.animationImages = imageView.animationImages
    copiedImageView.highlightedAnimationImages = imageView.highlightedAnimationImages
    copiedImageView.animationDuration = imageView.animationDuration
    copiedImageView.animationRepeatCount = imageView.animationRepeatCount

    mirrorProperties(from: imageView, to: copiedImageView)

    return copiedImageView
  }

  private func richReplica(of label: UILabel) -> UIView {
    let copiedLabel = UILabel()

    if let attributedText = label.attributedText {
      copiedLabel.attributedText = attributedText
    } else {
      copiedLabel.text = label.text
    }

    copiedLabel.font = label.font
    copiedLabel.textColor = label.textColor
    copiedLabel.shadowColor = label.shadowColor
    copiedLabel.shadowOffset = label.shadowOffset
    copiedLabel.textAlignment = label.textAlignment
    copiedLabel.lineBreakMode = label.lineBreakMode
    copiedLabel.highlightedTextColor = label.highlightedTextColor
    copiedLabel.isEnabled = label.isEnabled
    copiedLabel.numberOfLines = label.numberOfLines
    copiedLabel.adjustsFontSizeToFitWidth = label.adjustsFontSizeToFitWidth
    copiedLabel.baselineAdjustment = label.baselineAdjustment
    copiedLabel.minimumScaleFactor = label.minimumScaleFactor
    copiedLabel.preferredMaxLayoutWidth = label.preferredMaxLayoutWidth

    mirrorProperties(from: label, to: copiedLabel)

    return copiedLabel
  }

  private func mirrorProperties(from view: UIView, to copiedView: UIView) {
    copiedView.clipsToBounds = view.clipsToBounds
    copiedView.backgroundColor = view.backgroundColor
    copiedView.alpha = view.alpha
    copiedView.isOpaque = view.isOpaque
    copiedView.clearsContextBeforeDrawing = view.clearsContextBeforeDrawing
    copiedView.isHidden = view.isHidden
    copiedView.contentMode = view.contentMode
    copiedView.mask = view.mask
    copiedView.tintColor = view.tintColor
    copiedView.isUserInteractionEnabled = view.isUserInteractionEnabled
  }

  private var replicatedViews: [UIView] = []
  private var replicaViews: [UIView] = []
}
