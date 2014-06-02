# Installation

#### Provisioning (prepare your server)
  * copy your ssh key to your host
    - `ssh-copy-id -i ~/.ssh/id_rsa.pub user@host`
    - or
    - ssh into your host
    - append your ssh-key to the `authorized_keys` file
  * `knife solo prepare user@host`
  * modify `nodes/host.json`. Use the `node.json.example` as base.
  * look at the vhost template if you want to use ssl, or ask someone who knows nginx and chef..
  * `knife solo cook user@host` - this will take long and show some errors but will run through

## Deployment (installing the app to the server)

#### In project root
  * modify `config/deploy/production.rb` - change the ip/hostname of your host
  * modify `config/deploy.rb` - normally you don't have to change things in here
  * `bundle exec cap production deploy`
