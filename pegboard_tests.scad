use <pegboard.scad>

module test_case(test_number, test_name, xoff, yoff)
{
    echo(str("--> test ", test_number, ": ", test_name));

    translate([xoff, yoff, 0])
    let($test = test_number, $test_name = test_name)
    children();

    echo(str("<-- test ", test_number, ": ", test_name));
}

module assert_expect(varname, actual, expected)
{
    assert(expected == actual, str(varname, ": expected ", expected, ", got ", actual));
}

// Hint: use F12 "thrown together" view for tests
module pegboard_test()
{
    // Coarse draft for tests; we don't need quality and we're going
    // to have a LOT of holes.
    $fn = 10;

    // Make sure we have proper is_undef support
    assert(is_undef($undefined));
    
    //=== BASIC FORMS ===

    test_case(1, "default margin, hexpattern", 0, 0)
    {
        pegboard([20, 20, 3], 1, 2, hexpattern=true)
        {
            assert_expect("$test", $test, 1); // Can see $test
            assert($strip_ncols != undef); // Can see $strip_ncols
            assert_expect("$strip_ncols", $strip_ncols, 10);
            assert_expect("$strip_nrows", $strip_nrows, 11);
        }
    };

    test_case(1, "scalar margin, hexpattern", 25, 0)
    {
        pegboard([20, 20, 3], 1, 2, hexpattern=true, margins=4) {
            assert_expect("$strip_ncols", $strip_ncols, 6);
            assert_expect("$strip_nrows", $strip_nrows, 7);
        }
    }

    test_case(1, "vector margin, hexpattern", 50, 0) {
		pegboard([20, 20, 3], 1, 2, true, [2, 4]) {
			assert_expect("$strip_ncols", $strip_ncols, 8);
			assert_expect("$strip_nrows", $strip_nrows, 7);
		}
	}

    test_case(2, "default margin, grid", 0, 25) {
		pegboard([20, 20, 3], 1, 2, false) {
			assert_expect("$strip_ncols", $strip_ncols, 10);
			assert_expect("$strip_nrows", $strip_nrows, 10);
		}
	}

    test_case(3, "scalar margin, grid", 25, 25) {
		pegboard([20, 20, 3], 1, 2, false, 4) {
			assert_expect("$strip_ncols", $strip_ncols, 6);
			assert_expect("$strip_nrows", $strip_nrows, 6);
		}
	}

    test_case(4, "vector margin, grid", 50, 25) {
		pegboard([20, 20, 3], 1, 2, false, [2, 4])
		{
			assert_expect("$strip_ncols", $strip_ncols, 8);
			assert_expect("$strip_nrows", $strip_nrows, 6);
		}
	}

    // === SMALL FORMS ===

    // Should produce 1 row, 1 col, as diameter is 1, margin total is 1,
    // height is 2
    test_case(5, "small 1x1", 0, 50) {
		pegboard([2, 2, 3], 1, 2, false, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 1);
			assert_expect("$strip_nrows", $strip_nrows, 1);
		}
	}

    // With 1 hole, hexpattern doesn't matter so same result
    test_case(6, "small 1x1", 10, 50) {
		pegboard([2, 2, 3], 1, 2, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 1);
			assert_expect("$strip_nrows", $strip_nrows, 1);
		}
	}

    // This should have 4 holes
    test_case(7, "small 2x2", 20, 50) {
		pegboard([4, 4, 3], 1, 2, false, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 2);
			assert_expect("$strip_nrows", $strip_nrows, 2);
		};
	}

    // This should produce 3 holes. The bottom row isn't
    // affected by hexpattern.
    test_case(8, "small 3 holes triangle arrangement", 30, 50) {
		pegboard([4, 4, 3], 1, 2, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 2);
			assert_expect("$strip_nrows", $strip_nrows, 2);
		};
	}

    // === Shallow holes ====

    // Holes in this one only go half way through
    test_case(9, "shallow", 40, 50) {
    	pegboard([2, 2, 3], 1, 2, false, 0.5, 1.5);
	}

    // Centered vs uncentered. Uncentered should have holes
    // cutting through edges. Also tests negative margins.
    test_case(10, "centered", 0, 60) {
    	pegboard([8,8,5], 2, 4, false, 0, center=true);
	}

    test_case(11, "uncentered", 10, 60) {
    	pegboard([8,8,5], 2, 4, false, 0, center=false);
	}

    // Negative margins: Holes will cut through edges
    // to form semicircular cutouts + one hole in center.
    test_case(12, "negative margin, holes intersect edges", 20, 60) {
    	pegboard([8,8,5], 2, 4, false, -2);
	}

    // === TIGHT PACKING ===

    // No hexpattern. Holes should touch, bridge ~= 0
    test_case(13, "pitch=diam, grid, holes touch each other", 30, 60) {
		pegboard([7, 7, 3], 2, 2, false, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 3);
			assert_expect("$strip_nrows", $strip_nrows, 3);
		}
	}

    // With hexpattern the holes should touch too, but not
    // overlap.
    test_case(14, "pitch=diam, hex, holes touch each other", 40, 60) {
		pegboard([7, 7, 3], 2, 2, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 3);
			assert_expect("$strip_nrows", $strip_nrows, 3);
		}
	}

    // Hole bigger than object will force 1 hole
    // which will cut out edges
    test_case(15, "hole bigger than object, 1 hole cuts out edges", 50, 60) {
		pegboard([7, 7, 3], 8, 1, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 1);
			assert_expect("$strip_nrows", $strip_nrows, 1);
		}
	}

    // Holes bigger than pitch will overlap holes.
    test_case(16, "hole bigger than pitch, holes overlap each other", 60, 60) {
		pegboard([20, 7, 3], 6, 5, true, 0.5);
    }


    // === LONG THIN FORMS ===
    test_case(17, "2x30 hex/stagger", 0, 70) {
		pegboard([60, 4, 3], 1, 2, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 30);
			assert_expect("$strip_nrows", $strip_nrows, 2);
		}
	}

    test_case(18, "2x30 grid", 0, 75) {
		pegboard([60, 4, 3], 1, 2, false, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 30);
			assert_expect("$strip_nrows", $strip_nrows, 2);
		}
	}

    // === NEGATIVES ===

    // Pegs shouldn't be longer than needed when making
    // negative forms.
    test_case(19, "negative form pegs", 0, 80) {
		peg_grid([60, 4, 3], 1, 2, true, 0.5) {
			assert_expect("$strip_ncols", $strip_ncols, 30);
			assert_expect("$strip_nrows", $strip_nrows, 2);
		}
	}
}

pegboard_test();
