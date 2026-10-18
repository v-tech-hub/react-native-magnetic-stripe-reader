# React Native Magnetic Stripe Reader

Parse ISO/IEC 7813 bank-card Track 1 and Track 2 strings on Android and iOS.
Both platforms expose the same React Native callback API.

## Installation

```sh
npm install react-native-magnetic-stripe-reader
```

React Native 0.60 and newer autolinks the native module. For iOS, install the
CocoaPods dependency after adding the package:

```sh
cd ios
pod install
```

## Usage

```javascript
import MagneticStripeReader from 'react-native-magnetic-stripe-reader';

const rawData =
  '%B5350290149345177^FATEHI/SUALEH^16042010000000000000000000000000000567001000?' +
  ';5350290149345177=16042010000056700100?';

// 1 returns the parsed tracks. 2 returns normalized card information.
MagneticStripeReader.readBankCardData(rawData, 1, result => {
  if (result.success) {
    console.log(result);
  } else {
    console.warn(result.message);
  }
});
```

### Conversion types

| Type | Result |
| --- | --- |
| `1` | Track-level data in `TRACK1`, `TRACK2`, and, on Android, `TRACK3` |
| `2` | Normalized card information, including PAN validation, brand, expiration, cardholder name, and service code |

Values other than `2` retain the existing Android behavior and are treated as
type `1`.

## Track result

```javascript
{
  success: true,
  message: 'ok',
  TRACK1: {
    rawData: '%B5350290149345177^FATEHI/SUALEH^16042010000000000000000000000000000567001000?',
    'primaryAccountNumber:': '5350290149345177',
    expirationDate: '2016-04',
    name: 'Sualeh Fatehi',
    discretionaryData: '0000000000000000000000000000000000567001000'
  },
  TRACK2: {
    rawData: ';5350290149345177=16042010000056700100?',
    'primaryAccountNumber:': '5350290149345177',
    expirationDate: '2016-04',
    discretionaryData: '0000056700100'
  }
}
```

The colon in `primaryAccountNumber:` is retained for backward compatibility.

## Card-information result

```javascript
{
  success: true,
  message: 'ok',
  rawAccountNumber: '5350290149345177',
  primaryAccountNumber: '5350290149345177',
  majorIndustryIdentifier: 'mii_5',
  issuerIdentificationNumber: '535029',
  cardBrand: 'MasterCard',
  lastFourDigits: '5177',
  passesLuhnCheck: true,
  isPrimaryAccountNumberValid: true,
  expirationDate: '2016-04',
  isExpired: true,
  name: 'Sualeh Fatehi',
  serviceCode1: {
    code: 2,
    description: 'Interchange: International interchange. Technology: Integrated circuit card.'
  },
  serviceCode2: {
    code: 0,
    description: 'Authorization Processing: Normal.'
  },
  serviceCode3: {
    code: 1,
    description: 'Allowed Services: No restrictions. PIN Requirements: None.'
  }
}
```

Invalid or unsupported input returns:

```javascript
{
  success: false,
  message: 'No data found'
}
```

## Platform support

- Android: Track 1, Track 2, Track 3 passthrough, and normalized card data.
- iOS: Track 1, Track 2, and normalized card data.
- Minimum Android SDK: 16, unless overridden by the host application.
- Minimum iOS version: 9.0, subject to the React Native version used by the host application.

## Security

Magnetic-stripe data contains sensitive payment-card information. Avoid logging,
persisting, or transmitting raw track data unless your application and handling
process meet the applicable security and PCI DSS requirements.

## License

Apache License 2.0.
