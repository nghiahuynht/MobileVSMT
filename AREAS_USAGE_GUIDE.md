# Hướng dẫn sử dụng Areas từ AppBloc

## Tổng quan

Ứng dụng đã được cập nhật để gọi API `getAreas` khi khởi tạo app (nếu user đã đăng nhập) và lưu vào `AppState`. Dữ liệu areas này có thể được sử dụng ở bất kỳ đâu trong app một cách dễ dàng.

## Cách hoạt động

1. **Khởi tạo app**: `AppBloc` tự động kiểm tra trạng thái đăng nhập và gọi API `getAreas` nếu user đã đăng nhập
2. **Đăng nhập**: Sau khi đăng nhập thành công, `LoadAreasAfterLogin` event được gọi để load areas
3. **Truy cập dữ liệu**: Sử dụng các helper widgets và extensions để truy cập areas ở bất kỳ đâu

## Cách sử dụng

### 1. Sử dụng Extension (Khuyến nghị)

```dart
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';

// Trong BuildContext
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final areas = context.areas; // Lấy danh sách areas
    final isInitialized = context.isAppInitialized; // Kiểm tra đã khởi tạo
    
    return Column(
      children: [
        Text('Có ${areas.length} khu vực'),
        // Reload areas nếu cần
        ElevatedButton(
          onPressed: () => context.reloadAreas(),
          child: Text('Reload Areas'),
        ),
      ],
    );
  }
}
```

### 2. Sử dụng Helper Class (Không cần BuildContext)

```dart
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';

// Sử dụng từ bất kỳ đâu
void someFunction() {
  final areas = AppBlocHelper.areas; // Lấy danh sách areas
  final isInitialized = AppBlocHelper.isAppInitialized;
  
  if (areas.isNotEmpty) {
    print('First area: ${areas.first.name}');
  }
  
  // Reload areas
  AppBlocHelper.reloadAreas();
}
```

### 3. Sử dụng AreasBuilder Widget

```dart
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';

class AreasDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AreasBuilder(
      builder: (context, areas) {
        return ListView.builder(
          itemCount: areas.length,
          itemBuilder: (context, index) {
            final area = areas[index];
            return ListTile(
              title: Text(area.name),
              subtitle: Text('Group ID: ${area.groupId}'),
            );
          },
        );
      },
      loadingBuilder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### 4. Sử dụng Widget có sẵn

```dart
import 'package:trash_pay/presentation/widgets/common/areas_dropdown_widget.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  Area? selectedArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown areas với filter theo group
        AreasDropdownWidget(
          selectedArea: selectedArea,
          onChanged: (area) => setState(() => selectedArea = area),
          hintText: 'Chọn khu vực',
          filterByGroupId: 1, // Lọc theo group ID
          showAllOption: true,
          allOptionText: 'Tất cả khu vực',
        ),
        
        SizedBox(height: 20),
        
        // Hiển thị danh sách areas
        Expanded(
          child: AreasListWidget(
            onAreaTap: (area) {
              print('Selected area: ${area.name}');
            },
            showGroupInfo: true,
          ),
        ),
      ],
    );
  }
}
```

### 5. Sử dụng BlocBuilder truyền thống

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_bloc.dart';
import 'package:trash_pay/presentation/app/logics/app_state.dart';

class TraditionalUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (!state.isInitialized) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            Text('Areas: ${state.areas.length}'),
            ...state.areas.map((area) => ListTile(
              title: Text(area.name),
            )),
          ],
        );
      },
    );
  }
}
```

## Kiểm tra trạng thái khởi tạo

```dart
import 'package:trash_pay/presentation/app/app_bloc_extension.dart';

class AppInitializationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppInitializationBuilder(
      builder: (context) {
        // App đã khởi tạo xong, hiển thị nội dung chính
        return MainContent();
      },
      loadingBuilder: (context) {
        // App chưa khởi tạo xong, hiển thị loading
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang khởi tạo ứng dụng...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

## Lưu ý quan trọng

1. **Areas chỉ được load khi user đã đăng nhập**
2. **Data được cache trong AppBloc**, không cần gọi API lại nhiều lần
3. **Sử dụng `AreasBuilder` để tự động handle loading state**
4. **Có thể reload areas bằng cách gọi `LoadAreasAfterLogin` event**
5. **Areas được filter theo `groupId` nếu cần**

## Cấu trúc file

```
lib/presentation/app/
├── logics/
│   ├── app_bloc.dart           # AppBloc chính với logic load areas
│   ├── app_events.dart         # Bao gồm LoadAreasAfterLogin event  
│   └── app_state.dart          # AppState chứa areas
├── app_bloc_extension.dart     # Extensions và helper widgets
└── widgets/
    └── common/
        └── areas_dropdown_widget.dart  # Widget có sẵn để dùng areas
```

## Ví dụ thực tế

Xem file `lib/presentation/customer/customer_list_screen.dart` để thấy cách `AreasBuilder` được sử dụng thay thế cho việc lấy areas từ `CustomerBloc`. 