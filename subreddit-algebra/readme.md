### Subreddit Algebra

This directory contains the code and data behind the blog: [Sports Fans on Reddit](http://www.futuressport.com/en/insight/sports-fans-on-reddit.aspx).

The analysis is based on this fivethirtyeight article: [Dissecting Trump's Most Rabid Online Following](https://fivethirtyeight.com/features/dissecting-trumps-most-rabid-online-following/). The code has been adapted and added to.

The raw data (an online cache of Reddit comments going back to 2005) is from [Google's Big Query](https://bigquery.cloud.google.com/table/fh-bigquery:reddit_comments. all_starting_201501) and more information about the data can [be found here](https://www.reddit.com/r/bigquery/comments/3cej2b/17_billion_reddit_comments_loaded_on_bigquery/).

Details about the three files of code in this folder:

File | Description
---|---------
`processData.sql` | SQL code for filtering, processing, formatting and producing summary statistics for Reddit comment data from Google's Big Query.
`subredditVectorAnalysis.R` | Conducts a latent semantic analysis of over 50,000 subreddits that creates a vector representation of each one based on commenter co-occurence. Uses these vector representations to examine similarity between sets of sports subreddits and produce heatmap plots. It also implements "subreddit algebra:" the ability to add and subtract different subreddits to reveal how they relate to one another, although this aspect is not used in the article.
`computeUserOverlap.sql` | A separate SQL query used for computing the user overlap between r/The_Donald and other subreddits, also not used in the article. 
