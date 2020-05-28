module GameTest exposing (..)

import Array
import Expect
import Fuzz exposing (intRange)
import Game exposing (Cell, CellState(..), Game(..), Player(..), createGrid, getGrid, getPlayer, selectCell, updateGrid)
import Test exposing (Test, describe, fuzz2, test)


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
                                |> selectCell { x = 0, y = 1 }

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
                            selectCell { x = 0, y = 1 } initGame

                        noChange =
                            selectCell { x = 0, y = 1 } firstPlayerTurn
                    in
                    Expect.equal firstPlayerTurn noChange
            , test "should stop the game when first player win" <|
                \_ ->
                    let
                        game =
                            Running FirstPlayer createGrid
                                |> selectCell { x = 0, y = 0 }
                                |> selectCell { x = 1, y = 0 }
                                |> selectCell { x = 0, y = 1 }
                                |> selectCell { x = 1, y = 1 }
                                |> selectCell { x = 0, y = 2 }

                        grid =
                            getGrid game
                    in
                    Expect.equal (Won FirstPlayer grid) game
            ]
        ]
