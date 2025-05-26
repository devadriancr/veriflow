class RecordModel {
  int? id;
  final String containerCode;
  final String visualAidCode;
  final String finalLabelCode;
  final String creationDate;
  final bool status;
  bool isSynced;
  int? recordId;

  RecordModel({
    this.id,
    required this.containerCode,
    required this.visualAidCode,
    required this.finalLabelCode,
    required this.creationDate,
    required this.status,
    this.isSynced = false,
    this.recordId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'container_code': containerCode,
      'visual_aid_code': visualAidCode,
      'final_label_code': finalLabelCode,
      'creation_date': creationDate,
      'status': status ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'record_id': recordId,
    };
  }

  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'],
      containerCode: map['container_code'],
      visualAidCode: map['visual_aid_code'],
      finalLabelCode: map['final_label_code'],
      creationDate: map['creation_date'],
      status: map['status'] == 1,
      isSynced: map['is_synced'] == 1,
      recordId: map['record_id'],
    );
  }
}
