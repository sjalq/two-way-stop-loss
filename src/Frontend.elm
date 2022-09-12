module Frontend exposing (Model, app)

import Html exposing (Html, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (type_)
import Types exposing (FrontendMsg(..))
import Helpers
import Helpers exposing (..)
import Decimal exposing (Decimal)


type alias Model =
    FrontendModel


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "v1"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
    ( { counter = 0
    , clientId = ""
    , apiConnection = { key = ""
                      , secret = "" }
    , positionConfig = Nothing }
    , Cmd.none )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

        Decrement ->
            ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        KeyChanged key ->
            let 
                oldApiConnection= model.apiConnection
                newApiConnection = { oldApiConnection | key = key }
            in
            ( { model | apiConnection = newApiConnection }, Cmd.none )
            -- Debug.log key Noop

        SecretChanged secret ->
            let 
                oldApiConnection= model.apiConnection
                newApiConnection = { oldApiConnection | secret = secret }
            in
            ( { model | apiConnection = newApiConnection }, Cmd.none )
            -- Debug.log secret Noop

        ChangeApiConnection ->
            ( model, sendToBackend (ApiConnectionChanged model.apiConnection) )

        FNoop ->
            ( model, Cmd.none )

        -- ChangeApiConnection apiConnection ->
        --     ( { model | apiConnection = apiConnection }, sendToBackend (ApiConnectionChanged apiConnection) )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        CounterNewValue newValue clientId ->
            ( { model | counter = newValue, clientId = clientId }, Cmd.none )

        NewApiConnection apiConnection ->
            ( { model | apiConnection = apiConnection }, Cmd.none )

        AccountInfoFailure err ->
            let
                _ = 
                    case err of 
                        Http.BadUrl url ->
                            Debug.log "BadUrl" url

                        Http.Timeout ->
                            Debug.log "Timeout" ""

                        Http.NetworkError ->
                            Debug.log "NetworkError" ""

                        Http.BadStatus response ->
                            Debug.log "BadStatus" <| String.fromInt response

                        Http.BadBody body ->
                            Debug.log "BadBody" body
            in
                ( model, Cmd.none )

        AccountInfoSuccess _ ->
            ( model, Cmd.none )
        

view : Model -> Html FrontendMsg
view model =
    let
        apiView = 
            Html.div 
                [] 
                [ Html.text "API Connection"
                , Html.input [ onInput KeyChanged ] [  ] 
                , Html.input [ onInput SecretChanged ] [  ]
                , Html.div [] [ Html.text model.apiConnection.key ]
                , Html.div [] [ Html.text model.apiConnection.secret ]
                , Html.button [ onClick ChangeApiConnection ] [ text "Update API Connection" ]
                ]

        positionConfigView = 
            Html.div
                []
                [ Html.text "Position Config"
                , Html.input [ onInput AssetChanged ] [] 
                , Html.input [ onInput DenominatingAssetChanged ] []
                , Html.div [] [ model.positionConfig |> mapWithDefault .asset "" |> Html.text ]
                , Html.div [] [ model.positionConfig |> mapWithDefault .denominatingAsset "" |> Html.text ]
                , Html.input [ onInput DownTriggerPriceChanged ] []
                , Html.input [ onInput DownLimitPriceChanged ] []
                , Html.div [] [ model.positionConfig |> mapToDecimalStringOrZero (.downStop >> .triggerPrice) |> Html.text ]
                , Html.div [] [ model.positionConfig |> mapToDecimalStringOrZero (.downStop >> .limitPrice) |> Html.text ]
                , Html.input [ onInput UpTriggerPriceChanged ] []
                , Html.input [ onInput UpLimitPriceChanged ] []
                , Html.div [] [ model.positionConfig |> mapToDecimalStringOrZero (.upStop >> .triggerPrice) |> Html.text ]
                , Html.div [] [ model.positionConfig |> mapToDecimalStringOrZero (.upStop >> .limitPrice) |> Html.text ]
                , Html.button [ onClick ChangePositionConfig ] [ text "Update Position Config" ]    
                ]
    in
    Html.div [ style "padding" "30px" ]
        [ Html.button [ onClick Increment ] [ text "+" ]
        , Html.text (String.fromInt model.counter)
        , Html.button [ onClick Decrement ] [ text "-" ]
        , Html.div [] [ Html.text "Click me then refresh me!" ]
        , apiView
        , positionConfigView
        ]
