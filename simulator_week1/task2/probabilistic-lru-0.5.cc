#include <algorithm>
#include <iterator>
#include <map>

#include "cache.h"
#include "util.h"

std::map<CACHE*,std::vector<uint32_t>> plruBits;

void CACHE::initialize_replacement() {
  plruBits[this] = std::vector<uint32_t>(NUM_SET * NUM_WAY);
  for (int i=0; i < NUM_SET * NUM_WAY; i++) {
    plruBits[this][i] = 0;
  }
}

// find replacement victim
uint32_t CACHE::find_victim(uint32_t cpu, uint64_t instr_id, uint32_t set, const BLOCK* current_set, uint64_t ip, uint64_t full_addr, uint32_t type)
{
  for (uint32_t i=0; i < NUM_WAY; i++) {
    if (plruBits[this][set * NUM_WAY + i] == 0) {
      return i;
    }
  }
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
    uint32_t currVal = plruBits[this][set * NUM_WAY + way];
    for (uint32_t i=0; i < NUM_WAY; i++) {
        if (currVal < plruBits[this][set * NUM_WAY + i]) {
        plruBits[this][set * NUM_WAY + i]--;
        }
    }
    plruBits[this][set * NUM_WAY + way] = NUM_WAY - 1;
  }
  else {
    if (double(rand() % 100) / 100 < 0.5) {
    plruBits[this][set*NUM_WAY + way] = 0;
  }
  else {
    uint32_t currVal = plruBits[this][set * NUM_WAY + way];
    for (uint32_t i=0; i < NUM_WAY; i++) {
        if (currVal < plruBits[this][set * NUM_WAY + i]) {
        plruBits[this][set * NUM_WAY + i]--;
        }
    }
    plruBits[this][set * NUM_WAY + way] = NUM_WAY - 1;
  }
}
}

void CACHE::replacement_final_stats() {}
