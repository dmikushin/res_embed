#include "res_embed.h"

#include <map>
#include <memory>
#include <tuple>

using namespace std;

namespace res {

namespace embed {

// Container for embedded content that shall be
// loaded and persist in memory during the application lifetime.
static unique_ptr<map<string, tuple<const char*, size_t, string> > > index;

} // namespace embed

} // namespace res

void res::embed::add(const string& name, const char* content, size_t size, const string& mime)
{
	if (!index.get())
		index.reset(new map<string, tuple<const char*, size_t, string> >());

	index->emplace(name, std::make_tuple(content, size, mime));
}

const char* res::embed::get(const string& name, size_t* size, string* mime)
{
	if (!index.get())
	{
		fprintf(stderr, "The resources index maintained by RES::EMBED is not [yet] initialized\n"
			"Perhaps, the resource load is attempted by a static object, which is initialized earlier than the RES::EMBED index\n"
			"Please make sure this is not the case\n");
		return nullptr;
	}

	auto it = index->find(name);
	if (it == index->end()) return nullptr;

	auto& result = it->second;
	if (size) *size = std::get<1>(result);
	if (mime) *mime = std::get<2>(result);

	return std::get<0>(result);
}

