package com.e106.kdkd.global.handler;

import com.e106.kdkd.global.exception.EntityAlreadyExistsException;
import com.e106.kdkd.global.exception.InsufficientFundsException;
import com.e106.kdkd.global.exception.PermissionDeniedException;
import com.e106.kdkd.global.exception.ResourceNotFoundException;
import com.e106.kdkd.global.exception.UserNotFoundException;
import com.e106.kdkd.parents.exception.RelationNotFoundException;
import com.e106.kdkd.s3.exception.FileUploadFailureException;
import com.e106.kdkd.s3.exception.IllegalFileTypeException;
import com.e106.kdkd.s3.exception.StorageWriteException;
import com.e106.kdkd.s3.exception.TooBigFileSizeException;
import com.google.firebase.messaging.FirebaseMessagingException;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.persistence.NonUniqueResultException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Hidden
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<?> illegalArgumentExceptionHandler(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(FileUploadFailureException.class)
    public ResponseEntity<?> fileUploadFailureExceptionHandler(FileUploadFailureException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(IllegalFileTypeException.class)
    public ResponseEntity<?> illegalFileTypeExceptionHandler(IllegalFileTypeException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(StorageWriteException.class)
    public ResponseEntity<?> storageWriteExceptionHandler(StorageWriteException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(TooBigFileSizeException.class)
    public ResponseEntity<?> tooBigFileSizeExceptionHandler(TooBigFileSizeException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(RelationNotFoundException.class)
    public ResponseEntity<?> relationNotFoundExceptionHandler(
        RelationNotFoundException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ResponseEntity<?> userNotFoundExceptionHandler(UserNotFoundException e) {
        return ResponseEntity.status(404).body(e.getMessage());
    }

    @ExceptionHandler(EntityAlreadyExistsException.class)
    public ResponseEntity<?> entityAlreadyExistsExceptionHandler(EntityAlreadyExistsException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
    }

    @ExceptionHandler(NonUniqueResultException.class)
    public ResponseEntity<?> nonUniqueResultExceptionHandler(NonUniqueResultException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT) // 409 충돌 (데이터 무결성 위반)
            .body(e.getMessage());
    }

    @ExceptionHandler(FirebaseMessagingException.class)
    public ResponseEntity<?> firebaseMessagingExceptionHandler(FirebaseMessagingException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(e.getMessage());
    }

    @ExceptionHandler(PermissionDeniedException.class)
    public ResponseEntity<?> permissionDeniedExceptionHandler(PermissionDeniedException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<?> resourceNotFoundExceptionHandler(ResourceNotFoundException e) {
        return ResponseEntity.status(404).body(e.getMessage());
    }

    @ExceptionHandler(InsufficientFundsException.class)
    public ResponseEntity<?> insufficientFundsExceptionHandler(InsufficientFundsException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT) // 409 충돌(잔액 부족)
            .body(e.getMessage());
    }

}
