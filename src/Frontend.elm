module Frontend exposing (Model, app)


import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes


import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (type_)
import Types exposing (FrontendMsg(..))
import Helpers exposing (..)
import Decimal exposing (Decimal)
import Http


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
        CounterChange counterMsg ->
            case counterMsg of 
                Increment ->
                    ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

                Decrement ->
                    ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        ApiConnectionChange apiMsg ->
            let 
                oldApiConnection= model.apiConnection
            in
                case apiMsg of
                    KeyChanged key ->
                        ( { model | apiConnection = { oldApiConnection | key = key } }, Cmd.none )

                    SecretChanged secret ->
                        ( { model | apiConnection = { oldApiConnection | secret = secret } }, Cmd.none )

                    ChangeApiConnection ->
                        ( model, sendToBackend (ApiConnectionChanged model.apiConnection) )

        
        PositionConfigChange positionMsg ->
            let 
                oldPositionConfig = model.positionConfig |> Maybe.withDefault positionConfigDefault

                updateStop oldStop stopMsg = 
                    case stopMsg of
                        LimitPriceChanged priceString ->
                            let 
                                maybePrice = Decimal.fromIntString priceString
                            in
                                case maybePrice of
                                    Just price ->
                                        { oldStop | limitPrice = price }

                                    Nothing ->
                                        oldStop

                        TriggerPriceChanged priceString ->
                            let 
                                maybePrice = Decimal.fromIntString priceString
                            in
                                case maybePrice of
                                    Just price ->
                                        { oldStop | triggerPrice = price }

                                    Nothing ->
                                        oldStop
            in
                case positionMsg of
                    AssetChanged asset ->
                        ( { model | positionConfig = Just { oldPositionConfig | asset = asset } }, Cmd.none )

                    DenominatingAssetChanged denominatingAsset ->
                        ( { model | positionConfig = Just { oldPositionConfig | denominatingAsset = denominatingAsset } }, Cmd.none )

                    ChangePositionConfig ->
                        ( model, sendToBackend (PositionConfigChanged model.positionConfig) )

                    DownStopOrderChange downMsg ->
                        ( { model | positionConfig = Just { oldPositionConfig | downStop = updateStop oldPositionConfig.downStop downMsg } }
                        , Cmd.none )

                    UpStopOrderChange upMsg ->
                        ( { model | positionConfig = Just { oldPositionConfig | upStop = updateStop oldPositionConfig.downStop upMsg } }
                        , Cmd.none )
                        

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

        NewPositionConfig positionConfig ->
            ( { model | positionConfig = positionConfig }, Cmd.none )

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
        input msg value placeholder label = 
            Input.text 
                [] 
                { onChange = msg
                , text = value
                , placeholder = Just (Input.placeholder [] (text placeholder)) 
                , label = Input.labelAbove [] (text label)
                }
        
        apiView = 
            column 
                []     
                [ text "API Connection"
                , input KeyChanged model.apiConnection.key "Enter your API key" "Key"
                , input SecretChanged model.apiConnection.secret "Enter your API secret" "Secret"
                , Element.text model.apiConnection.key
                , Element.text model.apiConnection.secret
                , Input.button buttonStyle { onPress = Just ChangeApiConnection, label = text "Update API Connection" }
                ]

        positionConfigView = 
            let
                positionConfig = model.positionConfig |> Maybe.withDefault positionConfigDefault
            in
                column
                    [ spacing 10 ]
                    [ text "Position Config"
                    , input AssetChanged positionConfig.asset "Enter the asset you want to trade" "Asset"
                    , input DenominatingAssetChanged positionConfig.denominatingAsset "Enter the asset you want to trade with" "Denominating Asset"
                    , input 
                        TriggerPriceChanged 
                        (positionConfig.upStop.triggerPrice |> Decimal.toString) 
                        "Enter the trigger price" "Up Stop Trigger Price"
                        |> Element.map UpStopOrderChange
                    , input 
                        LimitPriceChanged 
                        (positionConfig.upStop.limitPrice |> Decimal.toString) 
                        "Enter the limit price" "Up Stop Limit Price"
                        |> Element.map UpStopOrderChange
                    , input
                        TriggerPriceChanged 
                        (positionConfig.downStop.triggerPrice |> Decimal.toString) 
                        "Enter the trigger price" "Down Stop Trigger Price"
                        |> Element.map DownStopOrderChange
                    , input
                        LimitPriceChanged 
                        (positionConfig.downStop.limitPrice |> Decimal.toString) 
                        "Enter the limit price" "Down Stop Limit Price"
                        |> Element.map DownStopOrderChange
                    , Input.button buttonStyle { onPress = Just ChangePositionConfig, label = text "Update Position Config" }
                    ]


        buttonStyle = 
            [ padding 5
            -- , alignLeft
            , Border.width 2
            , Border.rounded 6
            , Border.color color.blue
            , Background.color color.lightBlue
            ]
    in
        layout [ padding 10 ] <|
            row [ spacing 10 ]
                [ Input.button 
                    buttonStyle { onPress = Just (CounterChange Increment), label = text "+" }
                , text (String.fromInt model.counter)
                , Input.button buttonStyle { onPress = Just (CounterChange Decrement), label = text "-" }
                , apiView |> Element.map ApiConnectionChange
                , positionConfigView |> Element.map PositionConfigChange
                ]

color =
    { blue = rgb255 0x72 0x9F 0xCF
    , darkCharcoal = rgb255 0x2E 0x34 0x36
    , lightBlue = rgb255 0xC5 0xE8 0xF7
    , lightGrey = rgb255 0xE0 0xE0 0xE0
    , white = rgb255 0xFF 0xFF 0xFF
    }