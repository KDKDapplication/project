package com.e106.kdkd.boxes.dto.response;

import com.e106.kdkd.global.common.entity.SaveBoxItem;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SaveBoxItemInfo {

    String boxPayName;
    LocalDateTime boxTransferDate;
    Long boxAmount;

    public SaveBoxItemInfo(SaveBoxItem item) {
        this.boxPayName = item.getBoxPayName();
        this.boxTransferDate = item.getBoxTransferDate();
        this.boxAmount = item.getBoxAmount();
    }
}
