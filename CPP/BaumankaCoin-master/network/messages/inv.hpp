#pragma once

#ifndef INV_H
#define INV_H

#include "./message.hpp"

#include <cstdlib>
#include <vector>

namespace ad_patres
{
  namespace messages
  {
    struct inv_vect
    {
      enum class inv_type
      {
        error = 0,
        msg_tx = 1,
        msg_block = 2,
      } type;
      hash_t hash;
    };

    hash_t
    hash_from_32(const uint32_t value);

    uint32_t
    hash_to_32(const hash_t& hash);

    struct inv
    {
      std::vector<inv_vect> inventory;
      const char command[command_size] = "inv";
    };

    struct getdata
    {
      std::vector<inv_vect> inventory;
      const char command[command_size] = "getdata";
    };
  } // namespace messages

  messages::payload_t&
  operator<<(messages::payload_t&, const messages::inv_vect&);

  std::istream&
  operator>>(std::istream&, messages::inv_vect&);

  messages::payload_t&
  operator<<(messages::payload_t&, const messages::inv&);

  std::istream&
  operator>>(std::istream&, messages::inv&);

  messages::payload_t&
  operator<<(messages::payload_t&, const messages::getdata&);

  std::istream&
  operator>>(std::istream&, messages::getdata&);
} // namespace ad_patres
#endif // INV_H
