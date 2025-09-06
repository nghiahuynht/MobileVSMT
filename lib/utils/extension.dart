import 'package:intl/intl.dart';

extension StringUrl on String {
  String urlTrim() {
    String text = trim().toLowerCase();
    for (final e in ['https://www.', 'http://www.', 'https://', 'http://']) {
      if (text.indexOf(e) == 0) {
        text = text.substring(e.length);
      }
    }
    if (text.isNotEmpty && text[text.length - 1] == '/') {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  String get removeDiacritics {
    const vietnamese = 'àáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐÀÁẢÃẠÂẦẤẨẪẬĂẰẮẲẴẶÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ';
    const english = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydDAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY';
    
    String result = this;
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }
}

extension DateTimeExtension on DateTime {
  String getDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String toDDMMYYY() {
    return DateFormat('dd/MM/yyyy').format(this);
  }
}
