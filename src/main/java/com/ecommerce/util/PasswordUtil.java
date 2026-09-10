package com.ecommerce.util;

import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16;

    private static final String ALGORITHM =
            "PBKDF2WithHmacSHA256";


    public static String hashPassword(String password) {

        try {

            SecureRandom random = new SecureRandom();

            byte[] salt = new byte[SALT_LENGTH];

            random.nextBytes(salt);

            PBEKeySpec spec = new PBEKeySpec(
                    password.toCharArray(),
                    salt,
                    ITERATIONS,
                    KEY_LENGTH
            );

            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance(ALGORITHM);

            byte[] hash = factory
                    .generateSecret(spec)
                    .getEncoded();

            return ITERATIONS
                    + ":"
                    + Base64.getEncoder().encodeToString(salt)
                    + ":"
                    + Base64.getEncoder().encodeToString(hash);

        } catch (Exception e) {

            throw new RuntimeException(
                    "Password hashing failed",
                    e
            );
        }
    }


    public static boolean verifyPassword(
            String password,
            String storedPassword) {

        try {

            String[] parts =
                    storedPassword.split(":");

            int iterations =
                    Integer.parseInt(parts[0]);

            byte[] salt =
                    Base64.getDecoder()
                            .decode(parts[1]);

            byte[] storedHash =
                    Base64.getDecoder()
                            .decode(parts[2]);

            PBEKeySpec spec =
                    new PBEKeySpec(
                            password.toCharArray(),
                            salt,
                            iterations,
                            KEY_LENGTH
                    );

            SecretKeyFactory factory =
                    SecretKeyFactory.getInstance(ALGORITHM);

            byte[] testHash =
                    factory
                            .generateSecret(spec)
                            .getEncoded();

            return java.security.MessageDigest
                    .isEqual(
                            storedHash,
                            testHash
                    );

        } catch (Exception e) {

            return false;
        }
    }
}