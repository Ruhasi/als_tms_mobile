class LookupItem {
  const LookupItem({required this.seq, required this.name, required this.code});

  final int seq;
  final String name;
  final String code;

  factory LookupItem.fromJson(Map<String, dynamic> json) => LookupItem(
    seq: json['seq'] as int,
    name: json['name'] as String,
    code: json['code'] as String? ?? '',
  );
}
