##### Part 0: Formatted and processed data in BigQuery
## Thanks to Reddit users /u/Stuck_In_the_Matrix for pulling the data originally and /u/fhoffa for hosting the data on BigQery

#### Queries to create summary statistics for selected sets of subreddits
## Creating list of number of comments, authors and average scores for sports property related subreddits
SELECT subreddit, authors, comments, average_score, comments / authors AS comments_per_author
FROM (SELECT subreddit, SUM(1) AS authors, SUM(cnt) AS comments, SUM(sum_score) / SUM(cnt) AS average_score
     FROM (SELECT subreddit, author, COUNT(1) as cnt, SUM(score) AS sum_score
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE subreddit IN('AFL', 'CFL', 'nfl', 'soccer', 'MLS', 'rugbyunion', 
         'nrl', 'mlb', 'nhl', 'nba', 'ProGolf', 'tennis', 'Cricket', 'olympics', 'GAA',
         'CFB', 'CollegeBasketball', 'Boxing', 'formula1', 'MMA', 'ufc', 'NASCAR',
         'LaLiga', 'PremierLeague', 'baseball')
         GROUP BY subreddit, author 
         HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;

## Creating list of number of comments, authors and average scores for NFL teams
SELECT subreddit, authors, comments, average_score, comments / authors AS comments_per_author
FROM (SELECT subreddit, SUM(1) AS authors, SUM(cnt) AS comments, SUM(sum_score) / SUM(cnt) AS average_score
     FROM (SELECT subreddit, author, COUNT(1) as cnt, SUM(score) AS sum_score
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE subreddit IN('buffalobills', 'ravens', 'Colts', 'DenverBroncos', 'miamidolphins', 
                          'bengals', 'Jaguars', 'KansasCityChiefs', 'Patriots', 'Browns', 'Texans', 
                          'oaklandraiders', 'nyjets', 'steelers', 'Tennesseetitans', 'Chargers', 
                          'cowboys', 'CHIBears', 'falcons', 'AZCardinals', 'NYGiants', 'detroitlions', 
                          'panthers', '49ers', 'eagles', 'GreenBayPackers', 'Saints', 'Seahawks', 
                          'Redskins', 'minnesotavikings', 'buccaneers', 'StLouisRams', 'LosAngelesRams')
         GROUP BY subreddit, author 
         HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;


## Creating list of number of comments, authors and average scores for Premier League teams
SELECT subreddit, authors, comments, average_score, comments / authors AS comments_per_author
FROM (SELECT subreddit, SUM(1) AS authors, SUM(cnt) AS comments, SUM(sum_score) / SUM(cnt) AS average_score
     FROM (SELECT subreddit, author, COUNT(1) as cnt, SUM(score) AS sum_score
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE subreddit IN('Gunners', 'AFCBournemouth', 'chelseafc', 'crystalpalace', 'Everton', 'HullCity', 
         'lcfc', 'LiverpoolFC', 'MCFC', 'reddevils', 'SaintsFC', 'StokeCityFC', 'safc', 'coys', 'Watford_FC', 
         'WBAfootball', 'Hammers', 'swanseacity', 'Burnley', 'Middlesbrough')
         GROUP BY subreddit, author 
         HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;

## Creating list of number of comments, authors and average scores for MLB teams
SELECT subreddit, authors, comments, average_score, comments / authors AS comments_per_author
FROM (SELECT subreddit, SUM(1) AS authors, SUM(cnt) AS comments, SUM(sum_score) / SUM(cnt) AS average_score
     FROM (SELECT subreddit, author, COUNT(1) as cnt, SUM(score) AS sum_score
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE subreddit IN('angelsbaseball', 'whitesox', 'orioles', 'Astros', 'WahoosTipi', 'redsox', 'OaklandAthletics', 
                          'motorcitykitties', 'NYYankees', 'Mariners', 'KCRoyals', 'tampabayrays', 'TexasRangers', 
                          'minnesotatwins', 'Torontobluejays', 'azdiamondbacks', 'Cubs', 'Braves', 'ColoradoRockies', 
                          'Reds', 'letsgofish', 'Dodgers', 'Brewers', 'NewYorkMets', 'Padres', 'buccos', 'phillies', 
                          'SFGiants', 'Cardinals', 'Nationals')
         GROUP BY subreddit, author 
         HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;


## Creating list of number of comments, authors, and average scores for NBA Team subreddits
SELECT subreddit, authors, comments, average_score, comments / authors AS comments_per_author
FROM (SELECT subreddit, SUM(1) AS authors, SUM(cnt) AS comments, SUM(sum_score) / SUM(cnt) AS average_score
     FROM (SELECT subreddit, author, COUNT(1) as cnt, SUM(score) AS sum_score
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE subreddit IN('bostonceltics', 'chicagobulls', 'AtlantaHawks', 'GoNets', 'clevelandcavs', 'CharlotteHornets', 
         'NYKnicks', 'DetroitPistons', 'heat', 'sixers', 'pacers', 'OrlandoMagic', 'torontoraptors', 'MkeBucks', 
         'washingtonwizards', 'denvernuggets', 'warriors', 'Mavericks', 'timberwolves', 'LAClippers', 'rockets', 
         'Thunder', 'lakers', 'memphisgrizzlies', 'ripcity', 'suns', 'NOLAPelicans', 'UtahJazz', 'kings', 'NBASpurs')
         GROUP BY subreddit, author 
         HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;

#### Queries to create tables for subsequent use in R
## Creating list of number of users in each subreddit, save this as "subr_rank_all_starting_201501" for
## use in next query. Note that this includes data up to latest month available in BigQuery:
SELECT subreddit, authors, DENSE_RANK() OVER (ORDER BY authors DESC) AS rank_authors
FROM (SELECT subreddit, SUM(1) as authors
     FROM (SELECT subreddit, author, COUNT(1) as cnt 
         FROM [fh-bigquery:reddit_comments.all_starting_201501]
         WHERE author NOT IN (SELECT author FROM [fh-bigquery:reddit_comments.bots_201505])
         GROUP BY subreddit, author HAVING cnt > 0)
     GROUP BY subreddit) t
ORDER BY authors DESC;

## Creating list of number of users who authored at least 10 posts in pairs of subreddits: 
SELECT t1.subreddit, t2.subreddit, SUM(1) as NumOverlaps
FROM (SELECT subreddit, author, COUNT(1) as cnt 
     FROM [fh-bigquery:reddit_comments.all_starting_201501]
     WHERE author NOT IN (SELECT author FROM [fh-bigquery:reddit_comments.bots_201505])
     AND subreddit IN (SELECT subreddit FROM [subreddit-vectors:subredditoverlaps.subr_rank_all_starting_201501]
       WHERE rank_authors>200 AND rank_authors<2201)
     GROUP BY subreddit, author HAVING cnt > 10) t1
JOIN (SELECT subreddit, author, COUNT(1) as cnt 
     FROM [fh-bigquery:reddit_comments.all_starting_201501]
     WHERE author NOT IN (SELECT author FROM [fh-bigquery:reddit_comments.bots_201505])
     GROUP BY subreddit, author HAVING cnt > 10) t2
ON t1.author=t2.author
WHERE t1.subreddit!=t2.subreddit
GROUP BY t1.subreddit, t2.subreddit


#### Final query to calculate overlap between particular subreddits
SELECT t1.subreddit, t2.subreddit, SUM(1) as NumOverlaps
FROM (SELECT subreddit, author, COUNT(1) as cnt 
     FROM [fh-bigquery:reddit_comments.all_starting_201501]
     WHERE author NOT IN (SELECT author FROM [fh-bigquery:reddit_comments.bots_201505])
     AND subreddit IN ('LiverpoolFC', 'reddevils')
     GROUP BY subreddit, author HAVING cnt > 10) t1
JOIN (SELECT subreddit, author, COUNT(1) as cnt 
     FROM [fh-bigquery:reddit_comments.all_starting_201501]
     WHERE author NOT IN (SELECT author FROM [fh-bigquery:reddit_comments.bots_201505])
     AND subreddit IN ('LiverpoolFC', 'reddevils')
     GROUP BY subreddit, author HAVING cnt > 10) t2
ON t1.author=t2.author
WHERE t1.subreddit!=t2.subreddit
GROUP BY t1.subreddit, t2.subreddit
