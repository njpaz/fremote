Fremote
==============

Fremote is a web app to remote-control YouTube & Vimeo videos.  A user can send a link to a friend(or friends) they are chatting with and they can watch the video/movie at the same time.  Whoever has control of the "remote" can start/pause/fast-forward/rewind the video and it will control the video for every viewer.

## Features

* Server-sent Events via ActionController::Live
* Pub/Sub using ActiveSupport::Notifications
* Video.js API
* Streaming video scraped from multiple providrs
* MongoDB with Mongoid
* Live chat & playlist
* HAML
* User registration with Devise

## Supported Media Providers

* YouTube
* Vimeo
* Blip.tv
* Veoh
* Soundcloud
* Metacafe

## Unofficially Supported Media Providers
* VideoWeed (if the user's referrer info is disabled. lol)

## Demo

[fremote.tv](http://fremote.tv/)

## To Contribute

We'd love to have people contribute!  Simply fork the repo, make changes, and submit a pull request.

## Team

* Ben Titcomb [@Ravenstine](https://github.com/Ravenstine)
* Nicole Paz [@nicolejpaz](https://github.com/nicolejpaz)
