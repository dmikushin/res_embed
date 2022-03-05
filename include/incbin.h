#ifndef XXD_H
#define XXD_H

#include <map>
#include <memory>
#include <string>
#include <vector>

#ifdef _WIN32
#ifdef incbin_EXPORTS
#define INCBIN_API __declspec(dllexport)
#else
#define INCBIN_API __declspec(dllimport)
#endif
#else
#define INCBIN_API
#endif

// Container for embedded content that shall be
// loaded and persist in memory during the server lifetime.
extern INCBIN_API std::unique_ptr<std::map<std::string, std::pair<const char*, size_t> > > incbin;

// Container for embedded content MIME.
extern INCBIN_API std::unique_ptr<std::map<std::string, std::string> > incbin_mime;

#endif // XXD_H

