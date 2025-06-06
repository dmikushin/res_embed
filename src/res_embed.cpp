#include "res_embed.h"

#include <map>
#include <tuple>

using namespace std;

// Allow this function to be shadowed by another instance of the same
// function loaded from another shared library. This way embedded resources
// spanned across executable and libraries will use the same index.
map<string, tuple<const char*, size_t, string> >& res::embed::index()
{
    // Container for embedded content that shall be
    // loaded and persist in memory during the application lifetime.
    static map<string, tuple<const char*, size_t, string> > i;
    return i;
}

void res::embed::add(const string& name, const char* content, size_t size, const string& mime)
{
	auto it = index().find(name);
	if (it == index().end())
		index().emplace(name, std::make_tuple(content, size, mime));
}

const char* res::embed::get(const string& name, size_t* size, string* mime)
{
	auto it = index().find(name);

    // It could be that the resources index maintained by RES::EMBED is not [yet] initialized.
    // Perhaps, the resource load is attempted by a static object, which is initialized earlier
    // than the RES::EMBED index. Please make sure this is not the case. Otherwise, you can
    // initialize one particular resource manually by calling res::embed::init::<name>().
	if (it == index().end()) return nullptr;

	auto& result = it->second;
	if (size) *size = std::get<1>(result);
	if (mime) *mime = std::get<2>(result);

	return std::get<0>(result);
}

std::vector<std::tuple<std::string, const char*, size_t, std::string> > res::embed::get_all()
{
	std::vector<std::tuple<std::string, const char*, size_t, std::string> > list;

	for (auto& it : index())
		list.emplace_back(it.first, std::get<0>(it.second),
			std::get<1>(it.second), std::get<2>(it.second));

	return list;
}

