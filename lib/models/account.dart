class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
  });

  final String name;
  final String email;
  final String phone;

  /// A media reference: `asset:people/x.png` for a bundled picture,
  /// `file:media/x.jpg` for one the person chose, or empty for none (the
  /// initial shows instead). Never image bytes.
  final String avatar;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  UserProfile copyWith(
          {String? name, String? email, String? phone, String? avatar}) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
      );

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String? ?? '',
        avatar: j['avatar'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'phone': phone, 'avatar': avatar};
}

class Address {
  const Address({required this.id, required this.label, required this.line});

  final String id;
  final String label;
  final String line;

  Address copyWith({String? label, String? line}) =>
      Address(id: id, label: label ?? this.label, line: line ?? this.line);

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'line': line};

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'] as String,
        label: j['label'] as String,
        line: j['line'] as String,
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.minutesAgo,
    required this.read,
  });

  final String id;
  final String title;
  final String body;
  final int minutesAgo;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        body: body,
        minutesAgo: minutesAgo,
        read: read ?? this.read,
      );

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        minutesAgo: j['minutesAgo'] as int,
        read: j['read'] as bool? ?? false,
      );
}

/// "12 min ago", "5 h ago", "Yesterday", "6 days ago".
String agoLabel(int minutes) {
  if (minutes < 60) return '$minutes min ago';
  if (minutes < 60 * 24) return '${minutes ~/ 60} h ago';
  return daysAgoLabel(minutes ~/ (60 * 24));
}

String daysAgoLabel(int days) => switch (days) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => '$days days ago',
    };

/// "2:05 PM".
String clockLabel(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// "Today, 2:05 PM", "Yesterday, 9:40 AM", "3 days ago".
String whenLabel(DateTime t, DateTime now) {
  final days = DateTime(now.year, now.month, now.day)
      .difference(DateTime(t.year, t.month, t.day))
      .inDays;
  return switch (days) {
    0 => 'Today, ${clockLabel(t)}',
    1 => 'Yesterday, ${clockLabel(t)}',
    _ => '$days days ago',
  };
}
