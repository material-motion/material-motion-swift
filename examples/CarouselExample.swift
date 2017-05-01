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
import MaterialMotion

class CarouselExampleViewController: ExampleViewController, UIScrollViewDelegate {

  let delegate = ReactiveScrollViewDelegate()
  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    let scrollView = UIScrollView(frame: view.bounds)
    scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    scrollView.isPagingEnabled = true
    scrollView.contentSize = .init(width: view.bounds.size.width * 3, height: view.bounds.size.height)
    scrollView.delegate = delegate
    view.addSubview(scrollView)

    let pager = UIPageControl()
    let size = pager.sizeThatFits(view.bounds.size)
    pager.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
    pager.frame = .init(x: 0, y: view.bounds.height - size.height - 20, width: view.bounds.width, height: size.height)
    pager.numberOfPages = 3
    view.addSubview(pager)

    let datas = [
      (title: "Page 1", description: "Page 1 description", color: UIColor.white),
      (title: "Page 2", description: "Page 2 description", color: .primaryColor),
      (title: "Page 3", description: "Page 3 description", color: .secondaryColor),
    ]

    for (index, data) in datas.enumerated() {
      let page = CarouselPage(frame: view.bounds)
      page.frame.origin.x = CGFloat(index) * view.bounds.width
      page.titleLabel.text = data.title
      page.descriptionLabel.text = data.description
      page.iconView.backgroundColor = data.color
      scrollView.addSubview(page)

      let pageEdge = delegate.x().offset(by: -page.frame.origin.x)

      pageEdge.rewriteRange(start: 0, end: 128, destinationStart: 1, destinationEnd: 0).subscribeToValue {
        page.alpha = $0
      }
      pageEdge.rewriteRange(start: -view.bounds.width, end: 0, destinationStart: 0.5, destinationEnd: 1.0).subscribeToValue {
        page.layer.transform = CATransform3DMakeScale($0, $0, 1)
      }
    }

    delegate.x().offset(by: scrollView.bounds.width / 2).scaled(by: 1 / scrollView.bounds.width).subscribeToValue {
      pager.currentPage = Int($0)
    }
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Swipe betwen pages to see the scroll effects.")
  }
}

private class CarouselPage: UIView {
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  let iconView = UIView()

  override init(frame: CGRect) {
    titleLabel.font = .boldSystemFont(ofSize: 24)
    descriptionLabel.font = .systemFont(ofSize: 14)
    titleLabel.textColor = .white
    descriptionLabel.textColor = .white
    descriptionLabel.numberOfLines = 0
    descriptionLabel.lineBreakMode = .byWordWrapping

    super.init(frame: frame)

    addSubview(titleLabel)
    addSubview(descriptionLabel)
    addSubview(iconView)
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

    iconView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width).insetBy(dx: 64, dy: 64)
    iconView.layer.cornerRadius = iconView.bounds.width / 2
  }
}
