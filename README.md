# Employee Attendance System (HRIS)

A comprehensive, mobile-first Employee Attendance Management System built with Flutter. This application provides a complete solution for managing employee attendance, leave requests, and generating reports.

## 🚀 Features

### Core Features
- **Authentication & Security**
  - Secure login system
  - User session management
  - Password protection

- **Attendance Management**
  - Check-in/Check-out functionality
  - Location-based attendance
  - Attendance history tracking
  - Attendance correction requests

- **Dashboard & Analytics**
  - Real-time attendance overview
  - Monthly statistics
  - Quick action buttons
  - Recent activity feed

- **Leave Management**
  - Leave request submission
  - Leave balance tracking
  - Leave history
  - Multiple leave types (Annual, Sick, Personal)

- **Reports & Analytics**
  - Monthly attendance reports
  - Attendance statistics
  - Export capabilities

- **Settings & Profile**
  - User profile management
  - Password change functionality
  - App preferences
  - Theme customization

## 📱 Screenshots

### Main Screens
- **Login Screen**: Secure authentication with email/password
- **Dashboard**: Overview of today's attendance and quick actions
- **Attendance**: Check-in/out and attendance management
- **Leave**: Leave request and management
- **Reports**: Monthly attendance reports
- **Settings**: User preferences and account management

## 🏗️ Architecture

### File Structure
```
lib/
├── components/           # Reusable UI components
│   └── common/          # Common components (Button, Input, Card, etc.)
├── core/               # Core application files
│   ├── routes/         # Navigation and routing
│   └── theme/          # App theming and styling
├── models/             # Data models
├── screens/            # Application screens
│   ├── login/          # Authentication screens
│   ├── dashboard/      # Dashboard screens
│   ├── attendance/     # Attendance management screens
│   ├── leave/          # Leave management screens
│   ├── report/         # Report screens
│   └── settings/       # Settings screens
├── services/           # Business logic and API services
└── main.dart          # Application entry point
```

### Key Components

#### Reusable Components
- **AppButton**: Customizable button with multiple variants
- **AppInput**: Form input with validation support
- **AppCard**: Card component with header and content sections
- **AppBottomNavigation**: Bottom navigation with routing

#### Core Features
- **AppTheme**: Comprehensive theming system with light/dark modes
- **AppRouter**: Centralized routing with named routes
- **AuthService**: Authentication and user management
- **AttendanceService**: Attendance data management

## 🎨 Design System

### Color Palette
- **Primary**: Blue (#2563EB)
- **Secondary**: Green (#10B981)
- **Accent**: Orange (#F59E0B)
- **Error**: Red (#EF4444)
- **Success**: Green (#22C55E)
- **Warning**: Orange (#F97316)

### Typography
- **Heading Large**: 32px, Bold
- **Heading Medium**: 24px, Semi-bold
- **Heading Small**: 20px, Semi-bold
- **Body Large**: 16px, Regular
- **Body Medium**: 14px, Regular
- **Body Small**: 12px, Regular

### Responsive Design
- Mobile-first approach
- Adaptive layouts for different screen sizes
- Touch-friendly interface elements
- Optimized for both portrait and landscape orientations

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Material Design 3**: Design system

### Dependencies
- **http**: HTTP client for API calls
- **shared_preferences**: Local data storage
- **intl**: Internationalization and date formatting
- **geolocator**: Location services
- **image_picker**: Image selection for profile photos

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd attendance_system_hris
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Configuration

#### Authentication
- Default login credentials:
  - Email: `admin@example.com`
  - Password: `password`

#### Environment Setup
- Update API endpoints in service files
- Configure location services permissions
- Set up push notifications (optional)

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 11.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (Windows 10+)
- ✅ macOS (macOS 10.14+)
- ✅ Linux (Ubuntu 18.04+)

## 🔧 Development

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Implement proper error handling
- Add comments for complex logic

### Testing
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📊 Features Roadmap

### Phase 1 (Current)
- ✅ Basic authentication
- ✅ Attendance check-in/out
- ✅ Dashboard overview
- ✅ Leave management
- ✅ Settings and profile

### Phase 2 (Planned)
- 🔄 Real-time notifications
- 🔄 Advanced reporting
- 🔄 Team management
- 🔄 Offline support
- 🔄 Biometric authentication

### Phase 3 (Future)
- 📋 AI-powered attendance insights
- 📋 Integration with HR systems
- 📋 Advanced analytics
- 📋 Multi-language support
- 📋 Custom workflows

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: Ayush Bajagain
- **Design**: Ayush Bajagain
- **Project Manager**: Ayush Bajagain

## 📞 Support

For support and questions:
- Email: support@attendance-system.com
- Documentation: [Wiki Link]
- Issues: [GitHub Issues](https://github.com/your-repo/issues)

---

**Built with ❤️ using Flutter**
