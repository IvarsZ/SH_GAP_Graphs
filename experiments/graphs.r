queries <- read.table("scResults.txt", head = TRUE, sep=" ", fill=TRUE)

p <- 0
zero <-c(0)
d_range <-c(0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1)
c_range <-c(1, 2, 3, 4, 5, 6, 7)

q <- aggregate(queries[c("time", "numberOfComponents", "totalDepth")], by=queries[c("type", "vertexCount", "density")], FUN=mean)

cilLow <- function(x) {
  result <- t.test(x, conf.level = 0.95)$conf.int[1]
  return (result)
}

q.cilLow <- aggregate(queries[c("time")], by=queries[c("type", "vertexCount", "density")], FUN=cilLow)
q$cilLow = round(q.cilLow$time, 1)

q$absError <- q$time - q$cilLow
q$relError <- round(q$absError / q$time, 1) * 100

q$cilUp <- q$time + q$absError

queries <- q

# Average running time for strongly connected components.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Strongly connected components", pch=p, xlim=c(100, 10000), ylim=c(10000, 2000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "sc")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average number of components for strongly connected components.
plot(zero, zero, xlab="Number of vertices", ylab="Number of components", log="x", main="Strongly connected components", pch=p, xlim=c(100, 10000), ylim=c(0, 1000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "sc")
  lines(d_set$vertexCount, d_set$numberOfComponents, col=c)
  points(d_set$vertexCount, d_set$numberOfComponents, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for BFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Breadth first search", pch=p, xlim=c(100, 10000), ylim=c(10000, 1000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "bfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average number of components for bfs.
plot(zero, zero, xlab="Number of vertices", ylab="Number of components", log="xy", main="Breadth first search", pch=p, xlim=c(100, 10000), ylim=c(1, 500))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "bfs")
  lines(d_set$vertexCount, d_set$numberOfComponents, col=c)
  points(d_set$vertexCount, d_set$numberOfComponents, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average depth for bfs.
plot(zero, zero, xlab="Number of vertices", ylab="Average depth", log="x", main="Breadth first search", pch=p, xlim=c(100, 10000), ylim=c(0, 12))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "bfs")
  lines(d_set$vertexCount, d_set$totalDepth / d_set$numberOfComponents, col=c)
  points(d_set$vertexCount, d_set$totalDepth / d_set$numberOfComponents, col=c)
}
legend("topright", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average running time for DFS.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Depth first search", pch=p, xlim=c(100, 10000), ylim=c(10000, 1000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "dfs")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)










queries <- read.table("weightResults.txt", head = TRUE, sep=" ", fill=TRUE)

p <- 0
zero <-c(0)
d_range <-c(0.01, 0.05, 0.1, 0.5, 1)
c_range <-c(1, 2, 3, 4, 5)

q <- aggregate(queries[c("time", "minWeight")], by=queries[c("type", "vertexCount", "density")], FUN=mean)

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

# Average weight for minimum spanning tree.
plot(zero, zero, xlab="Number of vertices", ylab="Weight", log="x", main="Minimum spanning tree", pch=p, xlim=c(100, 1000), ylim=c(0, 100000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "mst")
  lines(d_set$vertexCount, d_set$minWeight, col=c)
  points(d_set$vertexCount, d_set$minWeight, col=c)
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









queries <- read.table("colResults.txt", head = TRUE, sep=" ", fill=TRUE)

p <- 0
zero <-c(0)
d_range <-c(0.1, 0.25, 0.5, 0.75, 1)
c_range <-c(1, 2, 3, 4, 5)

q <- aggregate(queries[c("time", "minColors")], by=queries[c("type", "vertexCount", "density")], FUN=mean)

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

# Average running time for colouring.
plot(zero, zero, xlab="Number of vertices", ylab="Time, ns", log="xy", main="Minimal colouring", pch=p, xlim=c(5, 30), ylim=c(1000, 1000000000))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "col")
  lines(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$time, col=c)
  points(d_set$vertexCount, d_set$cilLow, col=c, pch=3)
  points(d_set$vertexCount, d_set$cilUp, col=c, pch=3)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)

# Average number of colors for colouring.
plot(zero, zero, xlab="Number of vertices", ylab="Number of colors", main="Minimal colouring", pch=p, xlim=c(5, 30), ylim=c(1, 30))
for (c in c_range) {
  d_set <- subset(queries, queries$density == d_range[c] & queries$type == "col")
  lines(d_set$vertexCount, d_set$minColors, col=c)
  points(d_set$vertexCount, d_set$minColors, col=c)
}
legend("topleft", title="density", legend=d_range, col=c_range, cex=0.5, pch=1)