package com.e106.kdkd.global.exception;

public class UserNotFoundException extends RuntimeException {

    public UserNotFoundException(String uuid) {
        super("사용자를 찾을 수 없습니다. uuid=" + uuid);
    }

}
