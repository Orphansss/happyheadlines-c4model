workspace "Happy Headlines" "C4 L1+L2" {
  model {
    # Actors
    publisher = person "Publisher" "Publishes positive news via the internal web app."
    reader = person "Reader"    "Reads articles and posts comments."
    subscriber = person "Subscriber" "Subcribes to newsletter."

    # System
    happyHeadlines = softwareSystem "Happy Headlines System" "Positive news platform." {

        # Publisher containers
        publisherWebApp   = container "Web Application (Publisher)" "ASP.NET Core MVC" "Allows publishers to save drafts and publish articles."
        publisherService  = container "Publisher Service" "ASP.NET Core Web API" "Finalizes publications."


        # Subscriber / Newsletter
        //Shared
        website           = container "Website (Reader)" "ASP.NET Core MVC" "Displays recent and highlighted articles."
        articleService    = container "Article Service" "ASP.NET Core Web API" "Serves articles and subscribes to article queue."
        commentService    = container "Comment Service" "ASP.NET Core Web API" "Handles reader comments."
        commentDb         = container "Comment Database" "SQL Database" "Stores comments." {
            tags "Database"
        }

        //Subscriber only
        subscriberService = container "Subscriber Service" "ASP.NET Core Web API" "Handles subscriptions."
        subscriberDb      = container "Subscriber Database" "SQL Database" "Subscriber info." {
            tags "Database"
        }
        subscriberQueue   = container "Subscriber Queue" "FIFO Queue" "New subscribers queued." {
            tags "Queue"
        }
        newsletterService = container "Newsletter Service" "ASP.NET Core Web API" "Sends daily newsletters."

  
        //profanity containers
        profanityService  = container "Profanity Service" "ASP.NET Core Web API" "Filters inappropriate language."
        profanityDb       = container "Profanity Database" "SQL Database" "Prohibited words." {
            tags "Database"
        }


        // Draft Containers
        draftService      = container "Draft Service" "ASP.NET Core Web API" "Manages article drafts."
        draftDb           = container "Draft Database" "SQL Database" "Stores drafts." {
            tags "Database"
        }

        // Load Balancer
        loadBalancer      = container "Load Balancer" "Distributes incoming traffic." {
            tags "Load Balancer"
        }

        // article database containers
        articleQueue      = container "Article Queue" "RabbitMQ" "Approved articles queued." {
            tags "Queue"
        }
        articleDb_Global  = container "Article Database (Global)" "SQL Database" "Published articles (Global)." {
            tags "Database"
        }
        articleDb_EU      = container "Article Database (EU)" "SQL Database" "Published articles (EU)." {
            tags "Database"
        }
        articleDb_NA      = container "Article Database (NA)" "SQL Database" "Published articles (NA)." {
            tags "Database"
        }        
        articleDb_SA      = container "Article Database (SA)" "SQL Database" "Published articles (SA)." {
            tags "Database"
        }
        articleDb_AF      = container "Article Database (AF)" "SQL Database" "Published articles (AF)." {
            tags "Database"
        }
        articleDb_AS      = container "Article Database (AS)" "SQL Database" "Published articles (AS)." {
            tags "Database"
        }
        articleDb_OC      = container "Article Database (OC)" "SQL Database" "Published articles (OC)." {
            tags "Database"
        }
        articleDb_AN      = container "Article Database (AN)" "SQL Database" "Published articles (AN)." {
            tags "Database"
        }

    }

    # Relationships 
    // Persons → Containers
    publisher -> publisherWebApp "Publishes articles and manages drafts"
    reader    -> website "Reads articles, comments"
    subscriber -> website "Reads articles, comments, and subscribes to newsletter"
    // Databases and Queues → Containers
    publisherService -> articleQueue "When a article is being published the article will be put into the article queue"
    articleQueue -> articleService "Subscribes to the lastest articles in order to persist them in a database"
    articleService -> articleDb_Global "Store and read articles"
    articleService -> articleDb_EU "Fetching & Storing articles (EU)"
    articleService -> articleDb_NA "Fetching & Storing articles (NA)"
    articleService -> articleDb_SA "Fetching & Storing articles (SA)"
    articleService -> articleDb_AF "Fetching & Storing articles (AF)"
    articleService -> articleDb_AS "Fetching & Storing articles (AS)"
    articleService -> articleDb_OC "Fetching & Storing articles (OC)"
    articleService -> articleDb_AN "Fetching & Storing articles (AN)"

    // Profanity, Comments & Publisher → Containers
    publisherWebApp -> publisherService "Publishing an article"    
    publisherService -> profanityService "Filtering out profanity"
    profanityService -> profanityDb "Fetchibg profanity words"
    
    website -> commentService "Post comments"
    commentService -> commentDb "Store and read comments"
    commentService -> profanityService "Checks comment"

    // Draft - Containers
    publisherWebApp -> draftService "Saving a draft"
    publisherWebApp -> draftService "Fetching drafts"
    draftService -> draftDb "Storing a drafts"    
    
    //Subscriber -> articleDb "Read articles"
    website  -> subscriberService "Subscribe and unsubscribe"
    subscriberService -> subscriberDb "Store and Reads subscribers"
    subscriberService -> subscriberQueue "Enqueue new subscriber"

    // Newsletter → Containers
    website -> newsletterService "Fetch & send out newsletters"
    newsletterService -> articleService "Fetch articles"
    newsletterService -> subscriberService "Fetch subscriber information"
  }

    views {
    systemContext happyHeadlines "happyContext" {
        include publisher reader subscriber happyHeadlines
        autolayout lr
        title "Happy Headlines - System Context"
    }

    container happyHeadlines "happyPublisherView" {
        include publisher publisherWebApp articleService draftService draftDb publisherService profanityService profanityDb articleQueue articleDb_Global articleDb_EU articleDb_NA articleDb_SA articleDb_AF articleDb_AS articleDb_OC articleDb_AN
        autolayout lr
        title "Happy Headlines - Container (Publisher)"
    }

    container happyHeadlines "happyReaderView" {
        include reader website articleService commentService commentDb subscriberService subscriberDb subscriberQueue articleQueue articleDb_Global articleDb_EU articleDb_NA articleDb_SA articleDb_AF articleDb_AS articleDb_OC articleDb_AN profanityService profanityDb
        autolayout lr
        title "Happy Headlines - Container (Reader)"
    }

    container happyHeadlines "happySubscriberView" {
        include subscriber website articleService commentService commentDb subscriberService subscriberDb subscriberQueue articleQueue newsletterService articleDb_Global articleDb_EU articleDb_NA articleDb_SA articleDb_AF articleDb_AS articleDb_OC articleDb_AN  profanityService profanityDb
        autolayout lr
        title "Happy Headlines - Container (Subscriber)"
    }


    styles {
        element "Element" { 
            color #ffffff 
        }
        element "Person" { 
            background #9b191f 
            shape person
        }
        element "Software System" { 
            background #ba1e25
        }
        element "Container" { 
            background #d9232b
        }
        element "Component" { 
            background #E66C5A
        }
        element "Database" { 
            shape cylinder
        }
        element "Queue" { 
            shape pipe 
        }
    }
    }
}
