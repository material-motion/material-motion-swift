import Foundation
import UIKit
import PlaygroundSupport
import WebKit

public let canvas = createCanvas()

public func createCanvas() -> UIView {
  let canvas = UIView(frame: .init(x: 0, y: 0, width: 600, height: 800))
  canvas.backgroundColor = .white
  PlaygroundPage.current.liveView = canvas
  return canvas
}

public func visualize(graphviz: String, onCanvas canvas: UIView) {
  let webView = VisualizingWebView(graphviz: graphviz, frame: .init(x: 0, y: canvas.bounds.height - canvas.bounds.width, width: canvas.bounds.width, height: canvas.bounds.width))
  webView.load(.init(url: URL(string: "http://www.webgraphviz.com/")!))
  canvas.addSubview(webView)
}

public func createExampleView() -> UIView {
  let view = UIView(frame: .init(x: 0, y: 0, width: 128, height: 128))
  view.backgroundColor = .primaryColor
  view.layer.cornerRadius = view.bounds.width / 2
  return view
}

public func createExampleSquareView() -> UIView {
  let view = UIView(frame: .init(x: 0, y: 0, width: 128, height: 128))
  view.backgroundColor = .primaryColor
  return view
}

class VisualizingWebView: WKWebView, WKNavigationDelegate {
  init(graphviz: String, frame: CGRect) {
    self.graphviz = graphviz
    super.init(frame: frame, configuration: .init())
    self.navigationDelegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let javascript = "document.getElementById('graphviz_data').innerHTML = `\(graphviz.replacingOccurrences(of: "\\n", with: "\\\n"))`; document.getElementById('generate_btn').click(); var image = document.getElementById('graphviz_svg_div'); document.body.innerHTML = ''; document.body.appendChild(image);"
    webView.evaluateJavaScript(javascript) { value, error in

    }
  }
  let graphviz: String
}

extension UIColor {
  private convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")

    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }

  convenience init(hexColor: Int) {
    self.init(red: (hexColor >> 16) & 0xff, green: (hexColor >> 8) & 0xff, blue: hexColor & 0xff)
  }

  static var primaryColor: UIColor {
    return UIColor(hexColor: 0xFF80AB)
  }

  static var secondaryColor: UIColor {
    return UIColor(hexColor: 0xC51162)
  }

  static var backgroundColor: UIColor {
    return UIColor(hexColor: 0x212121)
  }
}
