/// 法定节假日表（一个自然年）。
///
/// - [holidays]：放假休息日（yyyy-MM-dd）。
/// - [makeupWorkdays]：调休补班日（周末上班，yyyy-MM-dd）。
class HolidayTable {
  const HolidayTable({
    required this.year,
    this.holidays = const {},
    this.makeupWorkdays = const {},
  });

  final int year;
  final Set<String> holidays;
  final Set<String> makeupWorkdays;

  bool isHoliday(String dateKey) => holidays.contains(dateKey);
  bool isMakeupWorkday(String dateKey) => makeupWorkdays.contains(dateKey);

  factory HolidayTable.fromJson(Map<String, dynamic> json) {
    return HolidayTable(
      year: json['year'] as int,
      holidays: (json['holidays'] as List? ?? const [])
          .map((e) => e as String)
          .toSet(),
      makeupWorkdays: (json['makeupWorkdays'] as List? ?? const [])
          .map((e) => e as String)
          .toSet(),
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'holidays': holidays.toList()..sort(),
        'makeupWorkdays': makeupWorkdays.toList()..sort(),
      };
}
