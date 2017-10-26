#include "./version.hpp"

#include <ctime>

using namespace ad_patres::messages;
using namespace boost::asio::ip;

version::version(tcp::endpoint endp, uint16_t port)
: addr_recv{endp.address().to_v4().to_bytes(),
            static_cast<uint16_t>(endp.port())}
{
  std::srand(std::time(0));
  nonce = static_cast<uint64_t>(std::rand());
  addr_from.ip = {0x7f, 0x00, 0x00, 0x01};
  addr_from.port = port;
}

payload_t&
ad_patres::operator<<(payload_t& payload, const version& obj)
{
  payload << obj.addr_recv << obj.addr_from;
  for (auto byte : itobl(obj.nonce))
    payload.push_back(byte);
  return payload;
}

std::istream&
ad_patres::operator>>(std::istream& is, version& obj)
{
  is >> obj.addr_recv >> obj.addr_from;
  is.read(reinterpret_cast<char*>(&obj.nonce), sizeof(obj.nonce));
  return is;
}

payload_t&
ad_patres::operator<<(payload_t& payload, const verack& obj)
{
  return payload;
}

std::istream&
ad_patres::operator>>(std::istream& is, verack& obj)
{
  return is;
}
