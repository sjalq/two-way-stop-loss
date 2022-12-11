module Types exposing (..)

import Browser
import Browser.Navigation as Nav
import Decimal exposing (..)
import Http exposing (Error)
import JsonTranslation.AccountInfo exposing (..)
import JsonTranslation.AccountValueAtTimeJson exposing (..)
import JsonTranslation.DeleteOpenOrders exposing (..)
import JsonTranslation.PlaceOrder exposing (..)
import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Time
import Url as Url


type alias ApiConnection =
    { key : String
    , secret : String
    }


type alias Asset =
    String


type alias TwoWayStop =
    { symbol : String
    , stopPrice : Decimal
    , limitPriceDown : Decimal
    , limitPriceUp : Decimal
    }


type alias AccountValueAtTime =
    { time : Time.Posix
    , value : Decimal
    }


twoWayStopDefault : TwoWayStop
twoWayStopDefault =
    { symbol = ""
    , stopPrice = Decimal.zero
    , limitPriceDown = Decimal.zero
    , limitPriceUp = Decimal.zero
    }


type Email
    = Email String


type alias User =
    { email : Email
    , salt : String
    , passwordHash : String
    }


type UserDict
    = Dict Email User


type alias BackendModel =
    { counter : Int
    , apiConnection : ApiConnection
    , twoWayStop : TwoWayStop
    , serverTime : Maybe Time.Posix
    , orderHistory : List JsonTranslation.PlaceOrder.Root
    , accountValueOverTime : List AccountValueAtTime
    }


type alias Page =
    { key : Nav.Key
    , url : Url.Url
    }


type alias FrontendModel =
    { page : Page
    , counter : Int
    , clientId : String
    , apiConnection : ApiConnection
    , twoWayStop : TwoWayStop
    , serverTime : Maybe Time.Posix
    }


type FrontendMsg
    = CounterChange CounterMsg
    | ApiConnectionChange ApiConnectionMsg
    | TwoWayStopChange TwoWayStopMsg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | FNoop


type CounterMsg
    = Increment
    | Decrement


type ApiConnectionMsg
    = KeyChanged String
    | SecretChanged String
    | ChangeApiConnection


type TwoWayStopMsg
    = SymbolChanged String
    | StopPriceChanged String
    | LimitPriceDownChanged String
    | LimitPriceUpChanged String
    | ChangeTwoWayStop


type OrderSide
    = Buy
    | Sell


type OrderType
    = Market
    | Limit
    | Stop
    | StopLimit
    | MarketIfTouched
    | LimitIfTouched
    | MarketWithLeftOverAsLimit
    | Pegged


type OrderPlacements
    = None
    | Up
    | Down


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | ApiConnectionChanged ApiConnection
    | TwoWayStopChanged TwoWayStop


type BackendMsg
    = ClientConnected SessionId ClientId
    | GetAccountInfo
    | GetAccountInfoResponse (Result Error JsonTranslation.AccountInfo.Root)
    | ResetStopOrder Time.Posix
    | CancelAllOrders Time.Posix
    | ResetStopOrderResponse (Result Error JsonTranslation.PlaceOrder.Root)
    | CancelAllOrdersResponse (Result Error (List JsonTranslation.DeleteOpenOrders.Root))
    | CalculateAccountValue Time.Posix
    | CalculateAccountValueResponse Time.Posix (Result Error Decimal)
    | Tick Time.Posix
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | NewTwoWayStop TwoWayStop
    | AccountInfoSuccess JsonTranslation.AccountInfo.Root
    | AccountInfoFailure Http.Error
    | ResetStopOrderSuccess JsonTranslation.PlaceOrder.Root
    | ResetStopOrderFailure Http.Error
    | ServerTime Time.Posix
    | Nope
