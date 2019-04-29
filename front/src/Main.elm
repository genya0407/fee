module Main exposing (Model(..), Msg(..), init, main, subscriptions, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, button, div, input, pre, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, dict, field, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Loading
    | Loaded Feeds DraftFeed
    | Failure


type alias Name =
    String


type alias FeedUrl =
    String


type Feeds
    = Feeds (Dict Name FeedUrl)


type DraftFeed
    = DraftFeed Name FeedUrl


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "/feeds.json"
        , expect = Http.expectJson GotFeeds feedsDecoder
        }
    )


feedsDecoder : Decoder Feeds
feedsDecoder =
    Json.Decode.map Feeds
        (dict
            (field "feed_url" string)
        )



-- UPDATE


type Msg
    = GotFeeds (Result Http.Error Feeds)
    | RemoveFeed Name
    | ChangeDraftFeedName Name
    | ChangeDraftFeedUrl FeedUrl
    | AddFeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFeeds result ->
            case result of
                Ok feeds ->
                    ( Loaded feeds (DraftFeed "" ""), Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )

        RemoveFeed name ->
            case model of
                Loaded (Feeds d) draft ->
                    ( Loaded (Feeds (Dict.remove name d)) draft, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ChangeDraftFeedName newName ->
            case model of
                Loaded feeds (DraftFeed oldName url) ->
                    ( Loaded feeds (DraftFeed newName url), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ChangeDraftFeedUrl newUrl ->
            case model of
                Loaded feeds (DraftFeed name oldUrl) ->
                    ( Loaded feeds (DraftFeed name newUrl), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        AddFeed ->
            case model of
                Loaded (Feeds d) (DraftFeed name url) ->
                    ( Loaded (Feeds <| Dict.insert name url d) (DraftFeed "" ""), Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to load your json."

        Loading ->
            text "Loading..."

        Loaded feeds draft ->
            div [] (viewFeeds feeds ++ [ viewAddFeed draft ])


viewAddFeed : DraftFeed -> Html Msg
viewAddFeed (DraftFeed name url) =
    div []
        [ input [ type_ "text", value name, onInput ChangeDraftFeedName ] []
        , text ": "
        , input [ type_ "text", value url, onInput ChangeDraftFeedUrl ] []
        , button [ onClick AddFeed ] [ text "追加" ]
        ]


viewFeeds : Feeds -> List (Html Msg)
viewFeeds (Feeds feeds) =
    Dict.toList feeds
        |> List.map viewFeed


viewFeed : ( Name, FeedUrl ) -> Html Msg
viewFeed ( name, url ) =
    div []
        [ text (name ++ ": " ++ url)
        , button [ onClick (RemoveFeed name) ] [ text "削除" ]
        ]
