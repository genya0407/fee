module Main exposing (Model(..), Msg(..), init, main, subscriptions, update, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, pre, text)
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
    | Loaded Feeds
    | Failure


type alias Name =
    String


type alias FeedUrl =
    String


type Feeds
    = Feeds (Dict Name FeedUrl)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFeeds result ->
            case result of
                Ok feeds ->
                    ( Loaded feeds, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



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

        Loaded (Feeds feeds) ->
            div [] (Dict.toList feeds |> List.map (\( name, url ) -> text url))
