# ShopFlow - Modern E-commerce Product Browser

A sleek Flutter product listing application with search, favorites, and dark mode support.

## 🚀 Features

### Core Features
- ✅ **Product Grid** - Beautiful grid layout with high-quality images
- ✅ **Search Functionality** - Search by title, category, or description
- ✅ **Category Filter** - Filter products by category with smooth animations
- ✅ **Pull-to-Refresh** - Refresh product data with pull gesture
- ✅ **Product Details** - Detailed product view with ratings and descriptions
- ✅ **Loading States** - Shimmer loading effects for better UX

### Advanced Features
- ✅ **Favorites System** - Save and manage favorite products
- ✅ **Dark Mode** - Toggle between light and dark themes
- ✅ **Error Handling** - Graceful error states with retry options
- ✅ **Responsive UI** - Works perfectly on different screen sizes
- ✅ **Image Caching** - Cached network images for better performance
- ✅ **API Integration** - Real-time data from FakeStore API

### Bonus Features
- ✅ **Theme Toggle** - Switch between light and dark modes
- ✅ **Favorites Counter** - Badge showing number of favorites
- ✅ **Product Ratings** - Star ratings and review counts
- ✅ **Price Formatting** - Proper currency formatting
- ✅ **Category Display** - User-friendly category names

## 🏗️ Architecture

```
lib/
├── models/          # Product data models with JSON serialization
├── providers/       # State management using Riverpod
├── screens/         # UI screens (Home, Product Detail, Favorites)
├── widgets/         # Reusable UI components
├── services/        # API and storage services
└── utils/           # Helper functions and extensions
```

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **Riverpod** - State management
- **HTTP** - API calls
- **Cached Network Image** - Image caching
- **Shimmer** - Loading animations
- **Hive** - Favorites storage

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK

### Installation

1. **Navigate to the project**
   ```bash
   cd shopflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Home Screen
- Product grid with beautiful cards
- Search bar with real-time filtering
- Category filter chips
- Dark mode toggle

### Product Detail Screen
- High-quality product images
- Detailed product information
- Star ratings and reviews
- Add to favorites button

### Favorites Screen
- Saved favorite products
- Clear all favorites option
- Empty state illustration

## 🎯 Key Features Explained

### State Management
Uses Riverpod for modern, type-safe state management:
- `ProductNotifier` - Product data management
- `FavoritesNotifier` - Favorites management
- `SearchNotifier` - Search query management
- `ThemeNotifier` - Theme management

### API Integration
Real-time data from FakeStore API:
- Product listings
- Product details
- Category filtering
- Error handling

### UI/UX Design
Modern Material Design 3:
- Consistent theming
- Smooth animations
- Responsive grid layout
- Beautiful loading states

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Coverage
- Unit tests for API services
- Widget tests for UI components
- Provider tests for state management

## 📦 Build

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### Web Build
```bash
flutter build web --release
```

## 🔧 Development

### Code Generation
```bash
flutter packages pub run build_runner build
```

### Linting
```bash
flutter analyze
```

### Formatting
```bash
flutter format .
```

## 🌐 API Endpoints

The app uses the FakeStore API:
- `GET /products` - Get all products
- `GET /products/{id}` - Get product by ID
- `GET /products/category/{category}` - Get products by category
- `GET /products/categories` - Get all categories

## 🚀 Future Enhancements

- [ ] Shopping cart functionality
- [ ] User authentication
- [ ] Product reviews and ratings
- [ ] Payment integration
- [ ] Offline support
- [ ] Push notifications
- [ ] Product comparison
- [ ] Wishlist sharing

## 📄 License

Created for ETESTICANOW Assessment

---

**ShopFlow** - Your modern shopping experience! 🛍️