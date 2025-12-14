import 'package:uuid/uuid.dart';

/// Model cho Task/Công việc trong ngày
/// Sử dụng để lưu trữ thông tin công việc cần làm
class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompleted;
  final TaskPriority priority;
  final String? category;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.date,
    DateTime? createdAt,
    this.updatedAt,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Tạo Task từ JSON (localstore hoặc Firestore)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      date: _parseDateTime(json['date']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseDateTime(json['updatedAt'])
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: json['category'] as String?,
    );
  }

  /// Helper method để parse DateTime từ String hoặc Firestore Timestamp
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    // Nếu là String (từ localstore)
    if (value is String) {
      return DateTime.parse(value);
    }
    
    // Nếu là Timestamp (từ Firestore)
    if (value.runtimeType.toString() == 'Timestamp') {
      return (value as dynamic).toDate();
    }
    
    // Nếu đã là DateTime
    if (value is DateTime) {
      return value;
    }
    
    return DateTime.now();
  }

  /// Chuyển Task thành JSON để lưu vào localstore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.name,
      'category': category,
    };
  }

  /// Copy Task với một số thuộc tính được thay đổi
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    TaskPriority? priority,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, date: $date, isCompleted: $isCompleted)';
  }
}

/// Độ ưu tiên của công việc
enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.high:
        return 'Cao';
      case TaskPriority.urgent:
        return 'Khẩn cấp';
    }
  }
}
