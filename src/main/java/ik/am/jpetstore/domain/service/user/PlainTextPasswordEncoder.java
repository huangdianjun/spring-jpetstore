package ik.am.jpetstore.domain.service.user;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;

public class PlainTextPasswordEncoder implements PasswordEncoder {
    private static final Logger logger = LoggerFactory.getLogger(PlainTextPasswordEncoder.class);

    @Override
    public String encode(CharSequence rawPassword) {
        logger.info("Encoding password: {}", rawPassword);
        return rawPassword.toString();
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        logger.info("Matching password - raw: {}, encoded: {}", rawPassword, encodedPassword);
        boolean result = rawPassword.toString().equals(encodedPassword);
        logger.info("Password match result: {}", result);
        return result;
    }

    @Override
    public boolean upgradeEncoding(String encodedPassword) {
        return false;
    }
}
