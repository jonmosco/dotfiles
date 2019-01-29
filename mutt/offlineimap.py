#!/usr/bin/python

from subprocess import check_output

def get_pass(account):
    if account == 'fp':
        return check_output("gpg -dq ~/.offlineimapfp.gpg",
                shell=True).strip("\n")
    elif account == 'dtcc':
        return check_output("gpg -dq ~/.offlineimapdtcc.gpg",
                shell=True).strip("\n")
    if account == 'greengate':
        return check_output("gpg -dq ~/.offlineimapgreengate.gpg",
                shell=True).strip("\n")
    else:
        print("No account named: {}", account)
