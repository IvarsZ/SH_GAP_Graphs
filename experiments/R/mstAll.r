queries <- read.table("../results/mstAll.res", head = TRUE, sep=" ", fill=TRUE)

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
plot_type_time <- function(t_range, e_range, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(t_range)))
  i_range <-c(seq(1, length(e_range)))
  leg <- numeric(length(t_range) * length(e_range))
  col_range <- (seq(1, length(t_range) * length(e_range)))
  plot(zero, zero, xlab="Number of vertices", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    for (i in i_range) {
      p_set <- subset(q, q$type == t_range[c] & q$edgesPerVertex == e_range[i])
      leg[(c-1)*length(e_range) + i] <- c(paste(t_range[c], e_range[i], collapse = "") )
      lines(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$cilLow, col=(c-1)*length(e_range) + i, pch=3)
      points(p_set$vertexCount, p_set$cilUp, col=(c-1)*length(e_range) + i, pch=3)
    }
  }
  legend("topleft", title="impl.", legend=leg, col=col_range, cex=0.6, pch=1)
}

# Plot different serial mst implementations.
plot_type_time(c('mst', 'mstPrims'), c(1),  "Boruvka vs Prims for 1 edge per vertex", 100000, 10^-5, 0.03)
plot_type_time(c('mst', 'mstPrims'), c(5),  "Boruvka vs Prims for 5 edges per vertex", 100000, 10^-5, 0.03)
plot_type_time(c('mst', 'mstPrims'), c(10),  "Boruvka vs Prims for 10 edges per vertex", 100000, 10^-5, 0.03)
plot_type_time(c('mst', 'mstPrims'), c(50),  "Boruvka vs Prims for 50 edges per vertex", 100000, 10^-5, 0.1)
plot_type_time(c('mst', 'mstPrims'), c(100),  "Boruvka vs Prims for 100 edges per vertex", 100000, 0.0002, 0.1)
plot_type_time(c('mst', 'mstPrims'), c(1000),  "Boruvka vs Prims for 1000 edges per vertex", 100000, 0.01, 0.4)

plot_type_time <- function(k_range, e_range, pC, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(k_range)))
  i_range <-c(seq(1, length(e_range)))
  leg <- numeric(length(k_range) * length(e_range))
  col_range <- (seq(1, length(k_range) * length(e_range)))
  plot(zero, zero, xlab="Number of vertices", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    for (i in i_range) {
      p_set <- subset(q, q$type=="mstp" & q$kFunction == k_range[c] & q$pCount == pC & q$edgesPerVertex == e_range[i])
      leg[(c-1)*length(e_range) + i] <- c(paste(k_range[c], e_range[i], collapse = ""))
      lines(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$time, col=(c-1)*length(e_range) + i)
      points(p_set$vertexCount, p_set$cilLow, col=(c-1)*length(e_range) + i, pch=3)
      points(p_set$vertexCount, p_set$cilUp, col=(c-1)*length(e_range) + i, pch=3)
    }
  }
  legend("topleft", title="mstp impl.", legend=leg, col=col_range, cex=0.6, pch=1)
}


#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 1, "Mstp for 1 edge per vertex with P=1", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 1, "Mstp for 5 edges per vertex with P=1", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 1, "Mstp for 10 edges per vertex with P=1", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 1, "Mstp for 50 edges per vertex with P=1", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 1, "Mstp for 100 edges per vertex with P=1", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 1, "Mstp for 1000 edges per vertex with P=1", 10000, 0.0004, 3)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 2, "Mstp for 1 edge per vertex with P=2", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 2, "Mstp for 5 edges per vertex with P=2", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 2, "Mstp for 10 edges per vertex with P=2", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 2, "Mstp for 50 edges per vertex with P=2", 10000, 0.004, 10)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 2, "Mstp for 100 edges per vertex with P=2", 10000, 0.004, 10)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 2, "Mstp for 1000 edges per vertex with P=2", 10000, 0.004, 10)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 4, "Mstp for 1 edge per vertex with P=4", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 4, "Mstp for 5 edges per vertex with P=4", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 4, "Mstp for 10 edges per vertex with P=4", 10000, 0.0005, 4)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 4, "Mstp for 50 edges per vertex with P=4", 10000, 0.004, 10)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 4, "Mstp for 100 edges per vertex with P=4", 10000, 0.004, 10)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 4, "Mstp for 1000 edges per vertex with P=4", 10000, 0.004, 10)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 8, "Mstp for 1 edge per vertex with P=8", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 8, "Mstp for 5 edges per vertex with P=8", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 8, "Mstp for 10 edges per vertex with P=8", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 8, "Mstp for 50 edges per vertex with P=8", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 8, "Mstp for 100 edges per vertex with P=8", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 8, "Mstp for 1000 edges per vertex with P=8", 10000, 0.0004, 3)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 16, "Mstp for 1 edge per vertex with P=16", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 16, "Mstp for 5 edges per vertex with P=16", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 16, "MSTP for 10 edges per vertex with P=16", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 16, "Mstp for 50 edges per vertex with P=16", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 16, "Mstp for 100 edges per vertex with P=16", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 16, "Mstp for 1000 edges per vertex with P=16", 10000, 0.0004, 3)

