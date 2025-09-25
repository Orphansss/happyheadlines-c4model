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
        articleDb         = container "Article Database" "SQL Database" "Published articles." {
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
    articleService -> articleQueue "Subscribes to the lastest articles in order to persist them in a database"
    articleService -> articleDb "Store and read articles"

    // Profanity, Comments & Publisher → Containers
    publisherWebApp -> publisherService "Publishing an article"    
    publisherService -> profanityService "Filtering out profanity"
    profanityService -> profanityDb "Fetchibg profanity words"
    
    website -> commentService "Posting a comment"
    website -> commentService "Requesting comments"
    commentService -> commentDb "Storing a comment"
        commentService -> commentDb "Fetching comments"
    commentService -> profanityService "Filtering out profanity"

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
    newsletterService -> articleQueue "Subscribes to receive the lastest news first for immediate newsletter"
    newsletterService -> articleService "Request article for daily newsletter"
    newsletterService -> subscriberService "Fetch subscriber information"
  }

    views {
    systemContext happyHeadlines "happyContext" {
        include publisher reader subscriber happyHeadlines
        autolayout lr
        title "Happy Headlines - System Context"
    }

    container happyHeadlines "happyPublisherView" {
        include publisher publisherWebApp articleService draftService draftDb publisherService profanityService profanityDb articleQueue newsletterService articleDb
        autolayout lr
        title "Happy Headlines - Container (Publisher)"
    }

    container happyHeadlines "happyReaderView" {
        include reader website articleService commentService commentDb subscriberService subscriberDb subscriberQueue articleQueue articleDb profanityService profanityDb
        autolayout lr
        title "Happy Headlines - Container (Reader)"
    }

    container happyHeadlines "happySubscriberView" {
        include subscriber website articleService commentService commentDb subscriberService subscriberDb subscriberQueue articleQueue newsletterService articleDb profanityService profanityDb
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
