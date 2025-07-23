class Criteria {
  final String? id;
  final String label;
  final int maxScore;
  final int weight;
  final String? commentGlobal;
  final String? commentPerCriteria;

  Criteria({
    this.id,
    required this.label,
    required this.maxScore,
    required this.weight,
    this.commentGlobal,
    this.commentPerCriteria,
  });

  factory Criteria.fromJson(Map<String, dynamic> json) => Criteria(
        id: json['id']?.toString(),
        label: json['label'] ?? '',
        maxScore: (json['maxScore'] is int)
            ? json['maxScore']
            : (json['maxScore'] as num?)?.toInt() ?? 10,
        weight: (json['weight'] is int)
            ? json['weight']
            : (json['weight'] as num?)?.toInt() ?? 1,
        commentGlobal: json['commentGlobal'],
        commentPerCriteria: json['commentPerCriteria'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'label': label,
        'maxScore': maxScore,
        'weight': weight,
        if (commentGlobal != null) 'commentGlobal': commentGlobal,
        if (commentPerCriteria != null) 'commentPerCriteria': commentPerCriteria,
      };
}

class CriteriaSet {
  final String? id;
  final String title;
  final String type; // 'defense', 'deliverable', 'report'
  final int weight;
  final List<Criteria> criteria;
  final String? groupId;
  final String? commentPerCriteria;
  final String? commentGlobal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CriteriaSet({
    this.id,
    required this.title,
    required this.type,
    required this.weight,
    required this.criteria,
    this.groupId,
    this.commentPerCriteria,
    this.commentGlobal,
    this.createdAt,
    this.updatedAt,
  });

  factory CriteriaSet.fromJson(Map<String, dynamic> json) => CriteriaSet(
        id: json['id']?.toString(),
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        weight: json['weight'] ?? 1,
        criteria: (json['criteria'] as List<dynamic>? ?? [])
            .map((e) => Criteria.fromJson(e as Map<String, dynamic>))
            .toList(),
        groupId: json['groupId']?.toString(),
        commentPerCriteria: json['commentPerCriteria'],
        commentGlobal: json['commentGlobal'],
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      );
}
