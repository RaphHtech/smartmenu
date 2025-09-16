class TableService {
  static String? _tableId;

  static void setTableId(String? tableId) {
    _tableId = tableId;
  }

  static String? getTableId() {
    return _tableId;
  }

  static void clearTableId() {
    _tableId = null;
  }
}
