class aProduct {
  String name;
  bool isChecked;
  bool isConfigured;
  bool selected; // Yeni özellik

  aProduct({
    required this.name,
    this.isChecked = false,
    this.isConfigured = false,
    this.selected = false, // Varsayılan olarak false
  });
}
