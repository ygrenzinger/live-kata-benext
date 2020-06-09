module GameOfLifeTest exposing (suite)

import Array exposing (length)
import Expect
import GameOfLife exposing (CellState(..), Grid(..), countAliveNeighbours, fromString, fullGrid, initGrid, killCell, tick, tickCell)
import Set exposing (Set)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Game Of Life"
        [ describe "Cell state rules"
            [ test "Any live cell with fewer than two live neighbours dies, as if by underpopulation" <|
                \_ ->
                    List.map (tickCell ALIVE) [ 0, 1 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            , test "Any live cell with two or three live neighbours lives on to the next generation" <|
                \_ ->
                    List.map (tickCell ALIVE) [ 2, 3 ] |> List.all ((==) ALIVE) |> Expect.true "should be all alive"
            , test "Any live cell with more than three live neighbours dies, as if by overpopulation." <|
                \_ ->
                    List.map (tickCell ALIVE) [ 4, 5, 6, 7, 8 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            , test "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." <|
                \_ ->
                    Expect.equal ALIVE (tickCell DEAD 3)
            , test "Any dead cell without exactly three live neighbours stays dead" <|
                \_ ->
                    List.map (tickCell DEAD) [ 0, 1, 2, 4, 5, 6, 7, 8 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            ]
        , describe "Literate programming"
            [ test "convert empty grid from literate representation" <|
                \_ ->
                    let
                        grid =
                            fromString """
                    000
                    000
                    000
                    """
                    in
                    Expect.equal (initGrid 3 Set.empty) grid
            , test "convert full grid alive from literate representation" <|
                \_ ->
                    let
                        grid =
                            fromString """
                        111
                        111
                        111
                        """
                    in
                    Expect.equal (fullGrid 3) grid
            , test "convert partial grid from literate representation" <|
                \_ ->
                    let
                        grid =
                            fromString """
                        111
                        101
                        101
                        """
                    in
                    Expect.equal (fullGrid 3 |> killCell ( 1, 1 ) |> killCell ( 2, 1 )) grid
            ]
        , describe "Compute alive neighbours"
            [ test "Should return 0 when there is no alive neighbours" <|
                \_ ->
                    let
                        grid =
                            fromString """
                    000
                    000
                    000
                    """
                    in
                    Expect.equal 0 (countAliveNeighbours grid ( 1, 1 ))
            , test "Should return 8 when all neighbours are alive" <|
                \_ ->
                    let
                        grid =
                            fromString """
                        111
                        111
                        111
                        """
                    in
                    Expect.equal 8 (countAliveNeighbours grid ( 1, 1 ))
            ]
        , describe "Patterns"
            [ test "still lifes - block" <|
                \_ ->
                    let
                        grid =
                            fromString """
                        0000
                        0110
                        0110
                        0000
                        """
                    in
                    Expect.equal grid (tick grid)
            , test "Oscillators - blinker" <|
                \_ ->
                    let
                        grid =
                            fromString """
                        010
                        010
                        010
                        """

                        expectedGrid =
                            fromString """
                        000
                        111
                        000
                        """
                    in
                    Expect.equal expectedGrid (tick grid)
            ]
        ]
