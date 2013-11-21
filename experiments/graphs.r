queries <- read.table("results3.txt", head = TRUE, sep=" ")

colnames(queries)

p <- 0
zero <-c(0)
d_range <-c(0.01, 0.05, 0.1, 0.5, 1)
c_range <-c(1, 2, 3, 4, 5)

queries <- aggregate(queries["time"], by=queries[c("type", "vertexCount", "density")], FUN=mean)

# Average running time for strongly connected components.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Strongly connected components", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "sc")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for BFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Breadth first search", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "bfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for DFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Depth first search", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "dfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)