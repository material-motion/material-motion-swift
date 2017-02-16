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

import Foundation
import MaterialMotionStreams

@available(iOS 9.0, *)
public class StickerPickerExampleViewController: UIViewController, StickerListViewControllerDelegate {

  var runtime: MotionRuntime!

  init() {
    super.init(nibName: nil, bundle: nil)

    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func didTapAdd() {
    let picker = StickerListViewController()
    picker.delegate = self
    present(picker, animated: true)
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    runtime = MotionRuntime(containerView: view)

    view.backgroundColor = .white
  }

  fileprivate func didPickSticker(_ sticker: Sticker) {
    let imageView = UIImageView(image: sticker.image)
    imageView.sizeToFit()
    imageView.center = .init(x: view.bounds.midX, y: view.bounds.midY)
    view.addSubview(imageView)

    imageView.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1)
    let spring = Spring(to: CGFloat(1), threshold: 1, system: coreAnimation)
    runtime.add(spring, to: runtime.get(imageView.layer).scale)

    runtime.add(DirectlyManipulable(targetView: imageView), to: imageView)
  }
}

private let numberOfStickers = 3

private struct Sticker {
  let name: String
  let image: UIImage
  let uuid: String

  fileprivate init(name: String) {
    self.uuid = NSUUID().uuidString
    self.name = name

    // NOTE: In a real app you should never load images from disk on the UI thread like this.
    // Instead, you should find some way to cache the thumbnails in memory and then asynchronously
    // load the full-size photos from disk/network when needed. The photo library APIs provide
    // exactly this sort of behavior (square thumbnails are accessible immediately on the UI thread
    // while the full-sized photos need to be loaded asynchronously).
    self.image = UIImage(named: "\(self.name).jpg")!
  }
}

private class StickerAlbum {
  let stickers: [Sticker]
  let identifierToIndex: [String: Int]

  init() {
    var stickers: [Sticker] = []
    var identifierToIndex: [String: Int] = [:]
    for index in 0..<numberOfStickers {
      let sticker = Sticker(name: "sticker\(index)")
      stickers.append(sticker)
      identifierToIndex[sticker.uuid] = index
    }
    self.stickers = stickers
    self.identifierToIndex = identifierToIndex
  }
}

private class StickerCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    imageView.contentMode = .scaleAspectFill
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    imageView.frame = bounds
    imageView.clipsToBounds = true

    contentView.addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func imageViewForTransition() -> UIImageView {
    return imageView
  }
}

@available(iOS 9.0, *)
private class StickerListViewController: UICollectionViewController {

  let album = StickerAlbum()
  var selectedSticker: Sticker?
  weak var delegate: StickerListViewControllerDelegate?

  init() {
    super.init(collectionViewLayout: UICollectionViewFlowLayout())

    transitionController.directorType = ModalTransitionDirector.self

    modalPresentationStyle = .overCurrentContext
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    collectionView!.backgroundColor = UIColor(white: 0, alpha: 0.25)
    collectionView!.register(PhotoCollectionViewCell.self,
                             forCellWithReuseIdentifier: photoCellIdentifier)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    updateLayout()
  }

  func updateLayout() {
    let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
    layout.sectionInset = .init(top: 4, left: 4, bottom: 4, right: 4)
    layout.minimumInteritemSpacing = 4
    layout.minimumLineSpacing = 4
    layout.headerReferenceSize = .init(width: 0, height: 48)

    let numberOfColumns: CGFloat = 3
    let squareDimension = (view.bounds.width - layout.sectionInset.left - layout.sectionInset.right - (numberOfColumns - 1) * layout.minimumInteritemSpacing) / numberOfColumns
    layout.itemSize = CGSize(width: squareDimension, height: squareDimension)
  }

  public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return album.stickers.count
  }

  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier,
                                                  for: indexPath) as! PhotoCollectionViewCell
    let sticker = album.stickers[indexPath.row]
    cell.imageView.image = sticker.image
    return cell
  }

  public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedSticker = album.stickers[indexPath.row]
    delegate?.didPickSticker(selectedSticker!)
    dismiss(animated: true)
  }
}

private protocol StickerListViewControllerDelegate: NSObjectProtocol {
  func didPickSticker(_ sticker: Sticker)
}

@available(iOS 9.0, *)
private class ModalTransitionDirector: TransitionDirector {

  required init() {}

  func willBeginTransition(_ transition: Transition, runtime: MotionRuntime) {
    let size = transition.fore.preferredContentSize == .zero() ? transition.fore.view.bounds.size : transition.fore.preferredContentSize

    if transition.direction == .forward {
      transition.fore.view.bounds = CGRect(origin: .zero, size: size)
    }

    let spring = TransitionSpring(back: CGFloat(0),
                                  fore: CGFloat(1),
                                  direction: transition.direction,
                                  threshold: 0.01,
                                  system: coreAnimation)
    runtime.add(spring, to: runtime.get(transition.fore.view.layer).opacity)
  }
}
