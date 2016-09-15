alias i='sudo apt install'
alias vault_auth='gpg2 --no-tty --quiet --decrypt $VAULT_KEY | ~/apps/vault auth -method=userpass username=$VAULT_USER password=-'