package com.e106.kdkd.invite.dto;

public record CreateInviteCodeRequest(String parentUuid, Long ttlSeconds) {

}
