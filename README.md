# Hackvertisements

Show off your hackclub projects with *hackvertisements*!

Hackvertisements are small banner embeds you can add to your website. Every time it is loaded, it will display a random hackvertisement submitted by fellow hackclubbers, showcasing off a certified cool project :3

Everything is completely free in every sense of the word and the hackvertisements may not be commercial in any way. This is **not** a place to advertise your vibecoded business. This is however a place for you to showcase that project you're super passionate about!!

## Running locally

Install Ruby on Rails (good luck).

Clone this :-)

Then i think you need to do `bundle install`.

Do `rails db:create db:migrate` i think ?

Then you probably want to set up the .env file! Run `cp .env.example .env`, then open .env and follow the instructions there.

And then you can run the server with `rails s` and hope it works!!

There's also a local CDN test server that is used for development to not send requests to the real Hackclub CDN during development.
The local CDN test server can be run with python (flask):

`python fake_cdn.py`