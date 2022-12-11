module JsonTranslation.DeleteOpenOrders exposing (..)

import Json.Decode
import Json.Encode



-- Required packages:
-- * elm/json


type Root
    = Root0 RootObject
    | Root1 RootMember


type alias RootObject =
    { clientOrderId : String
    , cummulativeQuoteQty : String
    , executedQty : String
    , orderId : Int
    , orderListId : Int
    , origClientOrderId : String
    , origQty : String
    , price : String
    , side : String
    , status : String
    , symbol : String
    , timeInForce : String
    , type_ : String
    }


type alias RootMember =
    { contingencyType : String
    , listClientOrderId : String
    , listOrderStatus : String
    , listStatusType : String
    , orderListId : Int
    , orderReports : List RootMemberOrderReports
    , orders : List RootMemberOrdersObject
    , symbol : String
    , transactionTime : Int
    }


type RootMemberOrderReports
    = RootMemberOrderReports0 RootMemberOrderReportsObject
    | RootMemberOrderReports1 RootMemberOrderReportsMember


type alias RootMemberOrderReportsObject =
    { clientOrderId : String
    , cummulativeQuoteQty : String
    , executedQty : String
    , icebergQty : String
    , orderId : Int
    , orderListId : Int
    , origClientOrderId : String
    , origQty : String
    , price : String
    , side : String
    , status : String
    , stopPrice : String
    , symbol : String
    , timeInForce : String
    , type_ : String
    }


type alias RootMemberOrderReportsMember =
    { clientOrderId : String
    , cummulativeQuoteQty : String
    , executedQty : String
    , icebergQty : String
    , orderId : Int
    , orderListId : Int
    , origClientOrderId : String
    , origQty : String
    , price : String
    , side : String
    , status : String
    , symbol : String
    , timeInForce : String
    , type_ : String
    }


type alias RootMemberOrdersObject =
    { clientOrderId : String
    , orderId : Int
    , symbol : String
    }


rootDecoder : Json.Decode.Decoder (List Root)
rootDecoder =
    Json.Decode.list rootItemDecoder


rootItemDecoder : Json.Decode.Decoder Root
rootItemDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map Root0 <| rootObjectDecoder
        , Json.Decode.map Root1 <| rootMemberDecoder
        ]


rootObjectDecoder : Json.Decode.Decoder RootObject
rootObjectDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootObject
                (Json.Decode.field "clientOrderId" Json.Decode.string)
                (Json.Decode.field "cummulativeQuoteQty" Json.Decode.string)
                (Json.Decode.field "executedQty" Json.Decode.string)
                (Json.Decode.field "orderId" Json.Decode.int)
                (Json.Decode.field "orderListId" Json.Decode.int)
                (Json.Decode.field "origClientOrderId" Json.Decode.string)
                (Json.Decode.field "origQty" Json.Decode.string)
                (Json.Decode.field "price" Json.Decode.string)
    in
    Json.Decode.map6 (<|)
        fieldSet0
        (Json.Decode.field "side" Json.Decode.string)
        (Json.Decode.field "status" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)
        (Json.Decode.field "timeInForce" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)


rootMemberDecoder : Json.Decode.Decoder RootMember
rootMemberDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootMember
                (Json.Decode.field "contingencyType" Json.Decode.string)
                (Json.Decode.field "listClientOrderId" Json.Decode.string)
                (Json.Decode.field "listOrderStatus" Json.Decode.string)
                (Json.Decode.field "listStatusType" Json.Decode.string)
                (Json.Decode.field "orderListId" Json.Decode.int)
                (Json.Decode.field "orderReports" <| Json.Decode.list rootMemberOrderReportsItemDecoder)
                (Json.Decode.field "orders" <| Json.Decode.list rootMemberOrdersObjectDecoder)
                (Json.Decode.field "symbol" Json.Decode.string)
    in
    Json.Decode.map2 (<|)
        fieldSet0
        (Json.Decode.field "transactionTime" Json.Decode.int)


rootMemberOrderReportsItemDecoder : Json.Decode.Decoder RootMemberOrderReports
rootMemberOrderReportsItemDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map RootMemberOrderReports0 <| rootMemberOrderReportsObjectDecoder
        , Json.Decode.map RootMemberOrderReports1 <| rootMemberOrderReportsMemberDecoder
        ]


