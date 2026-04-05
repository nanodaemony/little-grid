// app/lib/tools/bookshelf/models/item.dart

class Item {
  final int id;
  final int categoryId;
  final String title;
  final String coverUrl;
  final String? summary;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? finishDate;
  final String? author;
  final int? rating;
  final String? review;
  final String? progress;
  final bool? isRecommended;
  final List<String>? tags;
  final DateTime? createTime;
  final DateTime? updateTime;

  Item({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.coverUrl,
    this.summary,
    this.startDate,
    this.endDate,
    this.finishDate,
    this.author,
    this.rating,
    this.review,
    this.progress,
    this.isRecommended,
    this.tags,
    this.createTime,
    this.updateTime,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String,
      summary: json['summary'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      finishDate: json['finishDate'] != null
          ? DateTime.parse(json['finishDate'])
          : null,
      author: json['author'] as String?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      progress: json['progress'] as String?,
      isRecommended: json['isRecommended'] as bool?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'categoryId': categoryId,
      'title': title,
      'coverUrl': coverUrl,
      if (summary != null) 'summary': summary,
      if (startDate != null) 'startDate': startDate!.toIso8601String().substring(0, 10),
      if (endDate != null) 'endDate': endDate!.toIso8601String().substring(0, 10),
      if (finishDate != null) 'finishDate': finishDate!.toIso8601String().substring(0, 10),
      if (author != null) 'author': author,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (progress != null) 'progress': progress,
      if (isRecommended != null) 'isRecommended': isRecommended,
      if (tags != null) 'tags': tags,
      if (createTime != null) 'createTime': createTime!.toIso8601String(),
      if (updateTime != null) 'updateTime': updateTime!.toIso8601String(),
    };
    return data;
  }

  Item copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? coverUrl,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? finishDate,
    String? author,
    int? rating,
    String? review,
    String? progress,
    bool? isRecommended,
    List<String>? tags,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Item(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      finishDate: finishDate ?? this.finishDate,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      progress: progress ?? this.progress,
      isRecommended: isRecommended ?? this.isRecommended,
      tags: tags ?? this.tags,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
