# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

var_password_pam_remember='24'
var_password_pam_remember_control_flag='requisite,required'


var_password_pam_remember_control_flag="$(echo $var_password_pam_remember_control_flag | cut -d \, -f 1)"

if [ -f /usr/bin/authselect ]; then
    if authselect list-features sssd | grep -q with-pwhistory; then
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi
        authselect enable-feature with-pwhistory

        authselect apply-changes -b
    else
        
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi

        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            
            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
            
            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/password-auth")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
        if ! grep -qP "^\s*password\s+$var_password_pam_remember_control_flag\s+pam_pwhistory.so\s*.*" "$PAM_FILE_PATH"; then
            # Line matching group + control + module was not found. Check group + module.
            if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "$PAM_FILE_PATH")" -eq 1 ]; then
                # The control is updated only if one single line matches.
                sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1$var_password_pam_remember_control_flag \2/" "$PAM_FILE_PATH"
            else
                LAST_MATCH_LINE=$(grep -nP "^password.*requisite.*pam_pwquality\.so" "$PAM_FILE_PATH" | tail -n 1 | cut -d: -f 1)
                if [ ! -z $LAST_MATCH_LINE ]; then
                    sed -i --follow-symlinks $LAST_MATCH_LINE" a password     $var_password_pam_remember_control_flag    pam_pwhistory.so" "$PAM_FILE_PATH"
                else
                    echo "password    $var_password_pam_remember_control_flag    pam_pwhistory.so" >> "$PAM_FILE_PATH"
                fi
            fi
        fi
    fi
else
    if ! grep -qP "^\s*password\s+$var_password_pam_remember_control_flag\s+pam_pwhistory.so\s*.*" "/etc/pam.d/password-auth"; then
        # Line matching group + control + module was not found. Check group + module.
        if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "/etc/pam.d/password-auth")" -eq 1 ]; then
            # The control is updated only if one single line matches.
            sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1$var_password_pam_remember_control_flag \2/" "/etc/pam.d/password-auth"
        else
            LAST_MATCH_LINE=$(grep -nP "^password.*requisite.*pam_pwquality\.so" "/etc/pam.d/password-auth" | tail -n 1 | cut -d: -f 1)
            if [ ! -z $LAST_MATCH_LINE ]; then
                sed -i --follow-symlinks $LAST_MATCH_LINE" a password     $var_password_pam_remember_control_flag    pam_pwhistory.so" "/etc/pam.d/password-auth"
            else
                echo "password    $var_password_pam_remember_control_flag    pam_pwhistory.so" >> "/etc/pam.d/password-auth"
            fi
        fi
    fi
fi