#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1), 32, "Mstp for 1 edge per vertex with P=32", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(5), 32, "Mstp for 5 edges per vertex with P=32", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 32, "Mstp for 10 edges per vertex with P=32", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(50), 32, "Mstp for 50 edges per vertex with P=32", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(100), 32, "Mstp for 100 edges per vertex with P=32", 10000, 0.0004, 3)
#plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(1000), 32, "Mstp for 1000 edges per vertex with P=32", 10000, 0.0004, 3)

plot_type_time(c('single', 'double', "tenTimes", "square", "one"), c(10), 16, "MSTP for 10 edges per vertex with P=16", 10000, 0.0004, 1)

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
    p_set <- subset(q, q$type=="mstp" & q$kFunction == k_range[c] & q$pCount == pC)
    lines(p_set$totalEdges, p_set$time, col=c)
    points(p_set$totalEdges, p_set$time, col=c)
  }
  legend("topleft", title="mstp impl.", legend=k_range, col=c_range, cex=0.6, pch=1)
}

plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 1, "MSTP 1 processor", 100000000, 0.0005, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 2, "MSTP 2 processors", 100000000, 0.0005, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 4, "MSTP 4 processors", 100000000, 0.0005, 8)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 8, "MSTP 8 processors", 100000000, 0.0005, 4)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 16, "MSTP 16 processors", 100000000, 0.0005, 2)
plot_type_time(c('single', 'double', "tenTimes", "square", "one"), 32, "MSTP 32 processors", 100000000, 0.0005, 2)

zero <-c(0)
p <- 0
plot_type_time <- function(k, e_range, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(e_range)))
  print(c_range)
  plot(zero, zero, xlab="Number of processors", log="xy", ylab="Time, s", main=name, pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    p_set <- subset(q, q$type=="mstp" & q$kFunction == k & q$totalEdges == e_range[c])
    lines(p_set$pCount, p_set$time, col=c)
    points(p_set$pCount, p_set$time, col=c,  bg=c, pch=21)
  }
  legend(40, 100, title="Avg. no. edges", legend=e_range, col=c_range, cex=1, pch=21, pt.bg = c(seq(1, 8)))
}

par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
plot_type_time(c("double"), c(10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 10000000), "", 32, 0.0005, 150)

par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
zero <-c(0)
p <- 0
plot_type_time <- function(kF, p_range, name, x_max, y_min, y_max) {
  
  c_range <-c(seq(1, length(p_range)))
  print(c_range)
  plot(zero, zero, xlab="Average number of edges", log="xy", ylab="Time, s", pch=p, xlim=c(1, x_max), ylim=c(y_min, y_max))
  for (c in c_range) {
    p_set <- subset(q, q$type=="mstp" & q$kFunction == kF & q$pCount == p_range[c])
    lines(p_set$totalEdges, p_set$time, col=c, lwd = 3)
    points(p_set$totalEdges, p_set$time, col=c, bg=c, pch=21)
  }
}
plot_type_time("double", c(1, 2, 4, 8, 16, 32), "Serial vs Parallel", 10000000, 0.00001, 10)

p_set <- subset(q, q$type=="mst")
lines(p_set$totalEdges, p_set$time, col=7, lwd = 3)
points(p_set$totalEdges, p_set$time, col=7, bg = 7, pch = 21)

p_set <- subset(q, q$type=="mstPrims")
lines(p_set$totalEdges, p_set$time, col=8, lwd = 3)
points(p_set$totalEdges, p_set$time, col=8, bg = 8, pch = 21)

par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
legend("bottomright", inset=c(-0.3,0), title="impl", legend=c("Parallel with P=1", "Parallel with P=2", "Parallel with P=4", "Parallel with P=8", "Parallel with P=16", "Parallel with P=32", "Boruvka", "Prim's"), col=c(seq(1, 8)), pt.bg = c(seq(1, 8)), pch = 21, cex=1.05)