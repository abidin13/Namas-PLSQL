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
 -----------------------------------------------------------------------------------------------------------
 SELECT   USR.USER_NAME, (SELECT DISPLAY_NAME
                           FROM WF_USERS
                          WHERE NAME = USR.USER_NAME) DISPLAY_NAME,
         CASE
            WHEN USR.END_DATE IS NULL
               THEN 'AKTIF'
            ELSE 'TIDAK AKTIF'
         END AS STATUS_USER
    FROM FND_USER USR
   WHERE USR.END_DATE IS NULL AND SUBSTR (USR.USER_NAME, 1, 3) = 'MDN'
ORDER BY USR.USER_NAME