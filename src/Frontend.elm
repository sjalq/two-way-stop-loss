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
        a = 1
        -- labeledInput label msg =
        --     Html.div []
        --         [ Html.label [] [ Html.text label ]
        --         , Html.input [ onInput msg ] []
        --         ]

        -- labeledValue label value =
        --     Html.div []
        --         [ Html.label [] [ Html.text label ]
        --         , Html.div [] [ Html.text value ]
        --         ]

        -- labeledButton label msg =
        --     Html.button [ onClick msg ] [ Html.text label ]
            
        apiView = 
            column 
                []     
                [ text "API Connection"
                , Input.text 
                    [] 
                    { onChange = KeyChanged
                    , text = model.apiConnection.key
                    , placeholder =
                        Just <|
                            Input.placeholder [] <|
                                text "Enter your API key"
                    , label = Input.labelAbove [] <| text "API Key"
                    }
                , Input.text 
                    [] 
                    { onChange = KeyChanged
                    , text = model.apiConnection.secret
                    , placeholder =
                        Just <|
                            Input.placeholder [] <|
                                text "Enter your API key"
                    , label = Input.labelAbove [] <| text "API Key"
                    }
                , Element.text model.apiConnection.key
                , Element.text model.apiConnection.secret
                , Input.button buttonStyle { onPress = Just ChangeApiConnection, label = text "Update API Connection" }
                ]

        -- positionConfigView = 
        --     Html.div
        --         []
        --         [ Html.text "Position Config"
        --         , labeledInput "Asset" AssetChanged
        --         , labeledInput "Denominating Asset" DenominatingAssetChanged 
        --         , labeledInput "Down Trigger Price" TriggerPriceChanged |> Html.map DownStopOrderChange
        --         , labeledInput "Down Stop Price" LimitPriceChanged |> Html.map DownStopOrderChange
        --         , labeledInput "Up Trigger Price" TriggerPriceChanged |> Html.map UpStopOrderChange
        --         , labeledInput "Up Stop Price" LimitPriceChanged |> Html.map UpStopOrderChange
        --         , labeledValue "Asset" (model.positionConfig |> mapStringOrBlank .asset)
        --         , labeledValue "Denominating Asset" (model.positionConfig |> mapStringOrBlank .denominatingAsset)
        --         , labeledValue "Down Trigger Price" (model.positionConfig |> mapDecimalOrBlank (.downStop >> .triggerPrice))
        --         , labeledValue "Down Stop Price" (model.positionConfig |> mapDecimalOrBlank (.downStop >> .limitPrice))
        --         , labeledValue "Up Trigger Price" (model.positionConfig |> mapDecimalOrBlank (.upStop >> .triggerPrice))
        --         , labeledValue "Up Stop Price" (model.positionConfig |> mapDecimalOrBlank (.upStop >> .limitPrice))
        --         , labeledButton "Update Position Config" ChangePositionConfig
        --         ]
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
                ]

        -- Html.div [ style "padding" "30px" ]
        --     [ Html.button [ onClick (CounterChange Increment) ] [ text "+" ]
        --     , Html.text (String.fromInt model.counter)
        --     , Html.button [ onClick (CounterChange Decrement) ] [ text "-" ]
        --     , Html.div [] [ Html.text "Click me then refresh me!" ]
        --     , apiView |> Html.map ApiConnectionChange
        --     , positionConfigView |> Html.map PositionConfigChange
        --     ]

color =
    { blue = rgb255 0x72 0x9F 0xCF
    , darkCharcoal = rgb255 0x2E 0x34 0x36
    , lightBlue = rgb255 0xC5 0xE8 0xF7
    , lightGrey = rgb255 0xE0 0xE0 0xE0
    , white = rgb255 0xFF 0xFF 0xFF
    }