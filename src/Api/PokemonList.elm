module Api.PokemonList exposing (getFirst150)

import Http
import Json.Decode as Decoder


type alias Pokemon =
    { name : String
    }


getFirst150 :
    { onResponse : Result Http.Error (List Pokemon) -> msg
    }
    -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse decoder
        }


decoder : Decoder.Decoder (List Pokemon)
decoder =
    Decoder.field "results" (Decoder.list pokemonDecoder)


pokemonDecoder : Decoder.Decoder Pokemon
pokemonDecoder =
    Decoder.map Pokemon
        (Decoder.field "name" Decoder.string)
