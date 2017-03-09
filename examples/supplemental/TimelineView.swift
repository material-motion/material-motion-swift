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

public class TimelineView: UIView {

  public let timeline: Timeline!
  public let sliderValue: ReactiveProperty<CGFloat>!

  private var bgView: UIView!
  private var slider: UISlider!
  private var toggle: UIButton!

  public init(timeline: Timeline, frame: CGRect) {
    self.timeline = timeline
    sliderValue = createProperty("TimelineView.sliderValue", withInitialValue: CGFloat(0.5))
    super.init(frame: frame)

    bgView = UIView(frame: .zero)
    bgView.backgroundColor = UIColor.init(white: 0.95, alpha: 1)
    self.addSubview(bgView)

    slider = UISlider(frame: .zero)
    slider.value = Float(sliderValue.value)
    slider.tintColor = UIColor.black
    slider.addTarget(self, action: #selector(didSlide), for: .valueChanged)
    self.addSubview(slider)

    toggle = UIButton(type: .custom)
    toggle.setTitle("▶", for: .normal)
    toggle.setTitleColor(.black, for: .normal)
    toggle.addTarget(self, action: #selector(didToggle), for: .touchUpInside)
    self.addSubview(toggle)
  }

  public required override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    bgView.frame = .init(x: 0, y: 20, width: bounds.size.width, height: bounds.size.height - 20)

    var center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
    slider.frame = .init(x: 0, y: 0, width: frame.width, height: 40)
    toggle.frame = .init(x: center.x - 16, y: center.y - 16 + 12, width: 32, height: 32)
  }

  override public func sizeThatFits(_ size: CGSize) -> CGSize {
    return .init(width: size.width, height: 84)
  }

  func didSlide(_ slider: UISlider) {
    sliderValue.value = CGFloat(slider.value)
  }

  func didToggle(_ button: UIButton) {
    timeline.paused.value = !timeline.paused.value
    button.setTitle(timeline.paused.value ? "▶" : "❙❙", for: .normal)
  }
}
