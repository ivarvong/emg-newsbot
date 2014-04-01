EMG NewsBot
===========

We use Disqus for site comments. We wanted a way to be notified when a new one is posted, and allow internal discussion if the comment needs to be reviewed.

This Sinatra app pulls Disqus comments and posts new ones into a Basecamp project. When it sees a new comment, it adds its id to a Redis set.

Workers are ```sucker_punch``` jobs (Celluoid). Right now, there's an RSS worker and Disqus worker. The Twitter mention worker is disabled.

All credentials are set as ENV vars. This app will run for free on Heroku with the Redis Cloud addon. You'll need a server to POST to an endpoint to kick off the workers.
