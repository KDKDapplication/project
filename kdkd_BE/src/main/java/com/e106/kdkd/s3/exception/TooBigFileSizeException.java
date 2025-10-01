package com.e106.kdkd.s3.exception;

public class TooBigFileSizeException extends RuntimeException{
    public TooBigFileSizeException(String msg) {
        super(msg);
    }
}

