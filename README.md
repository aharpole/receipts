# Receipts

So you always have the receipts on Twitter

## What it's for

I use Twitter likes (nee favorites) as a way to keep a record of memorable tweets. However, Twitter's handling of these leaves a lot to be desired. You have limited ability to search through favorites, for instance, and Twitter doesn't seem to keep a record of when you liked a tweet, so if you happen to like a 5 year old tweet that got retweeted to your timeline today, good luck finding it.

Receipts saves your liked tweets as Markdown files, and it downloads any Twitter-native attached media to your computer as well. If a tweet quotes another tweet, that quoted tweet will be included in the Markdown file and nested a quote level deep (also complete with attached media).

## Some assembly required

I built this for myself, and I have not put any effort into easy installation. I built this with the goal of having it run on my own computer, and I built it so that it didn't add any servers of my own I need to maintain. It uses sqlite as a database to avoid needing a DB server running. It uses ActiveJob in case I want to scale later but it's just running everything inline at the moment.

You need:

- Something that keeps an eye out for new tweets you fave. For that, I use IFTTT and i have it write to a file on Dropbox with the URL of the favorited tweet.
- Something on your computer that can see those new tweets and tell Receipts to import the liked tweet. For that, I am using an app called Hazel which watches for the new file to be added to Dropbox, which then kicks off a Rake task to import 


* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
