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
    , serverTime : Maybe Time.Posix
    }


type alias FrontendModel =
    { counter : Int
    , clientId : String
    , apiConnection : ApiConnection
    , positionConfig : Maybe PositionConfig
    , serverTime : Maybe Time.Posix
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

type OrderSide
    = Buy
    | Sell


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | ApiConnectionChanged ApiConnection
    | PositionConfigChanged (Maybe PositionConfig)


type BackendMsg
    = ClientConnected SessionId ClientId
    | GetAccountInfo
    | GotAccountInfo (Result Error JsonTranslation.AccountInfo.Root)    
    | Tick Time.Posix
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | NewApiConnection ApiConnection
    | NewPositionConfig (Maybe PositionConfig)
    | AccountInfoSuccess JsonTranslation.AccountInfo.Root
    | AccountInfoFailure Http.Error
    | ServerTime Time.Posix