# JKChangeCapture

[![CI Status](https://img.shields.io/travis/xindizhiyin2014/JKKVOHelper.svg?style=flat)](https://travis-ci.org/xindizhiyin2014/JKKVOHelper)
[![Version](https://img.shields.io/cocoapods/v/JKKVOHelper.svg?style=flat)](https://cocoapods.org/pods/JKChangeCapture)
[![License](https://img.shields.io/cocoapods/l/JKKVOHelper.svg?style=flat)](https://cocoapods.org/pods/JKChangeCapture)
[![Platform](https://img.shields.io/cocoapods/p/JKKVOHelper.svg?style=flat)](https://cocoapods.org/pods/JKChangeCapture)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JKKVOHelper is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JKChangeCapture'
```
## guide

### 使用示例代码：
#### 只需要在结构体，类，遵守协议即可
```
struct PublishSubjectViewModel:JKChangeCaptureProtocol {
    var publishObjectMap: [String : RxSwift.PublishSubject<JKPublistMessage>]?
```

#### 发送属性变化：

```
var age:Int = 0 {
        didSet {
//          postMessage(key: "age", value: age) 如果不需要关注oldValue可以不传
            postMessage(key: "age", value: age, oldValue: oldValue)
        }
    }
    
    var num:Int = 0 {
        didSet {
            postMessage(key: "num", value: num, oldValue: oldValue)
        }
    }

```

#### 处理属性变化：
```
  viewModel.observe(key: "age") { value in
            print("aaa \(value)")
        }.disposed(by: disposeBag)

   viewModel.observe(key: "age", of: Int.self) { value, oldValue in
            print("aaa \(value)")
            print("bbb \(oldValue)")
        }.disposed(by: disposeBag)
        
```
#### 监听多个属性变化：
```
        viewModel.observe(keys: ["age","num"]) { message in
            print("aaa key: \(message?.key), value:\(message?.value), oldValue: \(message?.oldValue)")
        }.disposed(by: disposeBag)

```
### 基于RXSwift进行开发
想必很多有接触过RXswift的同学看到disposeBag这个已经猜到了，这个工具是基于RxSwift进行开发的，主要目的是在捕捉到数据变化的同时能够进行一些装饰性的操作，在保证代码优雅的同时增加代码的扩展性。示例如下：
```
        viewModel.observe(key: "age", of: Int.self) { subject in
           return subject.skip(1)
        } detailBlock: { value, oldValue in

            print("aaa \(value)")
            print("bbb \(oldValue)")
        }.disposed(by: disposeBag)
```
大家可以在第一个block内部，对subject执行一些装饰性的操作，debouce,throttle,skip,map.等Rxswift支持的操作，具体看自己的业务需求。



## Author

xindizhiyin2014, 929097264@qq.com

## License

JKKVOHelper is available under the MIT license. See the LICENSE file for more info.
