# Vendor Store App

A comprehensive Flutter application for vendors to manage their store, products, and orders in an e-commerce marketplace.

## 📱 App Overview

The Vendor Store App is a mobile application designed specifically for vendors to manage their business operations. It provides a complete solution for product management, order processing, earnings tracking, and store profile management.

## ✨ Features

### 🔐 Authentication

- **Vendor Registration**: Create new vendor accounts with email and password
- **Secure Login**: JWT-based authentication system
- **Session Management**: Automatic login persistence using SharedPreferences

### 📦 Product Management

- **Upload Products**: Add new products with multiple images, descriptions, and pricing
- **Category System**: Organize products by categories and subcategories
- **Image Upload**: Cloudinary integration for secure image storage
- **Edit Products**: Update product information, images, and inventory
- **Product Gallery**: View all vendor products in an organized list

### 📋 Order Management

- **Order Tracking**: Real-time order status monitoring
- **Order Processing**: Mark orders as delivered or cancel them
- **Order Details**: Comprehensive view of customer information and order specifics
- **Status Updates**: Three-state order system (Processing, Delivered, Cancelled)

### 💰 Earnings Dashboard

- **Revenue Analytics**: Track total earnings and order statistics
- **Order Metrics**: Monitor delivered, processing, and cancelled orders
- **Performance Stats**: Average order value and products sold
- **Visual Analytics**: Clean dashboard with charts and statistics

### 👤 Vendor Profile

- **Store Management**: Update store image and description
- **Profile Settings**: Manage vendor information and contact details
- **Business Address**: Add and update business location
- **Security**: Change password and account settings
- **Support**: Access vendor support and guidelines

## 🛠 Technical Stack

### Frontend

- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Flutter Riverpod**: State management
- **Material Design**: UI framework

### Backend Integration

- **REST API**: HTTP-based API communication
- **JWT Authentication**: Secure token-based auth
- **Cloudinary**: Image storage and management
- **SharedPreferences**: Local data persistence

### Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1 # State management
  http: ^1.2.1 # API requests
  shared_preferences: ^2.2.3 # Local storage
  image_picker: ^1.1.2 # Image selection
  cloudinary_public: ^0.23.1 # Image upload
  google_fonts: ^6.2.1 # Typography
  cupertino_icons: ^1.0.8 # iOS-style icons
```

## 🏗 Architecture

### State Management

The app uses **Flutter Riverpod** for state management with the following providers:

- `vendorProvider`: Manages vendor authentication and profile data
- `orderProvider`: Handles order list and status updates
- `vendorProductProvider`: Manages vendor's product catalog
- `totalEarningProvider`: Calculates earnings and statistics

### Project Structure

```
lib/
├── controllers/           # Business logic and API calls
│   ├── vendor_auth_controller.dart
│   ├── product_controller.dart
│   ├── order_controller.dart
│   ├── category_controller.dart
│   └── subcategory_controller.dart
├── models/               # Data models
│   ├── vendor.dart
│   ├── product.dart
│   ├── order.dart
│   ├── category.dart
│   └── subcategory.dart
├── provider/            # Riverpod state providers
│   ├── vendor_provider.dart
│   ├── order_provider.dart
│   ├── vendor_product_provider.dart
│   └── total_earning_provider.dart
├── services/            # Utility services
│   └── manage_http_response.dart
├── views/              # UI screens and widgets
│   └── screens/
│       ├── auth/       # Authentication screens
│       ├── nav_screens/ # Main navigation screens
│       └── detail/     # Detail screens
└── global_variables.dart # App configuration
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd vendor_store_ap
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure backend URL**
   Update the API endpoint in `lib/global_variables.dart`:

```dart
String uri = 'YOUR_BACKEND_URL';
```

4. **Set up Cloudinary**
   Update Cloudinary configuration in the product controller:

```dart
final cloudinary = CloudinaryPublic("YOUR_CLOUD_NAME", 'YOUR_UPLOAD_PRESET');
```

5. **Run the application**

```bash
flutter run
```

## 📱 App Screens

### Authentication Flow

- **Login Screen**: Vendor authentication with email/password
- **Register Screen**: New vendor account creation

### Main Navigation

- **Earnings Dashboard**: Revenue analytics and statistics
- **Upload Products**: Add new products to inventory
- **Edit Products**: Manage existing product catalog
- **Orders**: View and manage customer orders
- **Profile**: Vendor account and store management

### Detail Screens

- **Order Details**: Comprehensive order management
- **Product Edit**: Detailed product modification
- **Profile Settings**: Store and account configuration

## 🔧 Configuration

### API Endpoints

The app communicates with the following API endpoints:

- `POST /api/v2/vendor/signup` - Vendor registration
- `POST /api/v2/vendor/signin` - Vendor authentication
- `GET /api/categories` - Fetch product categories
- `GET /api/category/{name}/subcategory` - Fetch subcategories
- `POST /api/add-product` - Upload new product
- `PUT /api/edit-product/{id}` - Update product
- `GET /api/products/vendor/{id}` - Get vendor products
- `GET /api/orders/vendors/{id}` - Get vendor orders
- `PATCH /api/orders/{id}/delivered` - Mark order as delivered
- `PATCH /api/orders/{id}/processing` - Update order processing status

### Environment Setup

- Development: `http://your_ip:3000`
- Production: Update `global_variables.dart` with production URL

## 🧪 Testing

Run tests using:

```bash
flutter test
```

## 📦 Building

### Android APK

```bash
flutter build apk --release
```

### iOS IPA

```bash
flutter build ios --release
```

## 🔒 Security Features

- JWT token-based authentication
- Secure API communication with proper headers
- Local secure storage for authentication tokens
- Input validation and error handling
- HTTPS enforcement for production

## 🐛 Troubleshooting

### Common Issues

1. **Network Connection Errors**

   - Verify backend URL in `global_variables.dart`
   - Check device/emulator internet connection

2. **Image Upload Failures**

   - Confirm Cloudinary credentials
   - Check image file size and format

3. **Authentication Issues**
   - Clear app data and re-login
   - Verify token expiration handling

### Debug Mode

The app includes comprehensive logging. Check console output for:

- API request/response details
- State management updates
- Error stack traces

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ using Flutter**
