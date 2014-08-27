# DialogMap - Spatially enhanced dialogues

This repository contains a Rails/Angular single-page application to support dialogues with spatial references. It allows users to reference spatial features to parts of their contributions. Other users can write answers with own spatial references. It was developed in the context of a masters thesis with the title "Supporting public deliberation through spatially enhanced dialogues" by [Gerald Pape](http://geraldpape.io). The aim of the thesis is to study the benefits applying dialogues on a map to public deliberation.
You can find a small demonstration video [here](https://www.youtube.com/watch?v=lwWGbaIyn4k).

## Features
* Creation of topics with categories, picture and time limit
* Creation of new spatial features (points, polygons) with reference to text (words)
* Creation of references to spatial features created within the context of other contributions
* Creation of hyperlinks
* Edit your contributions and answers
* Two way highlighting between textual and spatial representations
* Sign up with Facebook, Google, Twitter (more possible thanks to Omniauth)
* Favorite contributions and answers (similar to Facebook Like)
* Filter contributions by categories and full text
* Sort categories

## Deployment
You need a linux server with root access and at least 512m ram (the more the merrier) and ~5g drive

Then:
See [INSTALL.md](INSTALL.md) (Chef and Capistrano)

## Libraries and technologies used
non exhaustive list. see [Gemfile](Gemfile) for everything used
#### Backend
* [Ruby on Rails 4.1](http://rubyonrails.org/)
* [PostgreSQL](http://www.postgresql.org/)
* [PostGIS](http://postgis.net/)

#### Frontend
* [AngularJS](https://angularjs.org/)
* [Leaflet](http://leafletjs.com/)
* [mapbox.js](https://www.mapbox.com/mapbox.js/api/v1.6.4/)

## Development
Fork this repository and clone it to your development machine. You should have the following tools installed
* Ruby > 2.1.2 (you can install it with [ruby-build](https://github.com/sstephenson/ruby-build) which is a part of rbenv)
* Bundler
* [rbenv](https://github.com/sstephenson/rbenv)
* [rbenv-vars](https://github.com/sstephenson/rbenv-vars)
* PostgreSQL (should be at least 9.3)
* PostGIS (should be at least 2.1.2)

After cloning the repository, run `bundle` and then `bundle exec rake db:migrate` in the project root. If no errors occured, start your development server with `bundle exec rails s`

Then:
1. Hack away
2. Send pull request
3. Everyone party

## License and Copyright
This software is open source and Apache Licensed. Copyright Gerald Pape. See [LICENSE](LICENSE)
