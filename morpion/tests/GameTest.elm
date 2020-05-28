module GameTest exposing (..)

import Array exposing (Array)
import Expect exposing (Expectation)
import Fuzz exposing (intRange)
import Game exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "Morpion game"
        [ describe "Grid"
            [ fuzz2 (intRange 0 2) (intRange 0 2) "should update grid with cross because first player" <|
                \x y ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            FirstPlayer

                        updatedGrid =
                            updateGrid player { x = x, y = y } emptyGrid

                        updatedCell =
                            Array.get y updatedGrid
                                |> Maybe.andThen (\row -> Array.get x row)
                    in
                    Expect.equal (Just (Cell { x = x, y = y } Cross)) updatedCell
            , test "should with circle because second player" <|
                \_ ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            SecondPlayer

                        updatedGrid =
                            updateGrid player { x = 1, y = 0 } emptyGrid

                        updatedCell =
                            Array.get 0 updatedGrid
                                |> Maybe.andThen (\row -> Array.get 1 row)
                    in
                    Expect.equal (Just (Cell { x = 1, y = 0 } Circle)) updatedCell
            , test "should switch player" <|
                \_ ->
                    let
                        game =
                            Running FirstPlayer createGrid
                                |> playerTurn { x = 0, y = 1 }

                        player =
                            getPlayer game
                    in
                    Expect.equal SecondPlayer player
            , test "Should not update Game state if player tries to click on a non empty cell" <|
                \_ ->
                    let
                        initGame =
                            Running FirstPlayer createGrid

                        firstPlayerTurn =
                            playerTurn { x = 0, y = 1 } initGame

                        noChange =
                            playerTurn { x = 0, y = 1 } firstPlayerTurn
                    in
                    Expect.equal firstPlayerTurn noChange
            , test "should stop the game when first player win" <|
                \_ ->
                    let
                        game =
                            Running FirstPlayer createGrid
                                |> playerTurn { x = 0, y = 0 }
                                |> playerTurn { x = 1, y = 0 }
                                |> playerTurn { x = 0, y = 1 }
                                |> playerTurn { x = 1, y = 1 }
                                |> playerTurn { x = 0, y = 2 }

                        grid =
                            getGrid game
                    in
                    Expect.equal (Won FirstPlayer grid) game
            ]
        ]
