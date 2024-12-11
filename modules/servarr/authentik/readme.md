# Useful stuff

## Links

<https://authentikswag.blogspot.com>

<https://safereddit.com/r/selfhosted/comments/15wfmaz/jellyfin_authentik_duo_2fa_solution_tutorial/>
<https://libreddit.bus-hit.me/r/selfhosted/comments/1gv38g7/working_authentication_ldap_for_calibreweb_and/?tl=es-es>
<https://snoo.habedieeh.re/r/Authentik/comments/1f6xnad/problems_with_using_authentik_to_secure_a/ll52or4/?context=3#ll52or4>

# Test command for LDAP

```bash
ldapsearch \         
  -x \
  -H ldap://localhost:389 \
  -D 'cn=ldapservice,ou=users,ou=jellyfin,dc=auth,dc=mediabyte,dc=win' \
  -w '9sn0DWoPjaglABaeImgZDhrIn8h3f8Aem2dLMz6RCTvykUslE4z6I2qPJxMP' \
  -b 'ou=jellyfin,dc=auth,dc=mediabyte,dc=win' \
'(&(objectClass=user)(memberOf=cn=Media,ou=groups,ou=jellyfin,dc=auth,dc=mediabyte,dc=win))'
```
