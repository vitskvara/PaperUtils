# PaperUtils
Utilities for creating content for LaTex papers with Julia. Implements some utilities for statistical comparison of classifiers as described in [this paper](http://www.jmlr.org/papers/volume7/demsar06a/demsar06a.pdf).

Computation of ranks across datasets:

```julia
using PaperUtils
using DataFrames

perf_df = DataFrame(
	:dataset =>  ["abalone", "haberman", "iris", "yeast"],
	:knn => [0.85, 0.71, 0.98, 0.78],
	:ocsvm => [0.8, 0.68, 0.93, 0.7],
	:if => [0.7, 0.61, 0.93, 0.65]
	)
4×4 DataFrame
│ Row │ dataset  │ knn     │ ocsvm   │ if      │
│     │ String   │ Float64 │ Float64 │ Float64 │
├─────┼──────────┼─────────┼─────────┼─────────┤
│ 1   │ abalone  │ 0.85    │ 0.8     │ 0.7     │
│ 2   │ haberman │ 0.71    │ 0.68    │ 0.61    │
│ 3   │ iris     │ 0.98    │ 0.93    │ 0.93    │
│ 4   │ yeast    │ 0.78    │ 0.7     │ 0.65    │

rank_df = PaperUtils.rankdf(perf_df)
5×4 DataFrame
│ Row │ dataset   │ knn     │ ocsvm   │ if      │
│     │ String    │ Float64 │ Float64 │ Float64 │
├─────┼───────────┼─────────┼─────────┼─────────┤
│ 1   │ abalone   │ 1.0     │ 2.0     │ 3.0     │
│ 2   │ haberman  │ 1.0     │ 2.0     │ 3.0     │
│ 3   │ iris      │ 1.0     │ 2.5     │ 2.5     │
│ 4   │ yeast     │ 1.0     │ 2.0     │ 3.0     │
│ 5   │ mean rank │ 1.0     │ 2.125   │ 2.875   │
```

Friedman test decides whether the performance of models based on mean ranks is the same for all comapred models:

```julia
R = Array(rank_df[end, 2:end])
n = 4
k = 3
α = 0.1
fts = PaperUtils.friedman_test_statistic(R,n,k)
7.125

ftcv = PaperUtils.friedman_critval(α, k)
5.99146454710798
```

Since `fts>fctv`, the difference in ranks is statistically significant and we can continue with the paired Nemenyi test which compares the differences in mean ranks in two models.

```julia
ncd = PaperUtils.nemenyi_cd(k, n, α)
1.451190106751196
```

This means that performance of `knn` and `ocsvm` is statistically speaking the same, but that of `knn` and `if` models is not.

