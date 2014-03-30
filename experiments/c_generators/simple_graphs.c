#include <igraph.h>
#include<iostream>
#include<fstream>
#include <sstream>
#include <vector>

using namespace std;

void print_vector(igraph_vector_t *v, ofstream &outfile) {
  long int i;

  outfile << "[";
  for (i = 0; i < igraph_vector_size(v) - 1; i++) {
    outfile << (long int) (VECTOR(*v)[i] + 1)  << ", ";
  }
  outfile << (long int) (VECTOR(*v)[i] + 1) << "]";
}

void generate_simple_undirected_graphs(void)
{
  int vertexCounts[] = {5, 10};
  int edgesPerVertex[] = {1, 2};
  int times = 2;
  int i;

  igraph_vector_t neighbors;
  igraph_vector_init(&neighbors, 0);
  for (int v = 0; v < sizeof(vertexCounts) / sizeof(vertexCounts[0]); v++) {
    for (int e = 0; e < sizeof(edgesPerVertex) / sizeof(edgesPerVertex[0]); e++) {
      double density = 1.0 * edgesPerVertex[e]/vertexCounts[v];
      if (density < 0) { density = 0; }
      if {density > 1} { break; }
      for (int t = 0; t < times; t++) {

        // Create the graph.
        igraph_t graph;
        igraph_erdos_renyi_game(&graph, IGRAPH_ERDOS_RENYI_GNP, vertexCounts[v], density,
                               IGRAPH_UNDIRECTED, IGRAPH_NO_LOOPS);

        // Print it to a file.
        stringstream ss;
        ss << "./graphs/sug_" <<  vertexCounts[v] << "_" << edgesPerVertex[e] << "_" << t << ".graph";
        ofstream outfile(ss.str().c_str());
        outfile << "vertexCount := " << vertexCounts[v] << ";\n";
        outfile << "edgesPerVertex := " << edgesPerVertex[e] << ";\n";

        outfile << "graph := Graph([";
        
        for (i = 0; i < vertexCounts[v] - 1; i++) {
          igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
          print_vector(&neighbors, outfile);
          outfile << ",\n";
        }
        igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
        print_vector(&neighbors, outfile);
        outfile << "]);\n";
        outfile.close();
        
        igraph_destroy(&graph);
      }
    }
  }
}

void generate_simple_directed_graphs(void)
{
  int vertexCounts[] = {5, 10};
  int edgesPerVertex[] = {1, 2};
  int times = 2;
  int i;

  igraph_vector_t neighbors;
  igraph_vector_init(&neighbors, 0);
  for (int v = 0; v < sizeof(vertexCounts) / sizeof(vertexCounts[0]); v++) {
    for (int e = 0; e < sizeof(edgesPerVertex) / sizeof(edgesPerVertex[0]); e++) {
      double density = 1.0 * edgesPerVertex[e]/vertexCounts[v];
      if (density < 0) { density = 0; }
      if {density > 1} { break; }
      for (int t = 0; t < times; t++) {

        // Create the graph.
        igraph_t graph;
        igraph_erdos_renyi_game(&graph, IGRAPH_ERDOS_RENYI_GNP, vertexCounts[v], density,
                               IGRAPH_DIRECTED, IGRAPH_NO_LOOPS);

        // Print it to a file.
        stringstream ss;
        ss << "./graphs/sdg_" <<  vertexCounts[v] << "_" << edgesPerVertex[e] << "_" << t << ".graph";
        ofstream outfile(ss.str().c_str());
        outfile << "vertexCount := " << vertexCounts[v] << ";\n";
        outfile << "edgesPerVertex := " << edgesPerVertex[e] << ";\n";

        outfile << "graph := Graph([";
        
        for (i = 0; i < vertexCounts[v] - 1; i++) {
          igraph_neighbors(&graph, &neighbors, i, IGRAPH_OUT);
          print_vector(&neighbors, outfile);
          outfile << ",\n";
        }
        igraph_neighbors(&graph, &neighbors, i, IGRAPH_OUT);
        print_vector(&neighbors, outfile);
        outfile << "]);\n";
        outfile.close();
        
        igraph_destroy(&graph);
      }
    }
  }
}

void generate_simple_connected_graphs(void)
{
  igraph_set_error_handler(igraph_error_handler_ignore);

  int max = 1000000;
  int vertexCounts[] = {10, 100, 1000, 10000, 50000, 100000, 500000, max};
  int edgesPerVertex[] = {1, 5, 10, 50, 100, 500, 5000};
  igraph_integer_t times = 20;
  int i;

  int tmp;

  igraph_vector_t neighbors;
  igraph_vector_init(&neighbors, 0);
  igraph_vector_reserve(&neighbors, max);
  igraph_vector_t edges;
  igraph_vector_init(&edges, 0);
  igraph_vector_reserve(&neighbors, max);
  for (int v = 0; v < sizeof(vertexCounts) / sizeof(vertexCounts[0]); v++) {
    for (int e = 0; e < sizeof(edgesPerVertex) / sizeof(edgesPerVertex[0]); e++) {
      double density = 1.0 * edgesPerVertex[e]/vertexCounts[v];
      if (density < 0) { density = 0; }
      if {density > 1} { break; }
      for (int t = 0; t < times; t++) {

        // Create the graph.
        igraph_t graph;

        igraph_erdos_renyi_game(&graph, IGRAPH_ERDOS_RENYI_GNP, vertexCounts[v], density,IGRAPH_UNDIRECTED, IGRAPH_NO_LOOPS); 

        // Connect it.
        igraph_vector_clear(&edges);
        vector<bool> isConnected(vertexCounts[v], false);
        int previous = rand() % vertexCounts[v];
        isConnected[previous] = true;
        int connectedCount = 1;
        while (connectedCount < vertexCounts[v]) {
          int next = rand() % vertexCounts[v];
          if (isConnected[next] == false) {

            // Not already connected.
            if (igraph_get_eid(&graph, &tmp, previous, next, IGRAPH_UNDIRECTED, 1) == IGRAPH_EINVAL &&
                igraph_get_eid(&graph, &tmp, next, previous, IGRAPH_UNDIRECTED, 1) == IGRAPH_EINVAL) {
              igraph_vector_push_back(&edges, previous);
              igraph_vector_push_back(&edges, next);  
            }

            isConnected[next] = true;
            connectedCount++;
            previous = next;
          }
        }
        igraph_add_edges(&graph, &edges, 0);

        // Print it to a file.
        stringstream ss;
        ss << "./graphs/scg_" <<  vertexCounts[v] << "_" << edgesPerVertex[e] << "_" << t << ".graph";
        ofstream outfile(ss.str().c_str());
        outfile << "vertexCount := " << vertexCounts[v] << ";\n";
        outfile << "edgesPerVertex := " << edgesPerVertex[e] << ";\n";

        outfile << "graph := Graph([";
        
        for (i = 0; i < vertexCounts[v] - 1; i++) {
          igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
          print_vector(&neighbors, outfile);
          outfile << ",\n";
        }
        igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
        print_vector(&neighbors, outfile);
        outfile << "]);\n";
        outfile.close();
        
        igraph_destroy(&graph);
      }
    }
  }
}

