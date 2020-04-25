module Constants exposing (canonicalSiteUrl, maxWidthDefault, maxWidthLarge, siteLinkedIn, siteTagline, siteTwitter)

import Css exposing (Px, px)


siteTagline : String
siteTagline =
    "DrifterCode - The great functional programming journey"


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://driftercode.com"


siteTwitter : String
siteTwitter =
    "larsparsfromage"


siteLinkedIn : String
siteLinkedIn =
    "https://www.linkedin.com/in/larslilloulvestad/"


maxWidthLarge : Px
maxWidthLarge =
    px 1000


maxWidthDefault : Px
maxWidthDefault =
    px 700