rootMemberOrderReportsObjectDecoder : Json.Decode.Decoder RootMemberOrderReportsObject
rootMemberOrderReportsObjectDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootMemberOrderReportsObject
                (Json.Decode.field "clientOrderId" Json.Decode.string)
                (Json.Decode.field "cummulativeQuoteQty" Json.Decode.string)
                (Json.Decode.field "executedQty" Json.Decode.string)
                (Json.Decode.field "icebergQty" Json.Decode.string)
                (Json.Decode.field "orderId" Json.Decode.int)
                (Json.Decode.field "orderListId" Json.Decode.int)
                (Json.Decode.field "origClientOrderId" Json.Decode.string)
                (Json.Decode.field "origQty" Json.Decode.string)
    in
    Json.Decode.map8 (<|)
        fieldSet0
        (Json.Decode.field "price" Json.Decode.string)
        (Json.Decode.field "side" Json.Decode.string)
        (Json.Decode.field "status" Json.Decode.string)
        (Json.Decode.field "stopPrice" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)
        (Json.Decode.field "timeInForce" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)


rootMemberOrderReportsMemberDecoder : Json.Decode.Decoder RootMemberOrderReportsMember
rootMemberOrderReportsMemberDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootMemberOrderReportsMember
                (Json.Decode.field "clientOrderId" Json.Decode.string)
                (Json.Decode.field "cummulativeQuoteQty" Json.Decode.string)
                (Json.Decode.field "executedQty" Json.Decode.string)
                (Json.Decode.field "icebergQty" Json.Decode.string)
                (Json.Decode.field "orderId" Json.Decode.int)
                (Json.Decode.field "orderListId" Json.Decode.int)
                (Json.Decode.field "origClientOrderId" Json.Decode.string)
                (Json.Decode.field "origQty" Json.Decode.string)
    in
    Json.Decode.map7 (<|)
        fieldSet0
        (Json.Decode.field "price" Json.Decode.string)
        (Json.Decode.field "side" Json.Decode.string)
        (Json.Decode.field "status" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)
        (Json.Decode.field "timeInForce" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)


rootMemberOrdersObjectDecoder : Json.Decode.Decoder RootMemberOrdersObject
rootMemberOrdersObjectDecoder =
    Json.Decode.map3 RootMemberOrdersObject
        (Json.Decode.field "clientOrderId" Json.Decode.string)
        (Json.Decode.field "orderId" Json.Decode.int)
        (Json.Decode.field "symbol" Json.Decode.string)


encodedRoot : List Root -> Json.Encode.Value
encodedRoot root =
    Json.Encode.list encodedRootItem root


encodedRootItem : Root -> Json.Encode.Value
encodedRootItem root =
    case root of
        Root0 value ->
            encodedRootObject value

        Root1 value ->
            encodedRootMember value


encodedRootObject : RootObject -> Json.Encode.Value
encodedRootObject rootObject =
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string rootObject.clientOrderId )
        , ( "cummulativeQuoteQty", Json.Encode.string rootObject.cummulativeQuoteQty )
        , ( "executedQty", Json.Encode.string rootObject.executedQty )
        , ( "orderId", Json.Encode.int rootObject.orderId )
        , ( "orderListId", Json.Encode.int rootObject.orderListId )
        , ( "origClientOrderId", Json.Encode.string rootObject.origClientOrderId )
        , ( "origQty", Json.Encode.string rootObject.origQty )
        , ( "price", Json.Encode.string rootObject.price )
        , ( "side", Json.Encode.string rootObject.side )
        , ( "status", Json.Encode.string rootObject.status )
        , ( "symbol", Json.Encode.string rootObject.symbol )
        , ( "timeInForce", Json.Encode.string rootObject.timeInForce )
        , ( "type", Json.Encode.string rootObject.type_ )
        ]


encodedRootMember : RootMember -> Json.Encode.Value
encodedRootMember rootMember =
    Json.Encode.object
        [ ( "contingencyType", Json.Encode.string rootMember.contingencyType )
        , ( "listClientOrderId", Json.Encode.string rootMember.listClientOrderId )
        , ( "listOrderStatus", Json.Encode.string rootMember.listOrderStatus )
        , ( "listStatusType", Json.Encode.string rootMember.listStatusType )
        , ( "orderListId", Json.Encode.int rootMember.orderListId )
        , ( "orderReports", Json.Encode.list encodedRootMemberOrderReportsItem rootMember.orderReports )
        , ( "orders", Json.Encode.list encodedRootMemberOrdersObject rootMember.orders )
        , ( "symbol", Json.Encode.string rootMember.symbol )
        , ( "transactionTime", Json.Encode.int rootMember.transactionTime )
        ]


