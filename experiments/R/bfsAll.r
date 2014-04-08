queries <- read.table("../results/bfsAll.res", head = TRUE, sep=" ", fill=TRUE)


# Collect results, calcute mean value for times and errors.
q <- aggregate(queries[c("time")], by=queries[c("type", "vertexCount", "edgesPerVertex", "kFunction", "pCount")], FUN=mean)
q$time <- round(q$time/10^9, 10)

cilLow <- function(x) {
  result <- t.test(x, conf.level = 0.95)$conf.int[1]
  return (result)
}

q.cilLow <- aggregate(queries[c("time")], by=queries[c("type", "vertexCount", "edgesPerVertex", "kFunction", "pCount")], FUN=cilLow)
q$cilLow = round(q.cilLow$time/10^9, 10)

q$absError <- q$time - q$cilLow
q$relError <- round(q$absError / q$time, 1) * 100

q$cilUp <- q$time + q$absError

zero <-c(0)
p <- 0
plot_type_time <- function(k_range, e_range, pC, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(k_range)))
  i_range <-c(seq(1, length(e_range)))
  leg <- numeric(length(k_range) * length(e_range))
  col_range <- (seq(1, length(k_range) * length(e_range)))
  plot(zero, zero, xlab="Number of vertices", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    for (i in i_range) {
      p_set <- subset(q, q$type=="bfsp" & q$kFunction == k_range[c] & q$pCount == pC & q$edgesPerVertex == e_range[i])
      leg[(c-1)*length(e_range) + i] <- c(paste(k_range[c], e_range[i], collapse = ""))
      lines(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$cilLow, col=(c-1)*length(e_range) + i, pch=3)
      points(p_set$vertexCount, p_set$cilUp, col=(c-1)*length(e_range) + i, pch=3)
    }
  }
  legend("topleft", title="bfsp impl.", legend=leg, col=col_range, cex=0.6, pch=1)
}

# UNCOMMENT TO SEE ALL CHARTS <-----------
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 2, "BFSP for 1 edge per vertex with P=2", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 2, "BFSP for 5 edges per vertex with P=2", 100000, 0.000005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 2, "BFSP for 10 edges per vertex with P=2", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 2, "BFSP for 50 edges per vertex with P=2", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 2, "BFSP for 100 edges per vertex with P=2", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 2, "BFSP for 1000 edges per vertex with P=2", 100000, 0.0000005, 40)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 4, "BFSP for 1 edge per vertex with P=4", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 4, "BFSP for 5 edges per vertex with P=4", 100000, 0.000005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 4, "BFSP for 10 edges per vertex with P=4", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 4, "BFSP for 50 edges per vertex with P=4", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 4, "BFSP for 100 edges per vertex with P=4", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 4, "BFSP for 1000 edges per vertex with P=4", 100000, 0.0000005, 40)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 8, "BFSP for 1 edge per vertex with P=8", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 8, "BFSP for 5 edges per vertex with P=8", 100000, 0.000005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 8, "BFSP for 10 edges per vertex with P=8", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 8, "BFSP for 50 edges per vertex with P=8", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 8, "BFSP for 100 edges per vertex with P=8", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 8, "BFSP for 1000 edges per vertex with P=8", 100000, 0.0000005, 40)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 16, "BFSP for 1 edge per vertex with P=16", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 16, "BFSP for 5 edges per vertex with P=16", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 16, "BFSP for 10 edges per vertex with P=16", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 16, "BFSP for 50 edges per vertex with P=16", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 16, "BFSP for 100 edges per vertex with P=16", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 16, "BFSP for 1000 edges per vertex with P=16", 100000, 0.0000005, 40)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 32, "BFSP for 1 edge per vertex with P=32", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 32, "BFSP for 5 edges per vertex with P=32", 100000, 0.000005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 32, "BFSP for 10 edges per vertex with P=32", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 32, "BFSP for 50 edges per vertex with P=32", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 32, "BFSP for 100 edges per vertex with P=32", 100000, 0.0000005, 40)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 32, "BFSP for 1000 edges per vertex with P=32", 100000, 0.0000005, 40)

plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 32, "BFSP for 10 edges per vertex with P=32", 100000, 0.0002, 15)

queries$totalEdges <- queries$vertexCount*queries$edgesPerVertex

# Collect results, calcute mean value for times and errors.
q <- aggregate(queries[c("time")], by=queries[c("type", "totalEdges", "kFunction", "pCount")], FUN=mean)
q$time <- round(q$time/10^9, 10)

cilLow <- function(x) {
  result <- t.test(x, conf.level = 0.95)$conf.int[1]
  return (result)
}

q.cilLow <- aggregate(queries[c("time")], by=queries[c("type", "totalEdges", "kFunction", "pCount")], FUN=cilLow)
q$cilLow = round(q.cilLow$time/10^9, 10)

q$absError <- q$time - q$cilLow
q$relError <- round(q$absError / q$time, 1) * 100

q$cilUp <- q$time + q$absError

zero <-c(0)
p <- 0
plot_type_time <- function(k_range, pC, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(k_range)))
  print(c_range)
  plot(zero, zero, xlab="Average number of edges", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    p_set <- subset(q, q$type=="bfsp" & q$kFunction == k_range[c] & q$pCount == pC)
    print(p_set)
    lines(p_set$totalEdges, p_set$time, col=c)
    points(p_set$totalEdges, p_set$time, col=c)
  }
  legend("topleft", title="bfsp impl.", legend=k_range, col=c_range, cex=0.6, pch=1)
}

plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 2, "BFSP 2 processors", 100000000, 0.0001, 500)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 4, "BFSP 4 processors", 100000000, 0.0001, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 8, "BFSP 8 processors", 100000000, 0.0003, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 16, "BFSP 16 processors", 100000000, 0.0003, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 32, "BFSP 32 processors", 100000000, 0.0005, 12)

zero <-c(0)
p <- 0
plot_type_time <- function(k, e_range, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(e_range)))
  print(c_range)
  plot(zero, zero, xlab="Number of processors", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(0.8, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    p_set <- subset(q, q$type=="bfsp" & q$kFunction == k & q$totalEdges == e_range[c])
    lines(p_set$pCount, p_set$time, col=c)
    points(p_set$pCount, p_set$time, col=c)
  }
  legend("bottomright", title="Average number of edges", legend=e_range, col=c_range, cex=0.5, pch=1)
}

plot_type_time(c("square"), c(10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 10000000, 100000000, 1000000000), "BFSP square implementation", 32, 0.0001, 15)

zero <-c(0)
p <- 0
plot_type_time <- function(kF, p_range, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(p_range)))
  print(c_range)
  plot(zero, zero, xlab="Average number of edges", log="xy", ylab="Time, s", pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    p_set <- subset(q, q$type=="bfsp" & q$kFunction == kF & q$pCount == p_range[c])
    lines(p_set$totalEdges, p_set$time, col=c, lwd = 3)
    points(p_set$totalEdges, p_set$time, col=c, bg=c, pch=21)
  }
}
plot_type_time("square", c(1, 2, 4, 8, 16, 32), "Serial vs Parallel", 1000000000, 0.000002, 15)

p_set <- subset(q, q$type=="bfs")
lines(p_set$totalEdges, p_set$time, col=7, lwd = 3)
points(p_set$totalEdges, p_set$time, col=7, bg=7, pch=21)

legend("topleft", legend=c("Parallel with P=1", "Parallel with P=2", "Parallel with P=4", "Parallel with P=8", "Parallel with P=16", "Parallel with P=32", "Serial"), col=c(seq(1, 7)), cex=0.6, pch=21, pt.bg=c(seq(1, 7)))