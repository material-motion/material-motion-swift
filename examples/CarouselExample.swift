/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import MaterialMotionStreams

public class CarouselExampleViewController: UIViewController, UIScrollViewDelegate {

  var runtime: MotionRuntime!
  public override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = UIColor(hexColor: 0xF8AA36)

    let scrollView = UIScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    scrollView.isPagingEnabled = true
    scrollView.contentSize = .init(width: view.bounds.size.width * 3, height: view.bounds.size.height)
    scrollView.delegate = self
    view.addSubview(scrollView)

    pager = UIPageControl()
    let size = pager.sizeThatFits(view.bounds.size)
    pager.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    pager.frame = .init(x: 0, y: view.bounds.height - size.height - 20, width: view.bounds.width, height: size.height)
    pager.numberOfPages = 3
    view.addSubview(pager)

    let datas = [
      (title: "Mr Catterson", description: "Such a cat", image: UIImage(named: "sticker0")!),
      (title: "Bartholomew", description: "Cattest of cats", image: UIImage(named: "sticker1")!),
      (title: "Purr purr", description: "Meow", image: UIImage(named: "sticker2")!),
    ]

    let stream = scrollViewToStream(scrollView)
    for (index, data) in datas.enumerated() {
      let page = CarouselPage(frame: view.bounds)
      page.frame.origin.x = CGFloat(index) * view.bounds.width
      page.titleLabel.text = data.title
      page.descriptionLabel.text = data.description
      page.imageView.image = data.image
      scrollView.addSubview(page)

      let pageEdge = stream.x().offset(by: -page.frame.origin.x)

      runtime.add(pageEdge.mapRange(rangeStart: 0, rangeEnd: 128,
                                    destinationStart: 1, destinationEnd: 0),
                  to: runtime.get(page).alpha)
      runtime.add(pageEdge.mapRange(rangeStart: -view.bounds.width, rangeEnd: 0,
                                    destinationStart: 0.5, destinationEnd: 1.0),
                  to: runtime.get(page.layer).scale)
    }
  }

  var pager: UIPageControl!

  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    pager.currentPage = Int((scrollView.contentOffset.x + scrollView.bounds.width / 2) / scrollView.bounds.width)
  }
}

private class CarouselPage: UIView {
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  let imageView = UIImageView()

  override init(frame: CGRect) {
    titleLabel.font = .boldSystemFont(ofSize: 24)
    descriptionLabel.font = .systemFont(ofSize: 14)
    titleLabel.textColor = .white
    descriptionLabel.textColor = .white
    descriptionLabel.numberOfLines = 0
    descriptionLabel.lineBreakMode = .byWordWrapping

    imageView.contentMode = .center

    super.init(frame: frame)

    addSubview(titleLabel)
    addSubview(descriptionLabel)
    addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let descriptionSize = descriptionLabel.sizeThatFits(bounds.size)
    descriptionLabel.frame = .init(x: 16, y: bounds.height - descriptionSize.height - 48, width: bounds.width - 32, height: descriptionSize.height)

    let titleSize = titleLabel.sizeThatFits(bounds.size)
    titleLabel.frame = .init(x: 16, y: descriptionLabel.frame.minY - descriptionSize.height - 24, width: bounds.width - 32, height: titleSize.height)

    imageView.frame = .init(x: 0, y: 0, width: bounds.width, height: bounds.width)
  }
}

extension UIColor {
  private convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")

    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }

  fileprivate convenience init(hexColor: Int) {
    self.init(red: (hexColor >> 16) & 0xff, green: (hexColor >> 8) & 0xff, blue: hexColor & 0xff)
  }
}
