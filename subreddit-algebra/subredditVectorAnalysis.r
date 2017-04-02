#######################################
#
# Program to analyze distance between
# Reddit subreddits using the cooccurrence
# of commentors across subreddits. 
# Also implements "subreddit algebra"
# by adding and subtracting subreddit
# vectors. 
# By @martintrevor_ for FiveThirtyEight
#
#######################################

library(reshape2)
library(lsa)
library(ggtern)
library(ggplot2)

##### Part 1: Load in the data

# This CSV file was created by running the SQL code in processData.sql in Google's BigQuery
rawsubredditvecs = read.table("all_starting_2015_01_overlaps_top2200_no200_10com_allrank_mod_122716.csv",header=TRUE,sep=",")

##### Part 2: Format and clean data for analysis

castsubredditvecs = dcast(rawsubredditvecs,t1_subreddit~t2_subreddit,FUN="identity",fill=0)
subredditvecst = as.matrix(castsubredditvecs[,-1])
rownames(subredditvecst) = castsubredditvecs[,1]
subredditvecs = t(subredditvecst)
subredditvecssums = apply(subredditvecs,1,sum)
subredditvecsnorm = sweep(subredditvecs,1,subredditvecssums,"/")
subredditvecssumscontext = apply(subredditvecs,2,sum)
contextprobs = subredditvecssumscontext/sum(subredditvecssumscontext)
subredditvecspmi = log(sweep(subredditvecsnorm,2,contextprobs,"/")) # PMI version
subredditvecsppmi = subredditvecspmi
subredditvecsppmi[subredditvecspmi<0] = 0 # PPMI version
scalar1 <- function(x) {x / sqrt(sum(x^2))} # Function to normalize vectors to unit length
subredditvecsppminorm = t(apply(subredditvecsppmi,1,scalar1))

##### Part 3: Analysis of subreddit similarities

## Looking at which subreddits are closest to each other (and combinations of subreddits)
cursubmat = subredditvecsppminorm
cursubmatt = t(cursubmat)
currownameslc = tolower(rownames(cursubmat))
# Function to calculate subreddit similarities and perform algebra
# Note that curops always has a leading "+"
findrelsubreddit <- function(cursubs,curops,numret=20) {
    cursubs = tolower(cursubs)
    curvec = 0
    for(i in 1:length(cursubs)) {
	    curvec = ifelse(curops[i]=="+",list(curvec + cursubmat[which(currownameslc==cursubs[i]),]),list(curvec - cursubmat[which(currownameslc==cursubs[i]),]))[[1]]
    }
    curclosesubs = cosine(x=curvec,y=cursubmatt)
    curclosesubso = order(curclosesubs,decreasing=TRUE)
    curclosesubsorder = curclosesubs[curclosesubso]
    curclosesubsorderc = curclosesubsorder[-which(tolower(names(curclosesubsorder))%in%cursubs)]
return(head(curclosesubsorderc,numret))
}

# Function to calculate similarity between two specified subreddits
subredditsimilarity <- function(sub1,sub2) {
	sub1 = tolower(sub1)
	sub2 = tolower(sub2)
	sub1vec = cursubmat[which(currownameslc==sub1),]
	sub2vec = cursubmat[which(currownameslc==sub2),]
	subsimilarity = cosine(x=sub1vec,y=sub2vec)
return(subsimilarity)
}

## function to calculate similarity matrix for set of subreddits
subredditmatrix <- function(cursubs) {
	cursubs = sort(tolower(cursubs))
	similaritymatrix = matrix(0, ncol=length(cursubs), nrow=length(cursubs))
	for(i in 1:length(cursubs)) {
		for(j in 1:length(cursubs)) {
			similaritymatrix[i,j] = subredditsimilarity(cursubs[i], cursubs[j])
		}
	}
	rownames(similaritymatrix) = cursubs
	colnames(similaritymatrix) = cursubs
return(similaritymatrix)
}

## matrix of similarities between premier league clubs (Middlesbrough did not have enough comments)
premierleagueclubs <- c("Gunners", "AFCBournemouth", "chelseafc", "crystalpalace", "Everton", 
		       "HullCity", "lcfc", "LiverpoolFC", "MCFC", "reddevils", "SaintsFC", 
		       "StokeCityFC", "safc", "coys", "Watford_FC", "WBAfootball", "Hammers", 
		       "swanseacity", "Burnley")
plmatrix <- subredditmatrix(premierleagueclubs)

## matrix of similarities between nfl teams (St Louis Rams moved to LA)
nflteams <- c("buffalobills", "ravens", "Colts", "DenverBroncos", "miamidolphins", "bengals", 
		   "Jaguars", "KansasCityChiefs", "Patriots", "Browns", "Texans", "oaklandraiders", 
		   "nyjets", "steelers", "Tennesseetitans", "Chargers", "cowboys", "CHIBears", "falcons", 
		   "AZCardinals", "NYGiants", "detroitlions", "panthers", "49ers", "eagles", 
		   "GreenBayPackers", "Saints", "Seahawks", "Redskins", "minnesotavikings", "buccaneers", 
		   "StLouisRams", "LosAngelesRams")
nflmatrix <- subredditmatrix(nflteams)

## matrix of similarities between nba teams
nbateams <- c("bostonceltics", "chicagobulls", "AtlantaHawks", "GoNets", "clevelandcavs", "CharlotteHornets", 
	      "NYKnicks", "DetroitPistons", "heat", "sixers", "pacers", "OrlandoMagic", "torontoraptors", 
	      "MkeBucks", "washingtonwizards", "denvernuggets", "warriors", "Mavericks", "timberwolves", 
	      "LAClippers", "rockets", "Thunder", "lakers", "memphisgrizzlies", "ripcity", "suns", "NOLAPelicans", 
	      "UtahJazz", "kings", "NBASpurs")
nbamatrix <- subredditmatrix(nbateams)

## matrix of similarities between mlb teams
mlbteams <- c("angelsbaseball", "whitesox", "orioles", "Astros", "WahoosTipi", "redsox", "OaklandAthletics", 
	      "motorcitykitties", "NYYankees", "Mariners", "KCRoyals", "tampabayrays", "TexasRangers", 
	      "minnesotatwins", "Torontobluejays", "azdiamondbacks", "Cubs", "Braves", "ColoradoRockies", 
	      "Reds", "letsgofish", "Dodgers", "Brewers", "NewYorkMets", "Padres", "buccos", "phillies", 
	      "SFGiants", "Cardinals", "Nationals")
mlbmatrix <- subredditmatrix(mlbteams)

## create and export plots
createplot <- function(matrix) {
	filename <- paste(deparse(substitute(matrix)),".png",sep="")
	matrix <- melt(matrix)
	
	p <- ggplot(matrix, aes(Var2, Var1)) + 
    	geom_tile(aes(fill = value), colour ="white") + 
    	scale_fill_gradient(low ="white", high ="black")

	base_size <- 9

	p <- p + theme_grey(base_size = base_size) + 
    	labs(x ="",y ="Subreddit Name") + scale_x_discrete(expand=c(0, 0)) +
    	scale_y_discrete(expand = c(0, 0)) +
	theme(legend.position = "none",
	      axis.ticks = element_blank(), 
	      axis.text.x = element_text(angle=315,hjust=0),
	      plot.margin = unit(c(1,1,1,1),"cm"))

	ggsave(filename=filename, plot=p)
}

createplot(nflmatrix)
createplot(nbamatrix)
createplot(mlbmatrix)
createplot(plmatrix)

nflmatrix <- melt(nflmatrix)

