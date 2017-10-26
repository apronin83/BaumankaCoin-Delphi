#include "./getblocks.hpp"

#include <cassert>
#include <exception>

#include <botan/hex.h>

using namespace ad_patres::messages;

payload_t&
ad_patres::operator<<(payload_t& payload, const getblocks& obj)
{
  for (const auto& byte : obj.hash)
    payload.push_back(byte);

  return payload;
}

std::istream&
ad_patres::operator>>(std::istream& is, getblocks& obj)
{
  char ha[32];
  obj.hash = hash_t(32);
  assert(obj.hash.size() == 32);
  is.read(reinterpret_cast<char*>(ha), 32);
  for (size_t i = 0; i < 32; ++i)
    obj.hash[i] = ha[i];

  return is;
}
