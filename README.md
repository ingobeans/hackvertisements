# Hackvertisements

Show off your hackclub projects with *hackvertisements*!

Hackvertisements are small banner embeds you can add to your website. Every time it is loaded, it will display a random hackvertisement submitted by fellow hackclubbers, showcasing off a certified cool project :3

Everything is completely free in every sense of the word and the hackvertisements may not be commercial in any way. This is **not** a place to advertise your vibecoded business. This is however a place for you to showcase that project you're super passionate about!!

## Running locally

1. Install Ruby on Rails (good luck).

2. Clone this :-)

3. Then i think you need to do `bundle install`.

4. Do `rails db:create db:migrate` i think ?

5. Then you probably want to set up the .env file! Run `cp .env.example .env`, then open .env and follow the instructions there.

6. And then you can run the server with `rails s` and hope it works!!

### Local CDN

There's a local CDN test server that is used for development to not send requests to the real Hackclub CDN during development. It should be run alongside the main rails server.
The local CDN test server can be run with python (flask):

`python fake_cdn.py`

Note: make sure you have set `CDN_BASE_URL` in your .env.

### Fake users

There's a python helper script for adding fake users to the db. This is particularly useful if you want to avoid setting up Hackclub authentication, as you can use this with the dev login instead.

Launch it using:

`python fake_user_adder.py`