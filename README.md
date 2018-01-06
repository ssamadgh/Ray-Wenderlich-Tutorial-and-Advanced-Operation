# Ray Wenderlich Operation Tutorial and Advanced Operation Sample

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
	    <img src="https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat" alt="Swift 4.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgrey.svg?style=flat" alt="Platform iOS | macOS">
</a>
    <a href="https://twitter.com/ssamadgh" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@ssamadgh-blue.svg?style=flat" alt="ssamadgh Twitter">
    </a>
        </a>
    </a>
    <a href="https://www.linkedin.com/in/ssamadgh" target="_blank">
        <img src="https://img.shields.io/badge/Linkedin-ssamadgh-blue.svg?style=flat" alt="ssamadgh Linkedin">
    </a>

</p>

## Advanced Operation Sample in Swift

This is a sample code of using Advanced operation in swift.

The base sample code is taken from [NSOperation and NSOperationQueue Tutorial in Swift - Ray Wenderlich](https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift) and rewrited with using Advanced operation library of [Advanced NSOperations - WWDC 2015 - Session 226](https://developer.apple.com/videos/play/wwdc2015/226/).

## Demo
### The Starter Project

![Session](./Demo/ClassicPhoto_Starter_E.gif)

### The Ray Wenderlich Version Completed project

![Session](./Demo/ClassicPhoto_Completed_E.gif)

### The Advanced Operation Version Completed Project

![Session](./Demo/ClassicPhoto_AdvancedOperation_E.gif)


## How to use This Sample
### For learning
First of all, if you haven't enough expriment about using operations in swift, have a look to raywenderlich tutorial. the starter and completed sample codes of [raywenderlich tutorial](https://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift) are exist in this sample codes for comparing with advanced operation library using. they are updated to swift 4 syntax and you can use the if you want some help.

Next compare ClassicPhotos with Advanced Operation and 
raywenderlich tutorial. look at differents in codes and runing. for more information about using advanced operation watch [Advanced NSOperations - WWDC 2015 - Session 226 Video](https://developer.apple.com/videos/play/wwdc2015/226/).

You will see:

* How the code is encapsulated and more readable and more understandable. You can detect easily what is the duty of each file and even each method.

* How loading images and their filtering is speeded up and being more efficient.

*  Notice that the app improvement isn't cause just using advanced Operations, I converted `PhotoRecord` class to struct. It was effective to improvement the app too. Look how I updated `photos` arrray in `ListViewController` after receiving details from internet or after downloading or filtering images. I used protocol for this. Also I used `URLSession` instead of simple `Data` for downloading images.


### for using in your project

just import the `Operations` folder inside the ClassicPhotos-Advanced-Operation Folder in to your project and use it.
Although this not a complete version of Advanced Operation library. you can download complete one from [Advanced NSOperations - WWDC 2015 - Session 226 sample code](https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip).

I hope this sample code will be useful to you.