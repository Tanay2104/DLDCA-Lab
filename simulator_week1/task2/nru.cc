#include <algorithm>
#include <iterator>
#include <map>

#include "cache.h"
#include "util.h"

std::map<CACHE*,std::vector<uint32_t>> nruBits;

void CACHE::initialize_replacement() {
  nruBits[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY);
  for (int i=0; i < NUM_SET * NUM_WAY; i++) {
    nruBits[this][i] = 1;
  }
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
    std::vector<uint32_t> zero_idx;
  for (uint32_t i=0; i < NUM_WAY; i++) {
    if (nruBits[this][set * NUM_WAY + i] == 0) {
        zero_idx.push_back(i);   
    }
  }
  // if all bits are 1, set all to 0
  if (zero_idx.size() == 0) {
    for (uint32_t i =0; i < NUM_WAY; i++) {
        nruBits[this][set* NUM_WAY + i] = 0;
        // And return random
    }
    return rand() % NUM_WAY;
  }
  // Else return random indx from any zero indices
  uint32_t idx = uint32_t(rand() % zero_idx.size());

  return zero_idx[idx];
  assert(false);

}

// called on every cache hit and cache fill
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  if (hit && type == WRITEBACK)  {
    return;
  }

//   uint32_t currVal = lruBits[this][set * NUM_WAY + way];
//   for (uint32_t i=0; i < NUM_WAY; i++) {
//     if (currVal < lruBits[this][set * NUM_WAY + i]) {
//       lruBits[this][set * NUM_WAY + i]--;
//     }
//   }
  nruBits[this][set * NUM_WAY + way] = 1;
    

}

void CACHE::replacement_final_stats() {}
