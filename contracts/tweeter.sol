// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Twitter {
    struct Tweet {
        uint id;
        address author;
        string content;
        uint likeCount;
        // mapping(address => bool) likes;

    }

    uint public  tweetCounter;
    mapping (uint => Tweet) public tweets;
    mapping (address => uint[]) public  userTweets;
    mapping(uint => mapping(address => bool)) public userLikedTweet;

    //events
    event TweetCreated(uint tweetId, address author, string content);
    event TweetLiked(uint tweetId, address liker);
    event TweetUnliked(uint tweetId, address unliker);

    // function to create a tweet
    function createTweet(string memory _content) public {
        tweetCounter ++; //create the tweet
        Tweet storage newTweet = tweets[tweetCounter];

        newTweet.id = tweetCounter;
        newTweet.author = msg.sender;
        newTweet.content = _content;
        newTweet.likeCount = 0;

        userTweets[msg.sender].push(tweetCounter);
        emit TweetCreated(tweetCounter, msg.sender, _content);
    }

    function getAllTweets()public view returns (Tweet[] memory) {
        Tweet[] memory allTweets = new Tweet[](tweetCounter);
        for(uint i =1; i<= tweetCounter; i++){
            allTweets[i-1] = tweets[i];
        }
        return allTweets;
    }

    function singleUserTweets(address _user) public  view returns(Tweet[] memory){
        // check the number of tweets the user has
        uint userTweetsCount = 0;
        for(uint i; i <= tweetCounter; i++){
            if(tweets[i].author == _user){
                userTweetsCount++;
            }
        } 

        Tweet[] memory allUserTweets = new Tweet[](tweetCounter);
        // make the size same as the user tweet size
        uint currentIndex = 0;
        for(uint i; i <= userTweetsCount; i++){
            if(tweets[i].author == _user){
                allUserTweets[currentIndex] = tweets[i];
                currentIndex++;
            }
        }
        return  allUserTweets;
    }

    function getTweet(uint _tweetId) public  view returns(Tweet memory){
        // ennsure the tweet exists;
        require(_tweetId > 0 && _tweetId <= tweetCounter, "Invalid tweet ID");
        
        return tweets[_tweetId];
    }

    function checkUserLIkeTweetStatus(uint _tweetId, address _user) public view  returns(bool){
        require(_tweetId > 0 && _tweetId <= tweetCounter, "Invalid tweet ID");
        return userLikedTweet[_tweetId][_user];
    }

    function likeTweet(uint _tweetId) public {
        require(_tweetId > 0 && _tweetId <= tweetCounter, "Invalid tweet ID");
        require(!userLikedTweet[_tweetId][msg.sender], "You have already liked this tweet");

        tweets[_tweetId].likeCount++;
        userLikedTweet[_tweetId][msg.sender] = true;

        emit TweetLiked(_tweetId, msg.sender);
    }

    function unlikeTweet(uint _tweetId) public {
        // Check if tweet ID is valid
        require(_tweetId > 0 && _tweetId <= tweetCounter, "Invalid tweet ID");
        
        // Check if user HAS liked the tweet (removed the ! operator)
        require(userLikedTweet[_tweetId][msg.sender], "You have not liked this tweet.");

        // Decrease like count
        tweets[_tweetId].likeCount--;
        
        // Set user's like status to false
        userLikedTweet[_tweetId][msg.sender] = false;

        // Emit the unlike event
        emit TweetUnliked(_tweetId, msg.sender);
    }

}