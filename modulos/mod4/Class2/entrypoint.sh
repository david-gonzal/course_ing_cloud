#!/bin/bash
if [ -n "$SSH_PUBLIC_KEY" ]; then
    mkdir -p /home/adminlab/.ssh
    echo "$SSH_PUBLIC_KEY" > /home/adminlab/.ssh/authorized_keys
    chown -R adminlab:root /home/adminlab/.ssh
    chmod 700 /home/adminlab/.ssh
    chmod 600 /home/adminlab/.ssh/authorized_keys
fi

exec /usr/sbin/sshd -D