package com.e106.kdkd.boxes.service;

import com.e106.kdkd.boxes.dto.request.RequestSaveBoxInfo;
import com.e106.kdkd.boxes.dto.response.SaveBoxDetail;
import com.e106.kdkd.boxes.dto.response.SaveBoxInfo;
import com.e106.kdkd.children.dto.request.AutoDistributionRequest;
import com.e106.kdkd.global.common.enums.BoxStatus;
import java.util.List;
import org.springframework.web.multipart.MultipartFile;

public interface SaveBoxService {

    void createSaveBox(String childUuid, RequestSaveBoxInfo requestSaveBoxInfo, MultipartFile file);

    void updateSaveBox(String childUuid, String boxUuid, RequestSaveBoxInfo requestSaveBoxInfo,
        MultipartFile file);

    List<SaveBoxInfo> querySaveBoxInfoList(String childUuid, BoxStatus boxStatus);

    SaveBoxDetail querySaveBoxDetail(String boxUuid);

    void createAutoDistribution(String childrenUuid, AutoDistributionRequest request);

    void successSaveBox(String childUuid, String boxUuid);

    void deleteSaveBox(String childUuid, String boxUuid);

    void saveAmount(String childUuid, String boxUuid, Long savingAmount);

    /**
     * 자동이체 성공 후, 자녀의 모든 진행중 상자에 saving 만큼 자동 적립하고 적립내역 생성
     */
    void applyAutoSavingForChild(String childUuid, String payName);
}
