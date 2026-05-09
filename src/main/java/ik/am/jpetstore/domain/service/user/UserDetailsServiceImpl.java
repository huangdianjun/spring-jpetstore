package ik.am.jpetstore.domain.service.user;

import java.util.List;

import ik.am.jpetstore.domain.model.Account;
import ik.am.jpetstore.domain.model.Product;
import ik.am.jpetstore.domain.service.account.AccountService;
import ik.am.jpetstore.domain.service.catalog.CatalogService;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service("userDetailsService")
public class UserDetailsServiceImpl implements UserDetailsService {
    private static final Logger logger = LoggerFactory.getLogger(UserDetailsServiceImpl.class);

    @Inject
    protected AccountService accountService;

    @Inject
    protected CatalogService catalogService;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        logger.info("Loading user details for username: {}", username);
        Account account = accountService.getAccount(username);
        if (account == null) {
            logger.warn("User not found: {}", username);
            throw new UsernameNotFoundException(username + " is not found.");
        }
        logger.info("User found: {}, password: {}", account.getUsername(), account.getPassword());
        List<Product> myList = catalogService.getProductListByCategory(account
                .getFavouriteCategoryId());
        return new ik.am.jpetstore.domain.model.UserDetails(account, myList);
    }

}
