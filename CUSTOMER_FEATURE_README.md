# Chức Năng Thêm Khách Hàng - TrashPay

## Tổng Quan

Chức năng thêm khách hàng mới đã được tích hợp vào ứng dụng TrashPay với đầy đủ các trường thông tin theo yêu cầu:

- **Tên khách hàng** (bắt buộc)
- **Số điện thoại** (tùy chọn)
- **Phường xã** (bắt buộc) - Lấy dữ liệu từ API
- **Địa chỉ** (tùy chọn)
- **Tổ** (bắt buộc) - Lấy dữ liệu từ API dựa trên phường xã đã chọn
- **Khu** (bắt buộc) - Lấy dữ liệu từ API dựa trên tổ đã chọn
- **Nhóm khách hàng** (bắt buộc) - Thường, VIP, Cao cấp
- **Giá tiền** (bắt buộc) - Giá tiền dịch vụ

## Cấu Trúc Files

### Entities
- `lib/domain/entities/location/ward.dart` - Entity Phường xã
- `lib/domain/entities/location/group.dart` - Entity Tổ
- `lib/domain/entities/location/area.dart` - Entity Khu
- `lib/domain/entities/customer/customer.dart` - Entity Khách hàng (đã cập nhật)

### Repository
- `lib/domain/repository/location/location_repository.dart` - Interface repository
- `lib/domain/repository/location/location_repository_impl.dart` - Implementation với mock data

### Presentation
- `lib/presentation/customer/add_customer_screen.dart` - Màn hình thêm khách hàng
- `lib/presentation/customer/customer_list_screen.dart` - Màn hình danh sách (đã cập nhật)

## Tính Năng

### 1. Form Validation
- Tên khách hàng: Bắt buộc nhập
- Phường xã: Bắt buộc chọn
- Tổ: Bắt buộc chọn
- Khu: Bắt buộc chọn
- Giá tiền: Bắt buộc nhập và phải > 0

### 2. Cascading Dropdowns
- Khi chọn phường xã → Tự động load danh sách tổ tương ứng
- Khi chọn tổ → Tự động load danh sách khu tương ứng

### 3. UI/UX
- Giao diện đẹp với gradient background
- Form fields có validation và error messages
- Loading states cho các dropdown
- Professional header với nút Save
- Responsive design

### 4. Data Flow
- Sử dụng BLoC pattern cho state management
- Mock data cho demo (có thể thay thế bằng API thực)
- Error handling và success messages

## Cách Sử Dụng

### 1. Truy cập màn hình thêm khách hàng
- Từ màn hình danh sách khách hàng, nhấn nút "+" ở header
- Hoặc navigate trực tiếp: `AddCustomerScreen()`

### 2. Điền thông tin
1. Nhập tên khách hàng
2. Nhập số điện thoại (tùy chọn)
3. Chọn phường xã từ dropdown
4. Nhập địa chỉ chi tiết (tùy chọn)
5. Chọn tổ (sẽ load dựa trên phường xã đã chọn)
6. Chọn khu (sẽ load dựa trên tổ đã chọn)
7. Chọn nhóm khách hàng (Thường/VIP/Cao cấp)
8. Nhập giá tiền dịch vụ

### 3. Lưu thông tin
- Nhấn nút Save (icon đĩa) ở header
- Nếu validation pass → Lưu thành công và quay về danh sách
- Nếu có lỗi → Hiển thị error message

## API Integration

### Endpoints (cần implement)
```dart
// Lấy danh sách phường xã
GET /MetaData/GetWards

// Lấy danh sách tổ theo phường xã
GET /MetaData/GetGroups?wardId={wardId}

// Lấy danh sách khu theo tổ
GET /MetaData/GetAreas?groupId={groupId}

// Thêm khách hàng mới
POST /customers
```

### Mock Data Structure
```dart
// Ward
{
  "id": 1,
  "code": "PX001",
  "name": "Phường 1",
  "description": "Phường 1 - Quận 1",
  "isActive": true
}

// Group
{
  "id": 1,
  "code": "TO001",
  "name": "Tổ 1",
  "description": "Tổ 1 - Phường 1",
  "wardId": 1,
  "isActive": true
}

// Area
{
  "id": 1,
  "code": "KH001",
  "name": "Khu A",
  "description": "Khu A - Tổ 1",
  "groupId": 1,
  "isActive": true
}
```

## Cập Nhật Customer Model

CustomerModel đã được mở rộng với các trường mới:

```dart
class CustomerModel {
  // Existing fields...
  final int? wardId;
  final String? wardName;
  final int? groupId;
  final String? groupName;
  final int? areaId;
  final String? areaName;
  final String? customerGroup; // 'regular', 'vip', 'premium'
  final double? price; // Giá tiền dịch vụ
}
```

## Hiển Thị Trong Danh Sách

Màn hình danh sách khách hàng đã được cập nhật để hiển thị:
- Thông tin vị trí (Phường - Tổ - Khu)
- Giá tiền dịch vụ
- Nhóm khách hàng với màu sắc phân biệt
- Ngày tạo

## Lưu Ý

1. **Demo Mode**: Hiện tại đang sử dụng mock data, cần thay thế bằng API calls thực
2. **Error Handling**: Đã implement basic error handling, có thể mở rộng thêm
3. **Validation**: Form validation đã được implement đầy đủ
4. **Performance**: Cascading dropdowns có loading states để tránh UI freeze
5. **Accessibility**: Cần thêm accessibility features cho production

## TODO

- [ ] Thay thế mock data bằng API calls thực
- [ ] Thêm unit tests
- [ ] Thêm integration tests
- [ ] Implement offline support
- [ ] Thêm image upload cho khách hàng
- [ ] Thêm search/filter theo vị trí
- [ ] Export data functionality 