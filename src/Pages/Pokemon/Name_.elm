module Pages.Pokemon.Name_ exposing (Model, Msg, page)

import Api
import Api.PokemonDetail exposing (Pokemon)
import Html exposing (Html)
import Html.Attributes as Attributes
import Http
import Page exposing (Page)
import Route.Path
import View exposing (View)


page : { name : String } -> Page Model Msg
page params =
    Page.element
        { init = init params
        , update = update
        , subscriptions = subscriptions
        , view = view params
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data Pokemon
    }


init : { name : String } -> ( Model, Cmd Msg )
init params =
    ( { pokemonData = Api.Loading }
    , Api.PokemonDetail.get
        { name = params.name
        , onResponse = PokeApiResponded
        }
    )



-- UPDATE



type Msg
    = PokeApiResponded (Result Http.Error Pokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok pokemon) ->
            ( { model | pokemonData = Api.Success pokemon }
            , Cmd.none
            )

        PokeApiResponded (Err httpError) ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : { name : String } -> Model -> View Msg
view params model =
    { title = [ params.name, " | Pokemon" ] |> String.concat
    , body =
        [ Html.div [ Attributes.class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ Attributes.class "title is-1" ] [ Html.text params.name ]
            , Html.h2 [ Attributes.class "subtitle is-6 is-underlined" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ]
                    [ Html.text "Back to Pokemon" ]
                ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ Attributes.class "has-text-centered p-6" ]
                    [ Html.text "Loading" ]

            Api.Success pokemon ->
                viewPokemon pokemon

            Api.Failure httpError ->
                Html.div [ Attributes.class "has-text-centered p-6" ]
                    [ Html.text (Api.toUserFriendlyMessage httpError) ]
        ]
    }


viewPokemon : Pokemon -> Html msg
viewPokemon pokemon =
    Html.div [ Attributes.class "container p-6 has-text-centered" ]
        [ viewPokemonImage pokemon
        , Html.p []
            [
                [ "Pokemon No. "
                , String.fromInt pokemon.pokedexId
                ]
                    |> String.concat
                    |> Html.text
            ]
        , viewPokemonTypes pokemon.types
        ]


viewPokemonImage : Pokemon -> Html msg
viewPokemonImage pokemon =
    Html.figure
        [ Attributes.class "image my-5 mx-auto"
        , Attributes.style "width" "256px"
        , Attributes.style "height" "256px"
        ]
        [ Html.img [ Attributes.src pokemon.spriteUrl, Attributes.alt pokemon.name ] []
        ]


viewPokemonTypes : List String -> Html msg
viewPokemonTypes types =
    Html.div [ Attributes.class "tags is-centered py-4" ]
        (List.map viewPokemonType types)


viewPokemonType : String -> Html msg
viewPokemonType pokemonType =
    Html.span [ Attributes.class "tag" ]
        [ Html.text pokemonType ]
