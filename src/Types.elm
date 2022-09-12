module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import BinanceDecoder exposing (..)
import Http exposing (Error)
-- import Numeric.Decimal as Decimal exposing (Decimal)
import Decimal exposing (..)

type alias ApiConnection =
    { key : String
    , secret : String
    }

type alias Asset = String

type alias StopOrder = 
    { triggerPrice : Decimal
    , price : Decimal
    }

type alias PositionConfig = 
    { asset : Asset
    , denominatingAsset : Asset
    , downStop : StopOrder
    , upStop : StopOrder
    }

type alias BackendModel =
    { counter : Int
    , apiConnection : ApiConnection
    , positionConfig : Maybe PositionConfig
    }


type alias FrontendModel =
    { counter : Int
    , clientId : String
    , apiConnection : ApiConnection
    }
    

type FrontendMsg
    = Increment
    | Decrement
    | KeyChanged String
    | SecretChanged String
    | ChangeApiConnection
    | FNoop


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | ApiConnectionChanged ApiConnection


type BackendMsg
    = ClientConnected SessionId ClientId
    | GetAccountInfo
    | GotAccountInfo (Result Error AccountInfo)    
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | AccountInfoSuccess AccountInfo
    | AccountInfoFailure Http.Error
