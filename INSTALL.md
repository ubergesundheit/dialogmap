# Docker and fig

  * Install Docker and fig
  * Install nginx
  * `fig build`
  * `fig run app rake db:create`
  * `fig run app rake db:migrate`
  * `fig up`

```
server {
  listen 80;
  server_name localhost; # change to match your URL
  root /usr/src/app/public; # I assume your app is located at this location

  location / {
    proxy_pass http://172.17.0.177:3000; # match the name of upstream directive which is defined above
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location ~* ^/assets/ {
    # Per RFC2616 - 1 year maximum expiry
    expires 1y;
    add_header Cache-Control public;

    # Some browsers still send conditional-GET requests if there's a
    # Last-Modified header or an ETag header even if they haven't
    # reached the expiry date sent in the Expires header.
    add_header Last-Modified "";
    add_header ETag "";
    break;
  }
}
```


# Installation

You should have cloned the repository and installed most of the dependencies (No need for a running postgres server or postgis. e.g. only run `bundle`)

#### Provisioning (prepare your server)
  * copy your ssh key to your host
    - `ssh-copy-id -i ~/.ssh/id_rsa.pub user@host`
    - or
    - ssh into your host
    - append your ssh-key to the `authorized_keys` file
  * `cd` into the `infrastructure` folder
  * `knife solo prepare user@host`
  * obtain app secret and keys from facebook, google and twitter
  * modify `nodes/host.json`. Use the `node.json.example` as base.
  * look at the vhost template if you want to use ssl, or ask someone who knows nginx and chef..
  * `knife solo cook user@host` - this will take long and show some warnings but will run through

## Deployment (installing the app to the server)

#### In project root
  * `cd` to the project root
  * modify `config/deploy/production.rb` - change the ip/hostname of your host
  * modify `config/deploy.rb` - normally you don't have to change things in here
  * `bundle exec cap production deploy`
