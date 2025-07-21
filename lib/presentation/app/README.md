# App Bloc - Bloc và State chung cho toàn ứng dụng

## Mô tả

AppBloc và AppState là hệ thống quản lý state chung cho toàn bộ ứng dụng, bao gồm:

- **Loading toàn app**: Hiển thị loading overlay khi cần thiết
- **Thông báo toàn app**: Quản lý các message/notification 
- **Theme management**: Quản lý dark/light mode
- **Ngôn ngữ**: Quản lý đa ngôn ngữ
- **Network status**: Theo dõi trạng thái kết nối mạng
- **App configuration**: Lưu trữ các cấu hình chung
- **Master Data Cache**: Cache và quản lý các list data chung (Units, Products, Customers, Groups, Areas, Wards, Languages)

## Cấu trúc

```
lib/presentation/app/
├── logics/
│   ├── app_bloc.dart       # AppBloc chính
│   ├── app_events.dart     # Các events (bao gồm master data events)
│   └── app_state.dart      # App state, AppMessage và MasterDataCache
├── widgets/
│   ├── app_loading_overlay.dart    # Widget hiển thị loading
│   └── app_message_listener.dart   # Widget lắng nghe messages
├── app_bloc_extension.dart         # Extension helpers (bao gồm master data)
├── master_data_manager.dart        # Manager để load master data
└── README.md
```

## Cách sử dụng

### 1. Import extension

```dart
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';
```

### 2. Sử dụng các phương thức cơ bản

```dart
class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Hiển thị loading
              context.showAppLoading('Đang tải dữ liệu...');
              
              // Simulate async task
              Future.delayed(Duration(seconds: 2), () {
                context.hideAppLoading();
                context.showAppSuccess('Tải dữ liệu thành công!');
              });
            },
            child: Text('Hiển thị Loading'),
          ),
          
          ElevatedButton(
            onPressed: () {
              // Hiển thị các loại thông báo
              context.showAppError('Có lỗi xảy ra!');
              context.showAppWarning('Cảnh báo!');
              context.showAppInfo('Thông tin quan trọng');
            },
            child: Text('Hiển thị Messages'),
          ),
          
          ElevatedButton(
            onPressed: () {
              // Toggle theme
              context.toggleAppTheme();
            },
            child: Text('Đổi Theme'),
          ),

          ElevatedButton(
            onPressed: () {
              // Load master data
              context.loadAllMasterData(forceRefresh: true);
            },
            child: Text('Load Master Data'),
          ),
        ],
      ),
    );
  }
}
```

### 3. Sử dụng với async tasks

```dart
// Chạy async task với loading tự động
await context.runWithLoading(
  () async {
    // Your async operation
    await apiService.getData();
  },
  loadingMessage: 'Đang tải...',
  successMessage: 'Thành công!',
  showSuccess: true,
);

// Chạy async task với error handling
await context.runSafely(
  () async {
    await riskyOperation();
  },
  errorMessage: 'Lỗi khi thực hiện tác vụ',
);
```

### 4. Sử dụng Master Data

```dart
class ProductListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Truy cập master data qua extension
    final products = context.products;
    final units = context.units;
    
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final unit = context.findUnitByCode(product.unitCode ?? '');
        
        return ListTile(
          title: Text(product.name ?? ''),
          subtitle: Text('${product.priceSale} - ${unit?.label ?? ''}'),
        );
      },
    );
  }
}

// Sử dụng trong màn hình
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh products data
              context.loadMasterDataType(MasterDataType.products, forceRefresh: true);
            },
          ),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (context.isMasterDataLoading(MasterDataType.products)) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!context.isMasterDataLoaded(MasterDataType.products)) {
            return Center(
              child: ElevatedButton(
                onPressed: () => context.loadMasterDataType(MasterDataType.products),
                child: Text('Load Products'),
              ),
            );
          }
          
          return ProductListWidget();
        },
      ),
    );
  }
}
```

### 5. Lắng nghe state changes

```dart
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.isGlobalLoading) 
              Text('Đang loading...'),
            
            Text('Theme: ${state.isDarkMode ? 'Dark' : 'Light'}'),
            Text('Ngôn ngữ: ${state.languageCode}'),
            Text('Mạng: ${state.isOnline ? 'Online' : 'Offline'}'),
            
            // Hiển thị thông tin master data
            Text('Products: ${state.masterDataCache.products.length}'),
            Text('Customers: ${state.masterDataCache.customers.length}'),
            Text('Units: ${state.masterDataCache.units.length}'),
            
            if (state.hasMessage)
              Text('Message: ${state.currentMessage?.message}'),
          ],
        );
      },
    );
  }
}
```

### 6. Truy cập trực tiếp AppBloc

```dart
final appBloc = context.read<AppBloc>();

// Hoặc
final appBloc = GetIt.I<AppBloc>();

// Sử dụng
appBloc.showSuccess('Thành công!');
appBloc.toggleTheme();
appBloc.setLanguage('en');

// Master Data
appBloc.loadAllMasterData(forceRefresh: true);
appBloc.loadMasterDataType(MasterDataType.units);
appBloc.clearMasterData();

// Truy cập master data
final products = appBloc.state.masterDataCache.products;
final isLoading = appBloc.state.masterDataCache.isLoading(MasterDataType.products);
```

## Events chính

### App Events
- `AppInitialized`: Khởi tạo app
- `ShowGlobalLoading`: Hiển thị loading
- `HideGlobalLoading`: Ẩn loading  
- `ShowAppMessage`: Hiển thị thông báo
- `HideAppMessage`: Ẩn thông báo
- `ChangeTheme`: Thay đổi theme
- `ChangeLanguage`: Thay đổi ngôn ngữ
- `UpdateNetworkStatus`: Cập nhật trạng thái mạng
- `UpdateAppConfig`: Cập nhật cấu hình
- `ResetAppState`: Reset state

### Master Data Events
- `LoadMasterData`: Load tất cả master data
- `LoadSpecificMasterData`: Load một loại master data cụ thể
- `ClearMasterDataCache`: Clear cache master data

### Master Data Types
- `MasterDataType.units`: Đơn vị
- `MasterDataType.products`: Sản phẩm
- `MasterDataType.customers`: Khách hàng
- `MasterDataType.groups`: Nhóm
- `MasterDataType.areas`: Khu vực
- `MasterDataType.wards`: Phường/Xã
- `MasterDataType.languages`: Ngôn ngữ

## Lưu ý

1. AppBloc đã được đăng ký trong `locator.dart` và `my_app.dart`
2. Loading overlay sẽ hiển thị trên toàn bộ app khi `isGlobalLoading = true`
3. Messages sẽ hiển thị dưới dạng SnackBar với màu sắc phù hợp theo loại
4. Theme preferences được lưu vào SharedPreferences tự động
5. AppBloc tự động khởi tạo khi app start
6. **Master Data tự động load khi app khởi tạo** - không cần gọi manual
7. Master Data được cache và chỉ refresh sau 1 giờ hoặc khi force refresh
8. Có thể truy cập master data qua extension methods từ bất kỳ BuildContext nào
9. MasterDataManager cung cấp các utility methods để filter và search data

## Mở rộng

Để thêm tính năng mới:

1. Thêm event mới vào `app_events.dart`
2. Cập nhật state trong `app_state.dart` 
3. Implement handler trong `app_bloc.dart`
4. Thêm helper method vào `app_bloc_extension.dart` nếu cần 