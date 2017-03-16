# Reactive Motion (Swift)

[![Build Status](https://travis-ci.org/material-motion/reactive-motion-swift.svg?branch=develop)](https://travis-ci.org/material-motion/reactive-motion-swift)
[![codecov](https://codecov.io/gh/material-motion/reactive-motion-swift/branch/develop/graph/badge.svg)](https://codecov.io/gh/material-motion/reactive-motion-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ReactiveMotion.svg)](https://cocoapods.org/pods/ReactiveMotion)
[![Platform](https://img.shields.io/cocoapods/p/ReactiveMotion.svg)](http://cocoadocs.org/docsets/ReactiveMotion)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/ReactiveMotion.svg)](http://cocoadocs.org/docsets/ReactiveMotion)

Reactive Motion is a library for creating motion with [reactive programming](http://reactivex.io/)
patterns.

This library includes a variety of ready-to-use **interactions**. Start by creating and storing a
`MotionRuntime` instance:

```swift
// Store me for as long as the interactions should take effect.
let runtime = MotionRuntime(containerView: <#view#>)
```

<table>
  <thead><tr><th></th><th>Interaction</th><th>Snippet</th></tr></thead>
  <tbody>
    <tr>
      <td align="center"><img src="assets/arcmove.gif" /></td>
      <td><pre><code class="language-swift">ArcMove</code></pre></td>
      <td><pre><code class="language-swift">let arcMove = ArcMove()
arcMove.from.value = <#from#>
arcMove.to.value = <#to#>
runtime.add(arcMove, to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/directlymanipulable.gif" /></td>
      <td><pre><code class="language-swift">DirectlyManipulable</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(DirectlyManipulable(), to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/draggable.gif" /></td>
      <td><pre><code class="language-swift">Draggable</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(Draggable(), to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/rotatable.gif" /></td>
      <td><pre><code class="language-swift">Rotatable</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(Rotatable(), to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/scalable.gif" /></td>
      <td><pre><code class="language-swift">Scalable</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(Scalable(), to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/setpositionontap.gif" /></td>
      <td><pre><code class="language-swift">SetPositionOnTap</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(SetPositionOnTap(),
            to: runtime.get(<#view#>.layer).position)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/spring.gif" /></td>
      <td><pre><code class="language-swift">Spring</code></pre></td>
      <td><pre><code class="language-swift">let spring = Spring()
spring.destination.value = <#initial destination#>
runtime.add(spring, to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/tossable.gif" /></td>
      <td><pre><code class="language-swift">Tossable</code></pre></td>
      <td><pre><code class="language-swift">let tossable = Tossable()
tossable.spring.destination.value = <#initial destination#>
runtime.add(tossable, to: <#view#>)</code></pre></td>
    </tr>
    <tr>
      <td align="center"><img src="assets/tween.gif" /></td>
      <td><pre><code class="language-swift">Tween</code></pre></td>
      <td><pre><code class="language-swift">runtime.add(Tween(duration: 0.5, values: [1, 0]),
            to: runtime.get(<#view#>.layer).opacity)</code></pre></td>
    </tr>
  </tbody>
</table>

## Installation

### Installation with CocoaPods

> CocoaPods is a dependency manager for Objective-C and Swift libraries. CocoaPods automates the
> process of using third-party libraries in your projects. See
> [the Getting Started guide](https://guides.cocoapods.org/using/getting-started.html) for more
> information. You can install it with the following command:
>
>     gem install cocoapods

Add `ReactiveMotion` to your `Podfile`:

    pod 'ReactiveMotion'

Then run the following command:

    pod install

### Usage

Import the framework:

    import ReactiveMotion

You will now have access to all of the APIs.

## Example apps/unit tests

Check out a local copy of the repo to access the Catalog application by running the following
commands:

    git clone https://github.com/material-motion/reactive-motion-swift.git
    cd reactive-motion-swift
    pod install
    open ReactiveMotion.xcworkspace

## Guides

1. [Architecture](#architecture)
2. [How to ...](#how-to-...)

### Architecture

### How to ...

## Contributing

We welcome contributions!

Check out our [upcoming milestones](https://github.com/material-motion/reactive-motion-swift/milestones).

Learn more about [our team](https://material-motion.github.io/material-motion/team/),
[our community](https://material-motion.github.io/material-motion/team/community/), and
our [contributor essentials](https://material-motion.github.io/material-motion/team/essentials/).

## License

Licensed under the Apache 2.0 license. See LICENSE for details.
