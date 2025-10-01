class CreateCollectionRequest {
  final String boxName;
  final int saving;
  final int target;

  const CreateCollectionRequest({
    required this.boxName,
    required this.saving,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
        'boxName': boxName,
        'saving': saving,
        'target': target,
      };
}