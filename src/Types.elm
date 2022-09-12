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
    , limitPrice : Decimal
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
    , positionConfig : Maybe PositionConfig -- initially assumes only 1 position with 100% of the funds
    }


type alias FrontendModel =
    { counter : Int
    , clientId : String
    , apiConnection : ApiConnection
    , positionConfig : Maybe PositionConfig
    }
    

type FrontendMsg
    = Increment
    | Decrement
    | KeyChanged String
    | SecretChanged String
    | ChangeApiConnection
    | AssetChanged String
    | DenominatingAssetChanged String
    | DownTriggerPriceChanged String
    | DownLimitPriceChanged String
    | UpTriggerPriceChanged String
    | UpLimitPriceChanged String
    | ChangePositionConfig
    | FNoop


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | ApiConnectionChanged ApiConnection
    | PositionConfigChanged PositionConfig


type BackendMsg
    = ClientConnected SessionId ClientId
    | GetAccountInfo
    | GotAccountInfo (Result Error AccountInfo)    
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | NewPositionConfig PositionConfig
    | AccountInfoSuccess AccountInfo
    | AccountInfoFailure Http.Error