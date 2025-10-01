package com.e106.kdkd.s3.exception;

public class FileUploadFailureException extends RuntimeException{
    public FileUploadFailureException(String msg) {
        super(msg);
    }
}