encodedRootMemberOrderReportsItem : RootMemberOrderReports -> Json.Encode.Value
encodedRootMemberOrderReportsItem rootMemberOrderReports =
    case rootMemberOrderReports of
        RootMemberOrderReports0 value ->
            encodedRootMemberOrderReportsObject value

        RootMemberOrderReports1 value ->
            encodedRootMemberOrderReportsMember value


encodedRootMemberOrderReportsObject : RootMemberOrderReportsObject -> Json.Encode.Value
encodedRootMemberOrderReportsObject rootMemberOrderReportsObject =
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string rootMemberOrderReportsObject.clientOrderId )
        , ( "cummulativeQuoteQty", Json.Encode.string rootMemberOrderReportsObject.cummulativeQuoteQty )
        , ( "executedQty", Json.Encode.string rootMemberOrderReportsObject.executedQty )
        , ( "icebergQty", Json.Encode.string rootMemberOrderReportsObject.icebergQty )
        , ( "orderId", Json.Encode.int rootMemberOrderReportsObject.orderId )
        , ( "orderListId", Json.Encode.int rootMemberOrderReportsObject.orderListId )
        , ( "origClientOrderId", Json.Encode.string rootMemberOrderReportsObject.origClientOrderId )
        , ( "origQty", Json.Encode.string rootMemberOrderReportsObject.origQty )
        , ( "price", Json.Encode.string rootMemberOrderReportsObject.price )
        , ( "side", Json.Encode.string rootMemberOrderReportsObject.side )
        , ( "status", Json.Encode.string rootMemberOrderReportsObject.status )
        , ( "stopPrice", Json.Encode.string rootMemberOrderReportsObject.stopPrice )
        , ( "symbol", Json.Encode.string rootMemberOrderReportsObject.symbol )
        , ( "timeInForce", Json.Encode.string rootMemberOrderReportsObject.timeInForce )
        , ( "type", Json.Encode.string rootMemberOrderReportsObject.type_ )
        ]


encodedRootMemberOrderReportsMember : RootMemberOrderReportsMember -> Json.Encode.Value
encodedRootMemberOrderReportsMember rootMemberOrderReportsMember =
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string rootMemberOrderReportsMember.clientOrderId )
        , ( "cummulativeQuoteQty", Json.Encode.string rootMemberOrderReportsMember.cummulativeQuoteQty )
        , ( "executedQty", Json.Encode.string rootMemberOrderReportsMember.executedQty )
        , ( "icebergQty", Json.Encode.string rootMemberOrderReportsMember.icebergQty )
        , ( "orderId", Json.Encode.int rootMemberOrderReportsMember.orderId )
        , ( "orderListId", Json.Encode.int rootMemberOrderReportsMember.orderListId )
        , ( "origClientOrderId", Json.Encode.string rootMemberOrderReportsMember.origClientOrderId )
        , ( "origQty", Json.Encode.string rootMemberOrderReportsMember.origQty )
        , ( "price", Json.Encode.string rootMemberOrderReportsMember.price )
        , ( "side", Json.Encode.string rootMemberOrderReportsMember.side )
        , ( "status", Json.Encode.string rootMemberOrderReportsMember.status )
        , ( "symbol", Json.Encode.string rootMemberOrderReportsMember.symbol )
        , ( "timeInForce", Json.Encode.string rootMemberOrderReportsMember.timeInForce )
        , ( "type", Json.Encode.string rootMemberOrderReportsMember.type_ )
        ]


encodedRootMemberOrdersObject : RootMemberOrdersObject -> Json.Encode.Value
encodedRootMemberOrdersObject rootMemberOrdersObject =
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string rootMemberOrdersObject.clientOrderId )
        , ( "orderId", Json.Encode.int rootMemberOrdersObject.orderId )
        , ( "symbol", Json.Encode.string rootMemberOrdersObject.symbol )
        ]
