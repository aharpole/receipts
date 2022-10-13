# Receipts

So you always have the receipts on Twitter

## What it's for

I use Twitter likes (nee favorites) as a way to keep a record of memorable tweets. However, Twitter's handling of these leaves a lot to be desired. You have limited ability to search through favorites, for instance, and Twitter doesn't seem to keep a record of when you liked a tweet, so if you happen to like a 5 year old tweet that got retweeted to your timeline today, good luck finding it.

Receipts saves your liked tweets as Markdown files, and it downloads any Twitter-native attached media to your computer as well. If a tweet quotes another tweet, that quoted tweet will be included in the Markdown file and nested a quote level deep (also complete with attached media).

## Some assembly required

I built this for myself, and I have not put any effort into easy installation. I built this with the goal of having it run on my own computer, and I built it so that it didn't add any servers of my own I need to maintain. It uses sqlite as a database to avoid needing a DB server running. It runs background jobs using ActiveJob in case I want to scale later but everything is currently configured to run inline so you don't need to set up persistent background job process that runs.

You need:

- A way to put links to tweets you want to bookmark in a folder. In my case, I use a Dropbox folder because I can conveniently write to Dropbox from anywhere, and it's easy to work with Dropbox on my computer since it's just another folder I can read. You have a couple options:
    - Originally, I used an IFTTT recipe that watched for new favorited tweets and then would put a file in Dropbox that I would watch. This method fell out of favor for me because I realized Twitter's API shows you favorited tweets in chronological order by the tweet's creation date, not the time you favorited the tweet. For a prolific favorite-r like me, that means that if I favorite a tweet from as recently as a few months ago, IFTTT might not be able to pick it up.
    - I ended up building an iOS/macOS shortcut which I'll describe more below
    - If you use Alfred and you frequently copy links to tweets to your clipboard, I made a Twitter Receipt workflow.
- Ideally, have a tool on your computer that watches a folder for new incoming tweets and kicks off a Rake task to import those tweets into Receipts. I'm using Hazel:

My Hazel setup looks like this (the `2>` part of my command is just logging errors to a text file; it's optional):

![screenshot of Hazel setup for importing tweets automatically](https://user-images.githubusercontent.com/507570/194731094-8cf0c07e-b53d-41f1-abea-fb64218cbdf0.png)


### Ruby setup

I built this on Ruby 2.7.1 but this should work on any modern Ruby.

If you're on a Mac, use a tool like `rbenv` or `rvm` to install a Ruby; don't rely on the system Ruby.

If you're on Windows I can't help you because I've never run any Ruby applications on Windows, but you should still be able to use Receipts!

The basic commands you'll want to use:

- clone the repo: `git clone git@github.com:aharpole/receipts.git`
- `cd receipts`
- `bundle install`
- `bin/rake db:create db:migrate db:seed`

At this point, the app is set up.

### API key

You'll need to [sign up for a Twitter API key](https://developer.twitter.com/en/portal/petition/essential/basic-info).

Run `bin/rails credentials:edit` and set up the YML file so that you have a `twitter` section that looks like this:

```yml
twitter:
  consumer_key: XXX
  consumer_secret: XXX
  access_token: XXX
  access_token_secret: XXX
```

To import tweets, you run `bin/rake import_from_file path/to/tweet.txt`

The Rake task expects a text file with one tweet URL per line.

Tweets will get saved to `~/twitter_receipts`. Change this in `TweetMarkdown::BASE_PATH` in `tweet_markdown.rb`.


## The Shortcut

To install the shortcut:
https://www.icloud.com/shortcuts/8e3a36169b4c4ddf884c58886353a381

This shortcut works on iOS and macOS.

To use it on macOS from the share menu, I use an app called [ShareBot](https://apps.apple.com/us/app/sharebot-for-shortcuts/id1597340986?mt=12)

## Alfred Workflow

You can find the Alfred workflow at `twitter_receipt.alfredworkflow`

