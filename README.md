<!-- <!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).


TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more. -->

# A flutter plugin for scanning qr code in Android & iOS.


CameraSource class’s required and optional parameters and functions.

| Parameter | Type     | Working | Default value |
| :-------- | :------- | :--------- |:--------- |
| `onDetect(barcode){}` | `required` | When a barcode is<br/>detected successfully then<br/>the barcode data will<br/>be available in this <br/>function. | _
|`immersive` | `optional` | _ | true
|`stopOnFound` | `optional` | If TRUE, then the scanner window will close automatically. | false
|`resolution` | `optional` | Affect the quality of video recording and image capture | ResolutionPreset.high

## Usage

```dart
import 'package:qr_scanner/qr_scanner.dart';

Navigator.of(context).push(
              MaterialPageRoute(
                maintainState: false,
                builder: (context) {
                  return CameraSource(
                    immersive: false,
                    stopOnFound: true,
                    onDetect: (barcode) async {
                    //DO YOUR STUFF WITH THE BARCODE DATA
                    },
                  );
                },
              ),
            );
```

## Detected QrCode data

```dart
onDetect: (barcode) async{
    ...
}
```

| Parameter | Type     | 
| :-------- | :------- | 
|`barcode.value` | A barcode value depending on the [BarcodeType] type set.
|`barcode.type` | The format type of barcode.
|`barcode.rawValue` | A barcode value as it was encoded in the barcode.
|`barcode.rawBytes` | Barcode bytes as encoded in the barcode.
|`barcode.format` | The format (symbology) of the barcode value.
|`barcode.displayValue` | A barcode value in a user-friendly format.<br/>This value may be multiline, <br/>for example, when line breaks<br/>are encoded into the original<br/>TEXT barcode value. May include<br/>the supplement value.



## License

[MIT](https://choosealicense.com/licenses/mit/)