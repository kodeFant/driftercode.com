module Util.Date exposing (formatDate)

import Date exposing (Date)
import Time exposing (Month(..), Weekday(..))


formatDate : Date -> String
formatDate date =
    Date.format "EEEE, d MMMM y" date
