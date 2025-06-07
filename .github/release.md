# Changelog

## :rocket: New Rust-based Http Client
A new option is now available: rhttp, a Rust-based HTTP client to boost download performance compared to the default Dart HTTP client.

Since rhttp uses FFI, it requires additional system resources, as it spawns extra threads to allow for communication between the Rust layer and the Dart app.

You can enable this client via:

`Settings → Connection → Download Engine → HTTP Client Type → Performance (Experimental).`

Because this feature is still new, it remains opt-in and is not enabled by default. The default client remains the Dart-based HTTP client due to its proven stability and compatibility with the download engine.

## :hammer_and_wrench: Bug Fixes and Improvements
- Fixed a Github dialog reappearing issue
- Fixed downloading video stream issues from some websites
- Fixed app crashing on macOS
