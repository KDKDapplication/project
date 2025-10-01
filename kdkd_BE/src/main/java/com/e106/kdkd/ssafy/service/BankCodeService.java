package com.e106.kdkd.ssafy.service;

import com.e106.kdkd.ssafy.dto.BankCodeItem;
import com.e106.kdkd.ssafy.dto.ResponseEnvelope;
import java.util.*;

public interface BankCodeService {
    ResponseEnvelope<List<BankCodeItem>> inquireBankCodes();
}
