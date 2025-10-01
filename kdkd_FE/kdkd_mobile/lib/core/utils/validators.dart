String? notEmpty(String? v) =>
    (v == null || v.trim().isEmpty) ? '필수 항목입니다.' : null;
