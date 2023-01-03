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
import 'package:quick_qr/quick_qr.dart';

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