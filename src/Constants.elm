module Constants exposing (canonicalSiteUrl, githubLink, maxWidthDefault, maxWidthLarge, rssFeed, siteLinkedIn, siteTagline, siteTwitter)

import Css exposing (Px, px)


siteTagline : String
siteTagline =
    "DrifterCode - The great functional programming journey"


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://driftercode.com/"


siteTwitter : String
siteTwitter =
    "larsparsfromage"


siteLinkedIn : String
siteLinkedIn =
    "https://www.linkedin.com/in/larslilloulvestad/"


githubLink : String
githubLink =
    "https://github.com/kodeFant/driftercode.com"


rssFeed : String
rssFeed =
    "/blog/feed.xml"


maxWidthLarge : Px
maxWidthLarge =
    px 1000


maxWidthDefault : Px
maxWidthDefault =
    px 700
