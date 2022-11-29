module Types exposing (..)


import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Http exposing (Error)
import Decimal exposing (..)
import Time
import JsonTranslation.AccountInfo exposing (..)
import JsonTranslation.PlaceOrder exposing (..)


type alias ApiConnection =
    { key : String
    , secret : String
    }


type alias Asset = String


type alias TwoWayStop = 
    { symbol : String
    , stopPrice : Decimal
    , limitPriceDown : Decimal
    , limitPriceUp : Decimal
    }


twoWayStopDefault : TwoWayStop
twoWayStopDefault = 
    { symbol = ""
    , stopPrice = Decimal.zero
    , limitPriceDown = Decimal.zero 
    , limitPriceUp = Decimal.zero 
    }


type alias BackendModel =
    { counter : Int
    , apiConnection : ApiConnection
    , twoWayStop : TwoWayStop 
    , serverTime : Maybe Time.Posix
    }


type alias FrontendModel =
    { counter : Int
    , clientId : String
    , apiConnection : ApiConnection
    , twoWayStop : TwoWayStop
    , serverTime : Maybe Time.Posix
    }
    

type FrontendMsg
    = CounterChange CounterMsg
    | ApiConnectionChange ApiConnectionMsg
    | TwoWayStopChange TwoWayStopMsg
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
    | ResetStopOrderResponse (Result Error JsonTranslation.PlaceOrder.Root)
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