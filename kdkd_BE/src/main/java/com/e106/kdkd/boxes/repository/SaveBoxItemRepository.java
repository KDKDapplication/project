package com.e106.kdkd.boxes.repository;

import com.e106.kdkd.global.common.entity.SaveBoxItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SaveBoxItemRepository extends JpaRepository<SaveBoxItem, Long> {

    List<SaveBoxItem> findAllByBox_BoxUuidOrderByBoxTransferDateDesc(String boxUuid);

    void deleteAllByBox_BoxUuid(String boxUuid);
}
