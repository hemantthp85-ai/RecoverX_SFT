// ============================================================
// RecoverX — PhysiologicalMetric model
// Matches: #/components/schemas/PhysiologicalMetric
// ============================================================

class PhysiologicalMetric {
  const PhysiologicalMetric({
    this.value,
    this.unit,
    this.status,
    this.interpretation,
  });

  final double? value;
  final String? unit;
  final String? status;
  final String? interpretation;

  factory PhysiologicalMetric.fromJson(Map<String, dynamic> json) {
    return PhysiologicalMetric(
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      status: json['status'] as String?,
      interpretation: json['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'unit': unit,
        'status': status,
        'interpretation': interpretation,
      };

  @override
  String toString() =>
      'PhysiologicalMetric(value: $value, unit: $unit, status: $status)';
}
