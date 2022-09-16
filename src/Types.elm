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

positionConfigDefault : PositionConfig
positionConfigDefault = 
    { asset = ""
    , denominatingAsset = ""
    , upStop = 
        { triggerPrice = Decimal.zero
        , limitPrice = Decimal.zero 
        }
    , downStop = 
        { triggerPrice = Decimal.zero
        , limitPrice = Decimal.zero
        } 
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
    = CounterChange CounterMsg
    | ApiConnectionChange ApiConnectionMsg
    | PositionConfigChange PositionConfigMsg
    | FNoop


type CounterMsg
    = Increment
    | Decrement


type ApiConnectionMsg 
    = KeyChanged String
    | SecretChanged String
    | ChangeApiConnection


type PositionConfigMsg
    = AssetChanged String
    | DenominatingAssetChanged String
    | DownStopOrderChange StopOrderMsg
    | UpStopOrderChange StopOrderMsg
    | ChangePositionConfig


type StopOrderMsg 
    = TriggerPriceChanged String
    | LimitPriceChanged String


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | ApiConnectionChanged ApiConnection
    | PositionConfigChanged (Maybe PositionConfig)


type BackendMsg
    = ClientConnected SessionId ClientId
    | GetAccountInfo
    | GotAccountInfo (Result Error AccountInfo)    
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | NewPositionConfig (Maybe PositionConfig)
    | AccountInfoSuccess AccountInfo
    | AccountInfoFailure Http.Error