PWHISTORY_CONF="/etc/security/pwhistory.conf"
if [ -f $PWHISTORY_CONF ]; then
    regex="^\s*remember\s*="
    line="remember = $var_password_pam_remember"
    if ! grep -q $regex $PWHISTORY_CONF; then
        echo $line >> $PWHISTORY_CONF
    else
        sed -i --follow-symlinks 's|^\s*\(remember\s*=\s*\)\(\S\+\)|\1'"$var_password_pam_remember"'|g' $PWHISTORY_CONF
    fi
    if [ -e "/etc/pam.d/password-auth" ] ; then
        PAM_FILE_PATH="/etc/pam.d/password-auth"
        if [ -f /usr/bin/authselect ]; then
            
            if ! authselect check; then
            echo "
            authselect integrity check failed. Remediation aborted!
            This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
            It is not recommended to manually edit the PAM files when authselect tool is available.
            In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
            exit 1
            fi

            CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
            # If not already in use, a custom profile is created preserving the enabled features.
            if [[ ! $CURRENT_PROFILE == custom/* ]]; then
                ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
                authselect create-profile hardening -b $CURRENT_PROFILE
                CURRENT_PROFILE="custom/hardening"
                
                authselect apply-changes -b --backup=before-hardening-custom-profile
                authselect select $CURRENT_PROFILE
                for feature in $ENABLED_FEATURES; do
                    authselect enable-feature $feature;
                done
                
                authselect apply-changes -b --backup=after-hardening-custom-profile
            fi
            PAM_FILE_NAME=$(basename "/etc/pam.d/password-auth")
            PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

            authselect apply-changes -b
        fi
        
    if grep -qP "^\s*password\s.*\bpam_pwhistory.so\s.*\bremember\b" "$PAM_FILE_PATH"; then
        sed -i -E --follow-symlinks "s/(.*password.*pam_pwhistory.so.*)\bremember\b=?[[:alnum:]]*(.*)/\1\2/g" "$PAM_FILE_PATH"
    fi
        if [ -f /usr/bin/authselect ]; then
            
            authselect apply-changes -b
        fi
    else
        echo "/etc/pam.d/password-auth was not found" >&2
    fi
else
    PAM_FILE_PATH="/etc/pam.d/password-auth"
    if [ -f /usr/bin/authselect ]; then
        
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi

        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            
            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
            
            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/password-auth")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
    fi
    if ! grep -qP "^\s*password\s+requisite\s+pam_pwhistory.so\s*.*" "$PAM_FILE_PATH"; then
        # Line matching group + control + module was not found. Check group + module.
        if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "$PAM_FILE_PATH")" -eq 1 ]; then
            # The control is updated only if one single line matches.
            sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1requisite \2/" "$PAM_FILE_PATH"
        else
            echo "password    requisite    pam_pwhistory.so" >> "$PAM_FILE_PATH"
        fi
    fi
    # Check the option
    if ! grep -qP "^\s*password\s+requisite\s+pam_pwhistory.so\s*.*\sremember\b" "$PAM_FILE_PATH"; then
        sed -i -E --follow-symlinks "/\s*password\s+requisite\s+pam_pwhistory.so.*/ s/$/ remember=$var_password_pam_remember/" "$PAM_FILE_PATH"
    else
        sed -i -E --follow-symlinks "s/(\s*password\s+requisite\s+pam_pwhistory.so\s+.*)(remember=)[[:alnum:]]+\s*(.*)/\1\2$var_password_pam_remember \3/" "$PAM_FILE_PATH"
    fi
    if [ -f /usr/bin/authselect ]; then
        
        authselect apply-changes -b
    fi
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

var_password_pam_remember='24'
var_password_pam_remember_control_flag='requisite,required'


var_password_pam_remember_control_flag="$(echo $var_password_pam_remember_control_flag | cut -d \, -f 1)"

if [ -f /usr/bin/authselect ]; then
    if authselect list-features sssd | grep -q with-pwhistory; then
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi
        authselect enable-feature with-pwhistory

        authselect apply-changes -b
    else
        
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi

        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            
            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
            
            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/system-auth")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
        if ! grep -qP "^\s*password\s+$var_password_pam_remember_control_flag\s+pam_pwhistory.so\s*.*" "$PAM_FILE_PATH"; then
            # Line matching group + control + module was not found. Check group + module.
            if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "$PAM_FILE_PATH")" -eq 1 ]; then
                # The control is updated only if one single line matches.
                sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1$var_password_pam_remember_control_flag \2/" "$PAM_FILE_PATH"
            else
                LAST_MATCH_LINE=$(grep -nP "^password.*requisite.*pam_pwquality\.so" "$PAM_FILE_PATH" | tail -n 1 | cut -d: -f 1)
                if [ ! -z $LAST_MATCH_LINE ]; then
                    sed -i --follow-symlinks $LAST_MATCH_LINE" a password     $var_password_pam_remember_control_flag    pam_pwhistory.so" "$PAM_FILE_PATH"
                else
                    echo "password    $var_password_pam_remember_control_flag    pam_pwhistory.so" >> "$PAM_FILE_PATH"
                fi
            fi
        fi
    fi
else
    if ! grep -qP "^\s*password\s+$var_password_pam_remember_control_flag\s+pam_pwhistory.so\s*.*" "/etc/pam.d/system-auth"; then
        # Line matching group + control + module was not found. Check group + module.
        if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "/etc/pam.d/system-auth")" -eq 1 ]; then
            # The control is updated only if one single line matches.
            sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1$var_password_pam_remember_control_flag \2/" "/etc/pam.d/system-auth"
        else
            LAST_MATCH_LINE=$(grep -nP "^password.*requisite.*pam_pwquality\.so" "/etc/pam.d/system-auth" | tail -n 1 | cut -d: -f 1)
            if [ ! -z $LAST_MATCH_LINE ]; then
                sed -i --follow-symlinks $LAST_MATCH_LINE" a password     $var_password_pam_remember_control_flag    pam_pwhistory.so" "/etc/pam.d/system-auth"
            else
                echo "password    $var_password_pam_remember_control_flag    pam_pwhistory.so" >> "/etc/pam.d/system-auth"
            fi
        fi
    fi
