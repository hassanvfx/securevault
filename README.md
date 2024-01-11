
# SecureVault

![image](https://github.com/hassanvfx/securevault/assets/425926/d599c4a1-37a2-4152-8994-805c8c6b3814)


SecureVault is a Swift library designed to provide fully encrypted disk storage for iOS applications. It leverages the robustness of Apple's Keychain services to enhance the security of data stored on the device. The library offers a simple Key-Value interface for easy integration with existing projects.

## Features

- **Fully Encrypted Disk Storage**: SecureVault ensures that all data stored on disk is fully encrypted, providing an additional layer of security.
- **Dynamic Key Generation**: The encryption key is dynamically generated at installation time and securely stored in the iOS Keychain.
- **Keychain Stored Key**: The library utilizes the Keychain to store the encryption key, ensuring it's never written to any unsafe location.
- **Runtime Key Exposure**: The encryption key is only exposed during runtime, minimizing the risk of key compromise.
- **AES.GCM + 256 SecureKey Encryption** As suggested by [Dave Poireir](https://www.linkedin.com/in/dave-poirier-a9b25a9/)
- **Swift Actor for Tread Safety** As suggested by [Dave Poireir](https://www.linkedin.com/in/dave-poirier-a9b25a9/)
  
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

## How It Works and Security

### How It Works
SecureVault operates by creating an encrypted storage on the disk. At the heart of its operation is the dynamic generation of an encryption key when the application is installed. This key is not stored in the usual file system; instead, it is securely saved in the iOS Keychain, a robust and secure system specifically designed for sensitive data.

The main functionality of SecureVault involves encrypting and decrypting data. When data is to be saved, it is first encrypted using the stored key, then written to the disk. Conversely, when data is read, it is decrypted using the same key. This process ensures that data is always stored in an encrypted form, and only decrypted when needed.

### Why It Is Secure
- **Keychain Storage**: By storing the encryption key in the iOS Keychain, SecureVault takes advantage of Apple's secure storage system, which is resistant to common hacking techniques.
- **Dynamic Key Generation**: The key is generated dynamically upon installation, which means it's unique for each installation, enhancing security against brute-force attacks.
- **Runtime Key Exposure**: The key is only exposed in memory during runtime, significantly reducing the risk of it being compromised.

## Caveats

While SecureVault offers robust security, there are some considerations to keep in mind:

- **Performance Overhead**: Encryption and decryption processes add a layer of computational overhead. For large volumes of data, this could potentially affect the performance of the app.
- **Keychain Access Restrictions**: Since the key is stored in the Keychain, any limitations or issues with Keychain access (like OS-level restrictions or Keychain corruption) could affect the functionality of SecureVault.
- **Data Recovery Limitations**: If the Keychain data is lost or corrupted, the encrypted data might become unrecoverable, as the unique encryption key is lost.
- **Dependence on iOS Security**: The security of SecureVault is partially reliant on the underlying security of the iOS Keychain. Any vulnerabilities in the iOS Keychain system could potentially affect SecureVault.

It's important for developers to weigh these caveats against their specific needs and the sensitivity of the data they are handling.

## Contributing

Contributions to SecureVault are welcome. Please submit pull requests with any enhancements or bug fixes.

## License

SecureVault is released under the MIT License. See [LICENSE](LICENSE) for details.

## Author

Created by Eon Fluxor.

# SPM 

This framework was built with the ios-framework  config tool.
[https://github.com/hassanvfx/ios-framework](https://github.com/hassanvfx/ios-framework)
