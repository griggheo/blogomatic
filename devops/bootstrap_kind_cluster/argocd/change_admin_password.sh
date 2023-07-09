#!/bin/bash

NEWPASS=$1
BCRYPT_PASS=$(argocd account bcrypt --password $NEWPASS)

kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'"$BCRYPT_PASS"'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
