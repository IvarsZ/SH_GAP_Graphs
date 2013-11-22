queries <- read.table("results3.txt", head = TRUE, sep=" ")

colnames(queries)

p <- 0
zero <-c(0)
d_range <-c(0.01, 0.05, 0.1, 0.5, 1)
c_range <-c(1, 2, 3, 4, 5)

q <- aggregate(queries["time"], by=queries[c("type", "vertexCount", "density")], FUN=mean)

cilLow <- function(x) {
  result <- t.test(x, conf.level = 0.95)$conf.int[1]
  return (result)
}

q.cilLow <- aggregate(queries["time"], by=queries[c("type", "vertexCount", "density")], FUN=cilLow)
q$cilLow = round(q.cilLow$time, 1)

q$absError <- q$time - q$cilLow
q$relError <- round(q$absError / q$time, 1) * 100

q$cilUp <- q$time + q$absError

queries <- q

# Average running time for strongly connected components.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Strongly connected components", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "sc")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for BFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Breadth first search", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "bfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for DFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, us", log="xy", main="Depth first search", pch=p, xlim=c(100, 10000), ylim=c(10, 2000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "dfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for minimum spanning tree.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Minimum spanning tree", pch=p, xlim=c(100, 1000), ylim=c(500000, 50000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "mst")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for shortest paths.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Shortest paths", pch=p, xlim=c(100, 1000), ylim=c(500000, 50000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "sp")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

d_range <-c(0.1, 0.25, 0.5, 1)
c_range <-c(1, 2, 3, 4)

# Average running time for colouring.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", main="Minimal colouring", pch=p, xlim=c(5, 10), ylim=c(10, 40000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "col")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)