void generate_simple_connected_weighted_graphs(void)
{
  igraph_set_error_handler(igraph_error_handler_ignore);

  int max = 1000000;
  int vertexCounts[] = {10, 100, 1000, 10000, 50000, 100000, 500000, 1000000};
  int edgesPerVertex[] = {1, 5, 10, 50, 100, 500, 5000};
  igraph_integer_t times = 20;
  int i;

  int tmp;

  igraph_vector_t neighbors;
  igraph_vector_init(&neighbors, 0);
  igraph_vector_reserve(&neighbors, max);

  igraph_vector_t edges;
  igraph_vector_init(&edges, 0);
  igraph_vector_reserve(&edges, max);
  
  igraph_vector_t degrees;
  igraph_vector_init(&degrees, 0);
  igraph_vector_reserve(&degrees, max);

  for (int v = 0; v < sizeof(vertexCounts) / sizeof(vertexCounts[0]); v++) {
    for (int e = 0; e < sizeof(edgesPerVertex) / sizeof(edgesPerVertex[0]); e++) {
      double density = 1.0 * edgesPerVertex[e]/vertexCounts[v];
      if (density < 0) { density = 0; }
      if {density > 1} { break; }
      for (int t = 0; t < times; t++) {

        // Create the graph.
        igraph_t graph;
        igraph_erdos_renyi_game(&graph, IGRAPH_ERDOS_RENYI_GNP, vertexCounts[v], density, IGRAPH_UNDIRECTED, IGRAPH_NO_LOOPS); 

        // Connect it.
        igraph_vector_clear(&edges);
        vector<bool> isConnected(vertexCounts[v], false);
        int previous = rand() % vertexCounts[v];
        isConnected[previous] = true;
        int connectedCount = 1;
        while (connectedCount < vertexCounts[v]) {
          int next = rand() % vertexCounts[v];
          if (isConnected[next] == false) {

            // Not already connected.
            if (igraph_get_eid(&graph, &tmp, previous, next, IGRAPH_UNDIRECTED, 1) == IGRAPH_EINVAL &&
                igraph_get_eid(&graph, &tmp, next, previous, IGRAPH_UNDIRECTED, 1) == IGRAPH_EINVAL) {
              igraph_vector_push_back(&edges, previous);
              igraph_vector_push_back(&edges, next);  
            }

            isConnected[next] = true;
            connectedCount++;
            previous = next;
          }
        }
        igraph_add_edges(&graph, &edges, 0);

        // Print it to a file.
        stringstream ss;
        ss << "./graphs/scwg_" <<  vertexCounts[v] << "_" << edgesPerVertex[e] << "_" << t << ".graph";
        ofstream outfile(ss.str().c_str());
        outfile << "vertexCount := " << vertexCounts[v] << ";\n";
        outfile << "edgesPerVertex := " << edgesPerVertex[e] << ";\n";

        outfile << "graph := WeightedGraph([";
        
        for (i = 0; i < vertexCounts[v] - 1; i++) {
          igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
          print_vector(&neighbors, outfile);
          outfile << ",\n";
        }
        igraph_neighbors(&graph, &neighbors, i, IGRAPH_ALL);
        print_vector(&neighbors, outfile);
        outfile << "],\n";

        // Generate and print weights.
        outfile << "[";
        igraph_degree(&graph, &degrees, igraph_vss_all(), IGRAPH_ALL, IGRAPH_NO_LOOPS);
        for (i = 0; i < vertexCounts[v] - 1; i++) {
          outfile << "[";
          for (int j = 0; j < VECTOR(degrees)[i] - 1; j++) {
              outfile << (rand() % vertexCounts[v] + 1) << ", ";
          }
          outfile << (rand() % vertexCounts[v] + 1) << "],\n";
        }
        outfile << "[";
        for (int j = 0; j < VECTOR(degrees)[i] - 1; j++) {
            outfile << (rand() % vertexCounts[v] + 1)  << ", ";
        }
        outfile << (rand() % vertexCounts[v] + 1)  << "]]);\n";

        outfile.close();
        igraph_destroy(&graph);
      }
    }
  }
}

int main() {
  
  //generate_simple_undirected_graphs();
  //generate_simple_directed_graphs();
  //generate_simple_connected_graphs();
  //generate_simple_connected_weighted_graphs();
  return 0;
}
