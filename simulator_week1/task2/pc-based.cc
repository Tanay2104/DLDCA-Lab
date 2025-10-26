#include <algorithm>
#include <iterator>
#include <map>
#include <limits>

#include "cache.h"
#include "util.h"

std::map<CACHE*,std::vector<uint16_t>> pc_table; // This table contains the pc value for all cache block
std::map<CACHE*, std::map<uint16_t, uint8_t>> pc_counter; // Map from pc to it's counter value
void CACHE::initialize_replacement() {
  pc_table[this] = std::vector<uint16_t>(NUM_SET * NUM_WAY);
  for (unsigned int i=0; i < NUM_SET * NUM_WAY; i++) {
    pc_table[this][i] = 0; // Initially no PC for any cache block
  }
  // for (uint16_t i=0; i < std::numeric_limits<uint16_t>; i++) {
  //   pc_counter[this][i] = 0; // Intialise the counter to zero for every lower 16 bits of PC
  // }
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
    uint16_t min_pc = std::numeric_limits<uint16_t>::max();
    uint32_t min_idx = 0;
    for (uint32_t i=0; i < NUM_WAY; i++) {
        if (pc_counter[this][pc_table[this][set * NUM_WAY + i]] <= min_pc) {
          // pc_table[this][...] returs an entry from the uint_16 vector, which refers to the lower 16 bits of the PC
          // Therefore we index that into our pc_counter to find it's counter value; 
            min_pc = pc_counter[this][pc_table[this][set * NUM_WAY + i]];
            min_idx = i;
        }
    }
    return min_idx;
    assert(false);

}

// called on every cache hit and cache fill
void CACHE::update_replacement_state(uint32_t cpu, uint32_t set, uint32_t way, uint64_t full_addr, uint64_t ip, uint64_t victim_addr, uint32_t type,
                                     uint8_t hit)
{
  if (hit && type == WRITEBACK)  {
    return;
  }
  // uint16_t lower_ip = (ip | (0x1111111111110000)) ^ (0x1111111111110000);
  uint16_t lower_ip = ip & (0x000000000000FFFF);
  if (hit) {
    if (pc_counter[this][lower_ip] < 255 - 1) pc_counter[this][lower_ip]++;
  }
  else {
    pc_table[this][set * NUM_WAY + way] = lower_ip;
    if (pc_counter[this][lower_ip] > 0) pc_counter[this][lower_ip]--;
  }

}

void CACHE::replacement_final_stats() {}
