// heat_simulation_bad.cpp
// Intentionally unoptimized 2D heat diffusion simulation
// Compile: g++ -O0 -march=native -std=c++17 -o heat_sim_bad heat_simulation_bad.cpp
// Run: ./heat_sim_bad [N] [STEPS] [OUTFILE], e.g. ./heat_sim_bad 512 200 output.csv

#include <bits/stdc++.h>
using namespace std;

#define IDX(i, j, N) ((i) * (N) + (j))

int main(int argc, char** argv) {
    size_t N = (argc > 1) ? stoul(argv[1]) : 256;   // grid size
    size_t STEPS = (argc > 2) ? stoul(argv[2]) : 100;
    string out_file = (argc > 3) ? argv[3] : "final_grid.csv";

    // allocate aligned memory
    double* grid = static_cast<double*>(malloc( N * N * sizeof(double)));
    double* new_grid = static_cast<double*>(malloc(N * N * sizeof(double)));
    if (!grid || !new_grid) {
        cerr << "Allocation failed!\n";
        return 1;
    }

    // initialize grid with random values between 0 and 1
    mt19937 rng(42);
    uniform_real_distribution<double> dist(0.0, 1.0);
    for (size_t i = 0; i < N * N; ++i)
        grid[i] = dist(rng);

    // random "hot spots"
    size_t hot_spots = max<size_t>(1, N / 8);
    vector<pair<size_t, size_t>> hot_indices;
    for (size_t k = 0; k < hot_spots; ++k)
        hot_indices.emplace_back(rng() % N, rng() % N);

    cout << "Running heat simulation on " << N << "x" << N << " grid for "
         << STEPS << " steps...\n";

    double total = 0.0;

    // Main simulation
    for (size_t t = 0; t < STEPS; ++t) {
        for (size_t j = 1; j < N - 1; j+=2) {
            for (size_t i = 1; i < N - 1; i+=2) {
                size_t iplus1 = i+1; 
                size_t jplus1 = j+1;
                new_grid[IDX(i, j, N)] = 0.25 * (
                    grid[IDX(i-1, j, N)] +
                    grid[IDX(iplus1, j, N)] +
                    grid[IDX(i, j-1, N)] +
                    grid[IDX(i, jplus1, N)]
                    );
                // for i+1, j
                new_grid[IDX(iplus1, j, N)] = 0.25 * (
                    grid[IDX(i, j, N)] +
                    grid[IDX(i+2, j, N)] +
                    grid[IDX(iplus1, j-1, N)] +
                    grid[IDX(iplus1, jplus1, N)]
                    );
                // for i, j+1
                new_grid[IDX(i, jplus1, N)] = 0.25 * (
                    grid[IDX(i-1, jplus1, N)] +
                    grid[IDX(iplus1, jplus1, N)] +
                    grid[IDX(i, j, N)] +
                    grid[IDX(i, j+2, N)]
                    );
                // for i+1, j+1
                new_grid[IDX(iplus1, jplus1, N)] = 0.25 * (
                    grid[IDX(i, jplus1, N)] +
                    grid[IDX(i+2, jplus1, N)] +
                    grid[IDX(iplus1, j, N)] +
                    grid[IDX(iplus1, j+2, N)]
                    );
                
            }
        }
        for (auto pair: hot_indices) {
            new_grid[IDX(pair.first, pair.second, N)] += 0.01;
        }
        // Instead of swapping, do new_grid <- grid on even iterations and grid <- new_grid on odd iterations
        // Instead of explicitly finding each hot index efor each i, j pair, just increment the hot indicies after each time step
        
        swap(grid, new_grid);

        if (t % 10 == 0) {
            for (size_t i = 0; i < N * N; i += 1024)
                total += grid[i];
            cout << "Step " << t << " checksum: " << total << "\n";
        }
    }

    cout << "Simulation complete. Final checksum: " << total << "\n";

    ofstream fout(out_file);
    if (!fout) {
        cerr << "Failed to open output file.\n";
        return 1;
    }
    for (size_t i = 0; i < N; ++i) {
        for (size_t j = 0; j < N; ++j) {
            fout << grid[IDX(i, j, N)];
            if (j + 1 != N) fout << ",";
        }
        fout << "\n";
    }
    fout.close();

    cout << "Final grid written to: " << out_file << "\n";

    free(grid);
    free(new_grid);
    return 0;
}