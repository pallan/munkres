require 'minitest/autorun'
require_relative '../lib/munkres'

class EmptyMunkresTest < Minitest::Test
  def setup
    @saved_protected_instance_methods = Munkres.protected_instance_methods
    x = @saved_protected_instance_methods
    Munkres.class_eval { public *x }
    @m = Munkres.new [[0]]
  end

  def teardown
    x = @saved_protected_instance_methods
    Munkres.class_eval { protected *x }
  end

  def test_tracks_matrix_of_values
    assert_equal [[0]], @m.matrix
  end

  def test_tracks_covered_columns
    assert_equal [], @m.covered_columns
  end

  def test_tracks_covered_rows
    assert_equal [], @m.covered_rows
  end

  def test_tracks_starred_zeros
    assert_equal [], @m.starred_zeros
  end

  def test_tracks_primed_zeros
    assert_equal [], @m.primed_zeros
  end
end

class MunkresSolvingTest < Minitest::Test
  def setup
    @saved_protected_instance_methods = Munkres.protected_instance_methods
    x = @saved_protected_instance_methods
    Munkres.class_eval { public *x }
    @m = Munkres.new [[1,2,3],[2,4,6],[3,6,9]]
  end

  def teardown
    x = @saved_protected_instance_methods
    Munkres.class_eval { protected *x }
  end

  def test_create_zero_in_rows
    @m.create_zero_in_rows
    assert_equal [[0,1,2],[0,2,4],[0,3,6]], @m.matrix
  end

  def test_retrieve_any_row
    assert_equal [3,6,9], @m.matrix.row(2)
  end

  def test_retrieve_any_column
    assert_equal [2,4,6], @m.matrix.column(1)
  end

  def test_min_or_zero
    assert_equal 0, @m.min_or_zero([3,0,2,1])
  end

  def test_star_zeros_stars_first_zero
    @m.create_zero_in_rows
    @m.star_zeros
    assert_equal [[0,0]], @m.starred_zeros
  end

  def test_star_in_column
    @m.starred_zeros << [0,0]
    assert @m.star_in_column?(0)
    refute @m.star_in_column?(1)
  end

  def test_star_in_row
    @m.starred_zeros << [0,1]
    assert @m.star_in_row?(0)
    refute @m.star_in_row?(1)
  end

  def test_cover_columns_with_stars_covers_first_column
    @m.create_zero_in_rows
    @m.star_zeros
    @m.cover_columns_with_stars
    assert_equal [0], @m.covered_columns
  end

  def test_done_when_all_columns_covered
    refute @m.done?
    @m.covered_columns = [0,1,2]
    assert @m.done?
  end

  def test_prime_first_uncovered_zero
    @m.matrix[0][1] = 0
    @m.matrix[1][1] = 0
    assert_equal [0,1], @m.prime_first_uncovered_zero
    assert_equal [[0,1]], @m.primed_zeros
  end

  def test_smallest_uncovered_value
    @m.covered_columns = [0,1]
    @m.covered_rows = [0]
    assert_equal 6, @m.smallest_uncovered_value
  end

  def test_add_and_subtract_for_step_6
    @m.covered_columns = [1]
    @m.covered_rows = [0,2]
    @m.add_and_subtract_for_step_6(2)
    assert_equal [[1,4,3],[0,4,4],[3,8,9]], @m.matrix
  end

  def test_find_better_stars
    @m.matrix = [[0,0,1],[0,1,3],[0,2,5]]
    @m.covered_rows = [0]
    @m.starred_zeros = [[0,0]]
    @m.primed_zeros = [[0,1], [1,0]]
    @m.find_better_stars [1,0]
    [[0,1], [1,0]].each { |star| assert_includes @m.starred_zeros, star }
    assert_empty @m.primed_zeros
    assert_empty @m.covered_rows
    assert_empty @m.covered_columns
  end

  def test_returns_optimal_pairings
    assert_equal [[0,2],[1,1],[2,0]].sort, @m.find_pairings.sort
  end
end

class OddlyShapedMunkresTest < Minitest::Test
  def setup
    @saved_protected_instance_methods = Munkres.protected_instance_methods
    x = @saved_protected_instance_methods
    Munkres.class_eval { public *x }
  end

  def teardown
    x = @saved_protected_instance_methods
    Munkres.class_eval { protected *x }
  end

  def test_zero_pads_tall_skinny_matrix
    m = Munkres.new [[1,2],[2,4],[3,6]]
    assert_equal [[1,2,0],[2,4,0],[3,6,0]], m.matrix
  end

  def test_raises_for_wide_input
    assert_raises(ArgumentError) { Munkres.new [[1,2,3],[4,5,6]] }
  end

  def test_raises_for_irregular_input
    assert_raises(ArgumentError) { Munkres.new [[1,2],[1,2,3]] }
  end

  def test_raises_for_empty_matrix
    assert_raises(ArgumentError) { Munkres.new [] }
  end

  def test_raises_for_empty_row
    assert_raises(ArgumentError) { Munkres.new [[],[]] }
  end
end

class ComplexMunkresExamplesTest < Minitest::Test
  def test_solves_first_example
    optimal_pairings = [[0,5],[1,1],[2,2],[3,3],[4,4],[5,0]]
    m = Munkres.new [[3,4,5,6,2,1],[3,0,1,2,3,4],[7,6,0,2,1,1],[4,4,5,0,1,2],[0,1,0,1,0,0],[0,3,2,2,2,0]]
    assert_equal optimal_pairings.sort, m.find_pairings.sort
  end

  def test_solves_larger_example
    m = Munkres.new [[4,1,2,3],
                     [6,9,2,4],
                     [1,0,3,7],
                     [10,4,6,6]]
    m.find_pairings
    assert_equal 10, m.total_cost_of_pairing
  end

  def test_solves_non_square_example
    optimal_pairings = [[[0,3],[1,2],[2,1],[5,0]],
                        [[0,1],[1,2],[2,0],[5,3]]]
    m = Munkres.new [[4,1,2,3],
                     [6,9,2,4],
                     [1,0,3,7],
                     [10,4,6,6],
                     [5,7,5,9],
                     [2,2,14,3]]
    assert_includes optimal_pairings.sort, m.find_pairings.sort
    assert_equal 7, m.total_cost_of_pairing
  end

  def test_solves_very_large_example
    arr = Array.new(100) { Array.new(100) { rand 20 } }
    m = Munkres.new arr
    m.find_pairings
  end
end
