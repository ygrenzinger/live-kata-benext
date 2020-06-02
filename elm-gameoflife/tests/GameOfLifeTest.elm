module GameOfLifeTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import GameOfLife exposing (CellState(..), tick)
import Test exposing (..)


suite : Test
suite =
    describe "Game Of Life"
        [ describe "Cell State rules"
            [ test "Any live cell with fewer than two live neighbours dies, as if by underpopulation" <|
                \_ ->
                    List.map (tick ALIVE) [ 0, 1 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            , test "Any live cell with two or three live neighbours lives on to the next generation" <|
                \_ ->
                    List.map (tick ALIVE) [ 2, 3 ] |> List.all ((==) ALIVE) |> Expect.true "should be all alive"
            , test "Any live cell with more than three live neighbours dies, as if by overpopulation." <|
                \_ ->
                    List.map (tick ALIVE) [ 4, 5, 6, 7, 8 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            , test "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." <|
                \_ ->
                    Expect.equal ALIVE (tick DEAD 3)
            , test "Any dead cell without exactly three live neighbours stays dead" <|
                \_ ->
                    List.map (tick DEAD) [ 0, 1, 2, 4, 5, 6, 7, 8 ] |> List.all ((==) DEAD) |> Expect.true "should be all dead"
            ]
        ]
