module Pages.Home_ exposing (Model, Msg, page)

import Api
import Api.PokemonList
import Html exposing (Html)
import Html.Attributes as Attributes
import Http
import Page exposing (Page)
import Route.Path
import View exposing (View)


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- INIT


type alias Model =
    { pokemonData : Api.Data (List Pokemon)
    }


type alias Pokemon =
    { name : String
    }


init : ( Model, Cmd Msg )
init =
    ( { pokemonData = Api.Loading }
    , Api.PokemonList.getFirst150
        { onResponse = PokeApiResponded
        }
    )



-- UPDATE


type Msg
    = PokeApiResponded (Result Http.Error (List Pokemon))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PokeApiResponded (Ok listOfPokemon) ->
            ( { model | pokemonData = Api.Success listOfPokemon }
            , Cmd.none
            )
        
        PokeApiResponded (Err httpError) ->
            ( { model | pokemonData = Api.Failure httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pokemon"
    , body =
        [ Html.div [ Attributes.class "hero is-danger py-6 has-text-centered" ]
            [ Html.h1 [ Attributes.class "title is-1" ] [ Html.text "Pokemon" ]
            , Html.h2 [ Attributes.class "subtitle is-4" ] [ Html.text "Gotta fetch em all!" ]
            ]
        , case model.pokemonData of
            Api.Loading ->
                Html.div [ Attributes.class "has-text-centered p-6" ]
                    [ Html.text "Loading..."
                    ]

            Api.Success pokemon ->
                viewPokemonList pokemon
            
            Api.Failure error ->
                Html.div [ Attributes.class "has-text-centered p-6" ]
                    [ Html.text <| Api.toUserFriendlyMessage error
                    ]
        ]
    }


viewPokemonList : List Pokemon -> Html Msg
viewPokemonList pokemonList =
    Html.div [ Attributes.class "container py-6 p-5" ]
        [ Html.div [ Attributes.class "columns is-multiline" ]
            (List.indexedMap viewPokemon pokemonList)
        ]


viewPokemon : Int -> Pokemon -> Html Msg
viewPokemon index pokemon =
    let
        pokedexNumber : Int
        pokedexNumber =
            index + 1

        pokemonImageUrl : String
        pokemonImageUrl =
            [ "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/"
            , String.fromInt pokedexNumber
            , ".png"
            ] |> String.concat

        pokemonDetailsRoute : Route.Path.Path
        pokemonDetailsRoute =
            Route.Path.Pokemon_Name_
                { name = pokemon.name
                }
    in
    Html.div [ Attributes.class "column is-4-desktop is-6-tablet" ]
        [ Html.a [ Route.Path.href pokemonDetailsRoute ]
            [ Html.div [ Attributes.class "card" ]
                [ Html.div [ Attributes.class "card-content" ]
                    [ Html.div [ Attributes.class "media" ]
                        [ Html.div [ Attributes.class "media-left" ]
                            [ Html.figure [ Attributes.class "image is-64x64"]
                                [ Html.img [ Attributes.src pokemonImageUrl, Attributes.alt pokemon.name ] []
                                ]
                            ]
                        , Html.div [ Attributes.class "media-content" ]
                            [ Html.p [ Attributes.class "title is-4" ] [ Html.text pokemon.name ]
                            , Html.p [ Attributes.class "subtitle is-6" ] [ Html.text <| ([ "No. ", String.fromInt pokedexNumber ] |> String.concat) ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
