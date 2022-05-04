#ifndef RES_EMBED_H
#define RES_EMBED_H

#include <map>
#include <memory>
#include <string>
#include <vector>

#if defined(_WIN32) && !defined(RES_EMBED_STATIC)
#ifdef res_embed_EXPORTS
#define RES_EMBED_API __declspec(dllexport)
#else
#define RES_EMBED_API __declspec(dllimport)
#endif
#else
#define RES_EMBED_API
#endif

#include <string>
#include <tuple>
#include <vector>

namespace res {

namespace embed {

// Add an entry to the index of embedded resources (internal).
void RES_EMBED_API add(const std::string& name, const char* content, size_t size, const std::string& mime);

// Get an entry from the index of embedded resources.
const char* RES_EMBED_API get(const std::string& name, size_t* size = nullptr, std::string* mime = nullptr);

// Get all entries from the index of embedded resources.
std::vector<std::tuple<std::string, const char*, size_t, std::string> > get_all();

} // namespace embed

} // namespace res

#endif // RES_EMBED_H

