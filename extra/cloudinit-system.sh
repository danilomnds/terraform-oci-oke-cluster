#!/bin/bash
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh

# download binaries on the worker node. 
# if at your company the outbound traffic for the internet is not allowed, you can upload these files to a bucket.
wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/oke-credential-provider-for-ocir-linux-amd64 -O /usr/local/bin/credential-provider-oke
wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/credential-provider-config.yaml -P /etc/kubernetes/

# add permission to execute
sudo chmod 755 /usr/local/bin/credential-provider-oke

# configure kubelet with image credential provider
bash /var/run/oke-init.sh --kubelet-extra-args "--register-with-taints=CriticalAddonsOnly=true:NoSchedule --image-credential-provider-bin-dir=/usr/local/bin/ --image-credential-provider-config=/etc/kubernetes/credential-provider-config.yaml"

timedatectl set-timezone Brazil/East

# Add Log rotate
echo '/var/log/cron
/var/log/messages
/var/log/secure
/var/log/audit/audit.log
{
    daily
    compress
    size 2G
    rotate 4
    notifempty
    sharedscripts
    postrotate
        /bin/kill -HUP `cat /var/run/rsyslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}' > /etc/logrotate.d/syslog


# Add Cron 
echo "0 */4 * * * root /usr/bin/find /var/mail/ -type f -cmin +5 -exec rm -f {} \;
0 */4 * * * root /usr/bin/find /var/spool/postfix/maildrop/ -type f -cmin +5 -exec rm -f {} \;
0 */4 * * * root /usr/bin/find /var/spool/mail/ -type f -cmin +5 -exec rm -f {} \;
" > /etc/cron.d/clean_varlnx