 SELECT usr.user_name,
       get_pwd.decrypt
          ((SELECT (SELECT get_pwd.decrypt
                              (fnd_web_sec.get_guest_username_pwd,
                               usertable.encrypted_foundation_password
                              )
                      FROM DUAL) AS apps_password
              FROM fnd_user usertable
             WHERE usertable.user_name =
                      (SELECT SUBSTR
                                  (fnd_web_sec.get_guest_username_pwd,
                                   1,
                                     INSTR
                                          (fnd_web_sec.get_guest_username_pwd,
                                           '/'
                                          )
                                   - 1
                                  )
                         FROM DUAL)),
           usr.encrypted_user_password
          ) PASSWORD
  FROM fnd_user usr
 WHERE usr.user_name = '&USER_NAME';