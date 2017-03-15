import Foundation
import UIKit
import PlaygroundSupport
import WebKit

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
