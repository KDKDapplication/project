package com.e106.kdkd.character.repository;

import com.e106.kdkd.global.common.entity.UserCharacter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserCharacterRepository extends JpaRepository<UserCharacter, String> {

    UserCharacter findUserCharacterByUser_UserUuid(String userUuid);
}
