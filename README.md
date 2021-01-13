# PaperUtils
Utilities for creating content for LaTex papers with Julia. Implements some utilities for statistical comparison of classifiers as described in [this paper](http://www.jmlr.org/papers/volume7/demsar06a/demsar06a.pdf).

Computation of ranks across datasets:

```julia
using PaperUtils
using DataFrames

perf_df = DataFrame(
	:dataset =>  ["abalone", "haberman", "iris", "yeast"],
	:knn => [0.8, 0.71, 0.98, 0.78],
	:ocsvm => [0.86, 0.68, 0.93, 0.7],
	:if => [0.7, 0.61, 0.93, 0.65]
	)
4×4 DataFrame
│ Row │ dataset  │ knn     │ ocsvm   │ if      │
│     │ String   │ Float64 │ Float64 │ Float64 │
├─────┼──────────┼─────────┼─────────┼─────────┤
│ 1   │ abalone  │ 0.8     │ 0.86    │ 0.7     │
│ 2   │ haberman │ 0.71    │ 0.68    │ 0.61    │
│ 3   │ iris     │ 0.98    │ 0.93    │ 0.93    │
│ 4   │ yeast    │ 0.78    │ 0.7     │ 0.65    │

rank_df = PaperUtils.rankdf(perf_df)
5×4 DataFrame
│ Row │ dataset   │ knn     │ ocsvm   │ if      │
│     │ String    │ Float64 │ Float64 │ Float64 │
├─────┼───────────┼─────────┼─────────┼─────────┤
│ 1   │ abalone   │ 2.0     │ 1.0     │ 3.0     │
│ 2   │ haberman  │ 1.0     │ 2.0     │ 3.0     │
│ 3   │ iris      │ 1.0     │ 2.5     │ 2.5     │
│ 4   │ yeast     │ 1.0     │ 2.0     │ 3.0     │
│ 5   │ mean rank │ 1.25    │ 1.875   │ 2.875   │
```

