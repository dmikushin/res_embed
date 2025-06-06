#ifndef RES_EMBED_H
#define RES_EMBED_H

#include <map>
#include <memory>
#include <string>
#include <vector>

#if defined(_WIN32) && !defined(res_embed_STATIC)
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
RES_EMBED_API void add(const std::string& name, const char* content, size_t size, const std::string& mime);

// Get an entry from the index of embedded resources.
RES_EMBED_API const char* get(const std::string& name, size_t* size = nullptr, std::string* mime = nullptr);

// Get all entries from the index of embedded resources.
RES_EMBED_API std::vector<std::tuple<std::string, const char*, size_t, std::string> > get_all();

// Get container for embedded content that shall be
// loaded and persist in memory during the application lifetime (internal).
std::map<std::string, std::tuple<const char*, size_t, std::string> >& index();

} // namespace embed

} // namespace res

#endif // RES_EMBED_H

