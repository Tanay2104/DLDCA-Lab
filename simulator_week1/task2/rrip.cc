#include <algorithm>
#include <iterator>
#include <map>

#include "cache.h"
#include "util.h"

std::map<CACHE*,std::vector<uint8_t>> rripBits; // As there is no 3 bit dtype, we use 8 bits

void CACHE::initialize_replacement() {
  rripBits[this] = std::vector<uint8_t>(NUM_SET * NUM_WAY);
  for (int i=0; i < NUM_SET * NUM_WAY; i++) {
    rripBits[this][i] = 0;
  }
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
    std::vector<uint32_t> zero_idx;

    while (true) {
        uint8_t min_rrip = 7;
        for (uint32_t i=0; i < NUM_WAY; i++) {
            if (rripBits[this][set * NUM_WAY + i] == 0) {
                zero_idx.push_back(i);   
            }
            if (rripBits[this][set * NUM_WAY + i] < min_rrip) {
                    min_rrip = rripBits[this][set * NUM_WAY + i];
            }
        }
        if (zero_idx.size() != 0) {
            break;
        }
        for (uint32_t i =0; i < NUM_WAY; i++) {
            rripBits[this][set* NUM_WAY + i] -= min_rrip;
        }
    }
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
  if (hit) {
    rripBits[this][set * NUM_WAY + way] = 7;
  }
  else {
    rripBits[this][set * NUM_WAY + way] = 1;
  }    
}

void CACHE::replacement_final_stats() {}
