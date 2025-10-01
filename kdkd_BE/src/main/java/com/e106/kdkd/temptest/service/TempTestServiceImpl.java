package com.e106.kdkd.temptest.service;

import com.e106.kdkd.account.repository.AccountRepository;
import com.e106.kdkd.global.common.entity.Account;
import com.e106.kdkd.global.common.entity.User;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.temptest.dto.RequestTestAccountInfo;
import com.e106.kdkd.temptest.dto.RequestTestUserInfo;
import com.e106.kdkd.users.repository.UserRepository;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class TempTestServiceImpl implements TempTestService {

    private final UserRepository userRepository;
    private final AccountRepository accountRepository;

    @Transactional
    @Override
    public User createTempTestUser(RequestTestUserInfo requestTestUserInfo) {
        String uuid = UUID.randomUUID().toString();

        User user = User.builder()
            .userUuid(uuid)
            .name(requestTestUserInfo.getName())
            .email(requestTestUserInfo.getEmail())
            .birthdate(requestTestUserInfo.getBirthday())
            .role(requestTestUserInfo.getRole())
            .provider(requestTestUserInfo.getProvider())
            .providerId(requestTestUserInfo.getProviderId())
            .ssafyUserKey(requestTestUserInfo.getSsafyUserKey())
            .build();
        userRepository.save(user);

        return userRepository.findById(uuid).orElseThrow(
            () -> new UserNotFoundException("유저 생성에 실패하였습니다."));
    }

    @Transactional
    @Override
    public Account registerTempTestAccount(RequestTestAccountInfo requestTestAccountInfo) {
        User user = userRepository.findById(requestTestAccountInfo.getUserUuid()).orElseThrow(
            () -> new UserNotFoundException("해당 uuid의 유저는 없는 유저입니다."));

        Account account = Account.builder()
            .accountNumber(requestTestAccountInfo.getAccountNumber())
            .virtualCard(requestTestAccountInfo.getVirtualCard())
            .virtualCardCvc(requestTestAccountInfo.getVirtualCardCvc())
            .accountPassword(requestTestAccountInfo.getAccountPassord())
            .bankName(requestTestAccountInfo.getBankName())
            .user(user)
            .build();

        accountRepository.save(account);
        return account;
    }
}
