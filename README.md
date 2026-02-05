# Offline Messenger

A peer-to-peer messaging app built with Flutter that works without internet connection using local WiFi networks.

## Features

- **Offline Communication**: Works without internet connection
- **Peer Discovery**: Automatically discovers other devices on the same WiFi network
- **Real-time Messaging**: Send and receive messages instantly
- **Message History**: Stores messages locally using SQLite
- **Modern UI**: Clean and intuitive Material Design interface
- **Cross-platform**: Works on Android and iOS

## How It Works

1. **WiFi Network**: All devices must be connected to the same WiFi network
2. **Peer Discovery**: The app automatically discovers other devices running the same app
3. **Direct Communication**: Messages are sent directly between devices using TCP sockets
4. **Local Storage**: All messages are stored locally on the device

## Requirements

- Flutter SDK 3.10.0 or higher
- Android SDK (for Android development)
- iOS development tools (for iOS development)
- WiFi network for device communication

## Installation

### Prerequisites

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Set up your development environment for Android/iOS

### Setup

1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

1. Connect your device or start an emulator
2. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Starting the App

1. Launch the app on multiple devices connected to the same WiFi network
2. Enable peer discovery from the Settings tab
3. Wait for devices to appear in the Peers tab

### Sending Messages

1. Go to the Peers tab
2. Tap on a device to start chatting
3. Type and send messages
4. Messages will appear in real-time on both devices

### Managing Chats

- **Chats Tab**: View all conversation history
- **Peers Tab**: Discover and connect to new devices
- **Settings Tab**: Manage discovery settings and view device information

## Technical Details

### Architecture

- **Provider Pattern**: State management using Provider
- **SQLite**: Local message storage
- **TCP Sockets**: Peer-to-peer communication
- **WiFi Discovery**: Network-based device discovery

### Key Components

- `PeerService`: Handles peer discovery and communication
- `ChatService`: Manages messages and chat state
- `StorageService`: Handles local data persistence
- UI Components: Reusable widgets for chat interface

### Network Protocol

The app uses a simple TCP-based protocol:

- **Peer Discovery**: `PEER_DISCOVERY:{peerId}:{peerName}`
- **Peer Response**: `PEER_RESPONSE:{peerId}:{peerName}`
- **Message**: `MESSAGE:{content}`

## Permissions

The app requires the following permissions:

- **Network Access**: For peer discovery and communication
- **WiFi Access**: To scan and connect to devices
- **Storage**: For saving message history
- **Location**: Required for WiFi scanning on some Android versions

## Troubleshooting

### Devices Not Discovering Each Other

1. Ensure all devices are on the same WiFi network
2. Check that peer discovery is enabled in settings
3. Verify that WiFi is enabled and working
4. Try restarting the discovery service

### Messages Not Sending

1. Check that both devices are still connected
2. Verify peer status in the Peers tab
3. Try reconnecting to the peer

### Performance Issues

1. Close other apps using network resources
2. Restart the discovery service
3. Check WiFi signal strength

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── peer.dart            # Peer model
│   └── message.dart         # Message model
├── services/                 # Business logic
│   ├── peer_service.dart    # Peer discovery and communication
│   ├── chat_service.dart    # Message management
│   └── storage_service.dart # Local data storage
├── screens/                  # UI screens
│   ├── home_screen.dart     # Main navigation
│   ├── peer_list_screen.dart # Peer discovery
│   ├── chat_list_screen.dart # Chat history
│   ├── chat_screen.dart     # Individual chat
│   └── settings_screen.dart # App settings
└── widgets/                  # Reusable UI components
    ├── peer_tile.dart       # Peer list item
    ├── chat_tile.dart       # Chat list item
    └── message_bubble.dart  # Message display
```

### Adding Features

1. Create models in `models/` directory
2. Implement business logic in `services/`
3. Build UI components in `screens/` and `widgets/`
4. Update state management with Provider

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the technical documentation
3. Create an issue in the repository

---

**Note**: This app works only on local WiFi networks and requires no internet connectivity for messaging.
