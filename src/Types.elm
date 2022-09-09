module Types exposing (..)

import Lamdera exposing (ClientId, SessionId)
import Set exposing (Set)
import BinanceDecoder exposing (..)
import Http exposing (Error)

type alias ApiConnection =
    { key : String
    , secret : String
    }

type alias BackendModel =
    { counter : Int
    , apiConnection : ApiConnection
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
