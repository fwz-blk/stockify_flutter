# 📦 Stockify Flutter App

Smart inventory & ordering platform for Kirana shops — Flutter mobile version.

## Features

✅ **Owner Side**
- Dashboard with stats (products, orders, low stock, inventory value)
- Full product management (add, edit, update stock)
- Live customer orders with complete/pending filter
- Low stock alerts with one-tap restock
- Walk-in billing with receipt generation
- Bill history with revenue tracking
- Stock manager with add/set modes
- QR code generation for shop

✅ **Customer Side**  
- Enter shop by ID
- Browse products with category filter & search
- Real-time stock indicators
- Shopping cart with qty controls
- Order placement with Supabase backend sync
- Order success screen with advance payment info

## 🚀 Quick Setup

### Prerequisites
- Flutter SDK 3.0+ installed → [flutter.dev](https://flutter.dev/docs/get-started/install)
- Android Studio or Xcode

### Steps

```bash
# 1. Navigate to project folder
cd stockify_flutter

# 2. Install dependencies
flutter pub get

# 3. Run on Android
flutter run

# 4. Run on iOS (Mac only)
cd ios && pod install && cd ..
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & router
├── theme.dart                   # Colors, theme config
├── models/
│   └── models.dart              # Shop, Product, Order, Bill etc.
├── services/
│   └── supabase_service.dart    # All DB operations
├── state/
│   └── app_state.dart           # Global state (Provider)
├── widgets/
│   └── widgets.dart             # Shared UI components
└── screens/
    ├── landing_screen.dart
    ├── auth_screen.dart
    ├── owner_setup_screen.dart
    ├── owner_dashboard.dart
    ├── customer_dashboard.dart
    ├── customer_shop_screen.dart
    ├── order_success_screen.dart
    └── owner/
        ├── dashboard_page.dart
        ├── products_page.dart
        ├── orders_page.dart
        ├── low_stock_page.dart
        ├── billing_page.dart
        └── qr_code_page.dart
```

## 🔧 Supabase Configuration

The app is already connected to your Supabase instance. If you need to change it, update these values in:

**`lib/main.dart`** and **`lib/services/supabase_service.dart`**:
```dart
const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseKey = 'YOUR_ANON_KEY';
```

### Required Supabase Tables

Make sure your Supabase database has these tables:

```sql
-- Shops
create table shops (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users,
  name text not null,
  phone text,
  created_at timestamptz default now()
);

-- Products
create table products (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid references shops(id),
  name text not null,
  category text,
  price numeric not null,
  stock integer default 0,
  unit text default 'pcs',
  created_at timestamptz default now()
);

-- Orders
create table orders (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid references shops(id),
  customer_name text,
  total numeric,
  status text default 'pending',
  created_at timestamptz default now()
);

-- Order Items
create table order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id),
  product_name text,
  qty integer,
  price numeric,
  created_at timestamptz default now()
);
```

Enable Row Level Security and add policies as needed.

## 🎨 Design System

The app mirrors the web version's dark theme:
- Primary: `#0A0A0F`
- Accent: `#6C63FF` (purple)
- Danger: `#FF6584` (pink)
- Success: `#43D9AD` (teal)
- Warning: `#FFB347` (orange)
- Font: Inter (via google_fonts)

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend (auth, database) |
| `provider` | State management |
| `google_fonts` | Inter font |
| `qr_flutter` | QR code generation |
| `mobile_scanner` | QR code scanning |
| `shared_preferences` | Persist login role |
| `intl` | Date/number formatting |
| `uuid` | Unique IDs |

## 📱 Build for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS (Mac only)
```bash
flutter build ios --release
# Then archive in Xcode for App Store
```