fi

PWHISTORY_CONF="/etc/security/pwhistory.conf"
if [ -f $PWHISTORY_CONF ]; then
    regex="^\s*remember\s*="
    line="remember = $var_password_pam_remember"
    if ! grep -q $regex $PWHISTORY_CONF; then
        echo $line >> $PWHISTORY_CONF
    else
        sed -i --follow-symlinks 's|^\s*\(remember\s*=\s*\)\(\S\+\)|\1'"$var_password_pam_remember"'|g' $PWHISTORY_CONF
    fi
    if [ -e "/etc/pam.d/system-auth" ] ; then
        PAM_FILE_PATH="/etc/pam.d/system-auth"
        if [ -f /usr/bin/authselect ]; then
            
            if ! authselect check; then
            echo "
            authselect integrity check failed. Remediation aborted!
            This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
            It is not recommended to manually edit the PAM files when authselect tool is available.
            In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
            exit 1
            fi

            CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
            # If not already in use, a custom profile is created preserving the enabled features.
            if [[ ! $CURRENT_PROFILE == custom/* ]]; then
                ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
                authselect create-profile hardening -b $CURRENT_PROFILE
                CURRENT_PROFILE="custom/hardening"
                
                authselect apply-changes -b --backup=before-hardening-custom-profile
                authselect select $CURRENT_PROFILE
                for feature in $ENABLED_FEATURES; do
                    authselect enable-feature $feature;
                done
                
                authselect apply-changes -b --backup=after-hardening-custom-profile
            fi
            PAM_FILE_NAME=$(basename "/etc/pam.d/system-auth")
            PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

            authselect apply-changes -b
        fi
        
    if grep -qP "^\s*password\s.*\bpam_pwhistory.so\s.*\bremember\b" "$PAM_FILE_PATH"; then
        sed -i -E --follow-symlinks "s/(.*password.*pam_pwhistory.so.*)\bremember\b=?[[:alnum:]]*(.*)/\1\2/g" "$PAM_FILE_PATH"
    fi
        if [ -f /usr/bin/authselect ]; then
            
            authselect apply-changes -b
        fi
    else
        echo "/etc/pam.d/system-auth was not found" >&2
    fi
else
    PAM_FILE_PATH="/etc/pam.d/system-auth"
    if [ -f /usr/bin/authselect ]; then
        
        if ! authselect check; then
        echo "
        authselect integrity check failed. Remediation aborted!
        This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
        It is not recommended to manually edit the PAM files when authselect tool is available.
        In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        exit 1
        fi

        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            
            authselect apply-changes -b --backup=before-hardening-custom-profile
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
            
            authselect apply-changes -b --backup=after-hardening-custom-profile
        fi
        PAM_FILE_NAME=$(basename "/etc/pam.d/system-auth")
        PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

        authselect apply-changes -b
    fi
    if ! grep -qP "^\s*password\s+requisite\s+pam_pwhistory.so\s*.*" "$PAM_FILE_PATH"; then
        # Line matching group + control + module was not found. Check group + module.
        if [ "$(grep -cP '^\s*password\s+.*\s+pam_pwhistory.so\s*' "$PAM_FILE_PATH")" -eq 1 ]; then
            # The control is updated only if one single line matches.
            sed -i -E --follow-symlinks "s/^(\s*password\s+).*(\bpam_pwhistory.so.*)/\1requisite \2/" "$PAM_FILE_PATH"
        else
            echo "password    requisite    pam_pwhistory.so" >> "$PAM_FILE_PATH"
        fi
    fi
    # Check the option
    if ! grep -qP "^\s*password\s+requisite\s+pam_pwhistory.so\s*.*\sremember\b" "$PAM_FILE_PATH"; then
        sed -i -E --follow-symlinks "/\s*password\s+requisite\s+pam_pwhistory.so.*/ s/$/ remember=$var_password_pam_remember/" "$PAM_FILE_PATH"
    else
        sed -i -E --follow-symlinks "s/(\s*password\s+requisite\s+pam_pwhistory.so\s+.*)(remember=)[[:alnum:]]+\s*(.*)/\1\2$var_password_pam_remember \3/" "$PAM_FILE_PATH"
    fi
    if [ -f /usr/bin/authselect ]; then
        
        authselect apply-changes -b
    fi
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

var_accounts_passwords_pam_faillock_deny='5'


if [ -f /usr/bin/authselect ]; then
    if ! authselect check; then
echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
It is not recommended to manually edit the PAM files when authselect tool is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
exit 1
fi
authselect enable-feature with-faillock

authselect apply-changes -b
else
    
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for pam_file in "${AUTH_FILES[@]}"
do
    if ! grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+(preauth silent|authfail).*$' "$pam_file" ; then
        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix\.so.*/i auth        required      pam_faillock.so preauth silent' "$pam_file"
        sed -i --follow-symlinks '/^auth.*required.*pam_deny\.so.*/i auth        required      pam_faillock.so authfail' "$pam_file"
        sed -i --follow-symlinks '/^account.*required.*pam_unix\.so.*/i account     required      pam_faillock.so' "$pam_file"
    fi
    sed -Ei 's/(auth.*)(\[default=die\])(.*pam_faillock\.so)/\1required     \3/g' "$pam_file"
done

fi

AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    regex="^\s*deny\s*="
    line="deny = $var_accounts_passwords_pam_faillock_deny"
    if ! grep -q $regex $FAILLOCK_CONF; then
        echo $line >> $FAILLOCK_CONF
    else
        sed -i --follow-symlinks 's|^\s*\(deny\s*=\s*\)\(\S\+\)|\1'"$var_accounts_passwords_pam_faillock_deny"'|g' $FAILLOCK_CONF
    fi
    for pam_file in "${AUTH_FILES[@]}"
    do
        if [ -e "$pam_file" ] ; then
            PAM_FILE_PATH="$pam_file"
            if [ -f /usr/bin/authselect ]; then
                
                if ! authselect check; then
                echo "
                authselect integrity check failed. Remediation aborted!
                This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
                It is not recommended to manually edit the PAM files when authselect tool is available.
                In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
                exit 1
                fi

                CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
                # If not already in use, a custom profile is created preserving the enabled features.
                if [[ ! $CURRENT_PROFILE == custom/* ]]; then
                    ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
                    authselect create-profile hardening -b $CURRENT_PROFILE
                    CURRENT_PROFILE="custom/hardening"
                    
                    authselect apply-changes -b --backup=before-hardening-custom-profile
                    authselect select $CURRENT_PROFILE
                    for feature in $ENABLED_FEATURES; do
                        authselect enable-feature $feature;
                    done
                    
                    authselect apply-changes -b --backup=after-hardening-custom-profile
                fi
                PAM_FILE_NAME=$(basename "$pam_file")
                PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

                authselect apply-changes -b
            fi
            
        if grep -qP "^\s*auth\s.*\bpam_faillock.so\s.*\bdeny\b" "$PAM_FILE_PATH"; then
            sed -i -E --follow-symlinks "s/(.*auth.*pam_faillock.so.*)\bdeny\b=?[[:alnum:]]*(.*)/\1\2/g" "$PAM_FILE_PATH"
        fi
            if [ -f /usr/bin/authselect ]; then
                
                authselect apply-changes -b
            fi
        else
            echo "$pam_file was not found" >&2
        fi
    done
else
    for pam_file in "${AUTH_FILES[@]}"
    do
        if ! grep -qE '^\s*auth.*pam_faillock\.so (preauth|authfail).*deny' "$pam_file"; then
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*preauth.*silent.*/ s/$/ deny='"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*authfail.*/ s/$/ deny='"$var_accounts_passwords_pam_faillock_deny"'/' "$pam_file"
        else
            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock\.so.*preauth.*silent.*\)\('"deny"'=\)[0-9]\+\(.*\)/\1\2'"$var_accounts_passwords_pam_faillock_deny"'\3/' "$pam_file"
            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock\.so.*authfail.*\)\('"deny"'=\)[0-9]\+\(.*\)/\1\2'"$var_accounts_passwords_pam_faillock_deny"'\3/' "$pam_file"
        fi
    done
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

if [ -f /usr/bin/authselect ]; then
    if ! authselect check; then
echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
It is not recommended to manually edit the PAM files when authselect tool is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
exit 1
fi
authselect enable-feature with-faillock

authselect apply-changes -b
else
    
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for pam_file in "${AUTH_FILES[@]}"
do
    if ! grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+(preauth silent|authfail).*$' "$pam_file" ; then
        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix\.so.*/i auth        required      pam_faillock.so preauth silent' "$pam_file"
        sed -i --follow-symlinks '/^auth.*required.*pam_deny\.so.*/i auth        required      pam_faillock.so authfail' "$pam_file"
        sed -i --follow-symlinks '/^account.*required.*pam_unix\.so.*/i account     required      pam_faillock.so' "$pam_file"
    fi
    sed -Ei 's/(auth.*)(\[default=die\])(.*pam_faillock\.so)/\1required     \3/g' "$pam_file"
done

fi

AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    regex="^\s*even_deny_root"
    line="even_deny_root"
    if ! grep -q $regex $FAILLOCK_CONF; then
        echo $line >> $FAILLOCK_CONF
    fi
    for pam_file in "${AUTH_FILES[@]}"
    do
        if [ -e "$pam_file" ] ; then
            PAM_FILE_PATH="$pam_file"
            if [ -f /usr/bin/authselect ]; then
                
                if ! authselect check; then
                echo "
                authselect integrity check failed. Remediation aborted!
                This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
                It is not recommended to manually edit the PAM files when authselect tool is available.
                In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
                exit 1
                fi

                CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
                # If not already in use, a custom profile is created preserving the enabled features.
                if [[ ! $CURRENT_PROFILE == custom/* ]]; then
                    ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
                    authselect create-profile hardening -b $CURRENT_PROFILE
                    CURRENT_PROFILE="custom/hardening"
                    
                    authselect apply-changes -b --backup=before-hardening-custom-profile
                    authselect select $CURRENT_PROFILE
                    for feature in $ENABLED_FEATURES; do
                        authselect enable-feature $feature;
                    done
                    
                    authselect apply-changes -b --backup=after-hardening-custom-profile
                fi
                PAM_FILE_NAME=$(basename "$pam_file")
                PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

                authselect apply-changes -b
            fi
            
        if grep -qP "^\s*auth\s.*\bpam_faillock.so\s.*\beven_deny_root\b" "$PAM_FILE_PATH"; then
            sed -i -E --follow-symlinks "s/(.*auth.*pam_faillock.so.*)\beven_deny_root\b=?[[:alnum:]]*(.*)/\1\2/g" "$PAM_FILE_PATH"
        fi
            if [ -f /usr/bin/authselect ]; then
                
                authselect apply-changes -b
            fi
        else
            echo "$pam_file was not found" >&2
        fi
    done
else
    for pam_file in "${AUTH_FILES[@]}"
    do
        if ! grep -qE '^\s*auth.*pam_faillock\.so (preauth|authfail).*even_deny_root' "$pam_file"; then
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*preauth.*silent.*/ s/$/ even_deny_root/' "$pam_file"
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*authfail.*/ s/$/ even_deny_root/' "$pam_file"
        fi
    done
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi


# Remediation is applicable only in certain platforms
if rpm --quiet -q pam; then

var_accounts_passwords_pam_faillock_unlock_time='900'


if [ -f /usr/bin/authselect ]; then
    if ! authselect check; then
echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
It is not recommended to manually edit the PAM files when authselect tool is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
exit 1
fi
authselect enable-feature with-faillock

authselect apply-changes -b
else
    
AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")
for pam_file in "${AUTH_FILES[@]}"
do
    if ! grep -qE '^\s*auth\s+required\s+pam_faillock\.so\s+(preauth silent|authfail).*$' "$pam_file" ; then
        sed -i --follow-symlinks '/^auth.*sufficient.*pam_unix\.so.*/i auth        required      pam_faillock.so preauth silent' "$pam_file"
        sed -i --follow-symlinks '/^auth.*required.*pam_deny\.so.*/i auth        required      pam_faillock.so authfail' "$pam_file"
        sed -i --follow-symlinks '/^account.*required.*pam_unix\.so.*/i account     required      pam_faillock.so' "$pam_file"
    fi
    sed -Ei 's/(auth.*)(\[default=die\])(.*pam_faillock\.so)/\1required     \3/g' "$pam_file"
done

fi

AUTH_FILES=("/etc/pam.d/system-auth" "/etc/pam.d/password-auth")

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    regex="^\s*unlock_time\s*="
    line="unlock_time = $var_accounts_passwords_pam_faillock_unlock_time"
    if ! grep -q $regex $FAILLOCK_CONF; then
        echo $line >> $FAILLOCK_CONF
    else
        sed -i --follow-symlinks 's|^\s*\(unlock_time\s*=\s*\)\(\S\+\)|\1'"$var_accounts_passwords_pam_faillock_unlock_time"'|g' $FAILLOCK_CONF
    fi
    for pam_file in "${AUTH_FILES[@]}"
    do
        if [ -e "$pam_file" ] ; then
            PAM_FILE_PATH="$pam_file"
            if [ -f /usr/bin/authselect ]; then
                
                if ! authselect check; then
                echo "
                authselect integrity check failed. Remediation aborted!
                This remediation could not be applied because an authselect profile was not selected or the selected profile is not intact.
                It is not recommended to manually edit the PAM files when authselect tool is available.
                In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
                exit 1
                fi

                CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
                # If not already in use, a custom profile is created preserving the enabled features.
                if [[ ! $CURRENT_PROFILE == custom/* ]]; then
                    ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
                    authselect create-profile hardening -b $CURRENT_PROFILE
                    CURRENT_PROFILE="custom/hardening"
                    
                    authselect apply-changes -b --backup=before-hardening-custom-profile
                    authselect select $CURRENT_PROFILE
                    for feature in $ENABLED_FEATURES; do
                        authselect enable-feature $feature;
                    done
                    
                    authselect apply-changes -b --backup=after-hardening-custom-profile
                fi
                PAM_FILE_NAME=$(basename "$pam_file")
                PAM_FILE_PATH="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE_NAME"

                authselect apply-changes -b
            fi
            
        if grep -qP "^\s*auth\s.*\bpam_faillock.so\s.*\bunlock_time\b" "$PAM_FILE_PATH"; then
            sed -i -E --follow-symlinks "s/(.*auth.*pam_faillock.so.*)\bunlock_time\b=?[[:alnum:]]*(.*)/\1\2/g" "$PAM_FILE_PATH"
        fi
            if [ -f /usr/bin/authselect ]; then
                
                authselect apply-changes -b
            fi
        else
            echo "$pam_file was not found" >&2
        fi
    done
else
    for pam_file in "${AUTH_FILES[@]}"
    do
        if ! grep -qE '^\s*auth.*pam_faillock\.so (preauth|authfail).*unlock_time' "$pam_file"; then
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*preauth.*silent.*/ s/$/ unlock_time='"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
            sed -i --follow-symlinks '/^auth.*required.*pam_faillock\.so.*authfail.*/ s/$/ unlock_time='"$var_accounts_passwords_pam_faillock_unlock_time"'/' "$pam_file"
        else
            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock\.so.*preauth.*silent.*\)\('"unlock_time"'=\)[0-9]\+\(.*\)/\1\2'"$var_accounts_passwords_pam_faillock_unlock_time"'\3/' "$pam_file"
            sed -i --follow-symlinks 's/\(^auth.*required.*pam_faillock\.so.*authfail.*\)\('"unlock_time"'=\)[0-9]\+\(.*\)/\1\2'"$var_accounts_passwords_pam_faillock_unlock_time"'\3/' "$pam_file"
        fi
    done
fi

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi
