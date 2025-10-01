package com.e106.kdkd.boxes.dto.response;

import com.e106.kdkd.global.common.entity.SaveBox;
import com.e106.kdkd.global.common.enums.BoxStatus;
import java.time.LocalDateTime;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SaveBoxDetail {

    String boxUuid;
    String boxName;
    Long remain;
    Long target;
    LocalDateTime createdAt;
    BoxStatus status;
    String imageUrl;
    List<SaveBoxItemInfo> saveBoxItemInfoList;

    public SaveBoxDetail(SaveBox saveBox) {
        this.boxUuid = saveBox.getBoxUuid();
        this.boxName = saveBox.getBoxName();
        ;
        this.remain = saveBox.getRemain();
        this.target = saveBox.getTarget();
        ;
        this.createdAt = saveBox.getCreatedAt();
        this.status = saveBox.getStatus();
    }

}
