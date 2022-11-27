module Types exposing (..)


import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import Http exposing (Error)
import Decimal exposing (..)
import Time
import JsonTranslation.AccountInfo exposing (..)


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

-- type alias StopOrder = 
--     { symbol : String
--     , stopPrice : Decimal
--     , limitPrice : Decimal
--     , side : OrderSide
--     }


-- type alias PositionConfig = 
--     { downStop : StopOrder 
--     , upStop : StopOrder
--     }

-- positionConfigDefault : PositionConfig
-- positionConfigDefault = 
--     { upStop = 
--         { symbol = ""
--         , stopPrice = Decimal.zero
--         , limitPrice = Decimal.zero 
--         , side = Buy
--         }   
--     , downStop = 
--         { symbol = ""
--         , stopPrice = Decimal.zero
--         , limitPrice = Decimal.zero 
--         , side = Buy
--         }
--     }

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
    , twoWayStop : Maybe TwoWayStop -- initially assumes only 1 position with 100% of the funds
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


-- type PositionConfigMsg
--     = DownStopOrderChange StopOrderMsg
--     | UpStopOrderChange StopOrderMsg
--     | SymbolChanged String
--     | ChangePositionConfig

type TwoWayStopMsg
    = SymbolChanged String
    | StopPriceChanged String
    | LimitPriceDownChanged String
    | LimitPriceUpChanged String


-- type StopOrderMsg 
--     = StopSymbolChanged String
--     | StopPriceChanged String
--     | LimitPriceChanged String

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
    | GotAccountInfo (Result Error JsonTranslation.AccountInfo.Root)    
    | Tick Time.Posix
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | NewTwoWayStop TwoWayStop
    | AccountInfoSuccess JsonTranslation.AccountInfo.Root
    | AccountInfoFailure Http.Error
    | ServerTime Time.Posix