
# SecureVault

SecureVault is a Swift library designed to provide fully encrypted disk storage for iOS applications. It leverages the robustness of Apple's Keychain services to enhance the security of data stored on the device. The library offers a simple Key-Value interface for easy integration with existing projects.

## Features

- **Fully Encrypted Disk Storage**: SecureVault ensures that all data stored on disk is fully encrypted, providing an additional layer of security.
- **Dynamic Key Generation**: The encryption key is dynamically generated at installation time and securely stored in the iOS Keychain.
- **Keychain Stored Key**: The library utilizes the Keychain to store the encryption key, ensuring it's never written to any unsafe location.
- **Runtime Key Exposure**: The encryption key is only exposed during runtime, minimizing the risk of key compromise.

## Usage

To use SecureVault in your project, import the library and initialize it:

```swift
import SecureVault

let secureVault = SecureVault(namespace: "yourNamespace")
```

### Storing Data

```swift
let key = "yourKey"
let value = "yourValue"
await secureVault.set(key: key, value: value)
```

### Retrieving Data

```swift
let retrievedValue = await secureVault.get(key: "yourKey")
```

## Testing

SecureVault includes unit tests to verify its functionality. To run the tests:

1. Clone the repository.
2. Open the project in Xcode.
3. Run the tests using the Xcode test navigator.

## Contributing

Contributions to SecureVault are welcome. Please submit pull requests with any enhancements or bug fixes.

## License

SecureVault is released under the MIT License. See [LICENSE](LICENSE) for details.

## Author

Created by Eon Fluxor.

# SPM 

This framework was built with the ios-framework  config tool.
[https://github.com/hassanvfx/ios-framework](https://github.com/hassanvfx/ios-framework)
