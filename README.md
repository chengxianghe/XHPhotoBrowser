# XHPhotoBrowser
photo browser

===
- 用 Objective-C 实现的photo browser的效果, 基于YYKit的Demo中的一个photoView改造而来, 仅供学习交流使用. 
- 项目依赖[YYWebImage](https://github.com/ibireme/YYWebImage)
- 支持 ARC 和 CocoaPods 
- iOS 8.0 (理论上iOS7.0也没问题, 但是我没有设备测试,所以...)

===

###CocoaPods:

`pod 'XHPhotoBrowser'`

GitHub：[chengxianghe](https://github.com/chengxianghe) 

###有什么问题请issue我

## Version 1.0.2:
- 删除多余的log
- 修复部分bug

## Version 1.0.1:
- 基本完成功能
- 支持cell中的布局显示,以view的形式,请参照demo;
- 支持collectionView的布局展示,请参照demo;
- 支持push一个controller的形式展示,请参照demo;
- 其余的功能请参照预览图;

## Features (TODO)

- [ ] 背景blur开启的时候,转屏总是有点卡,目前还没有好的方案...
- [ ] 对于reloadData的部分还没有完全测试(我测试了reloadDataWithRange,但是感觉这个功能的作用不大,考虑是不是放弃这个功能);

## Screenshots

####开启blur预览图
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower1.png?raw=true" width = "200" alt="开启blur预览图" align=center />

####以controller形式的展示
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower2.png?raw=true" width = "200" alt="以controller形式的展示" align=center />

####关闭blur 显示caption
<img src="https://github.com/chengxianghe/watch-gif/blob/master/photobrower3.png?raw=true" width = "200" alt="关闭blur 显示caption" align=center />

- GIF

####总体预览图
![image](https://github.com/chengxianghe/watch-gif/blob/master/photobrower1.gif?raw=true)

####blur预览图
![image](https://github.com/chengxianghe/watch-gif/blob/master/photobrower2.gif?raw=true)

#### Opensource libraries used

- [YYWebImage](https://github.com/ibireme/YYWebImage)

<!--## Licence-->

<!--This project uses MIT License.-->
