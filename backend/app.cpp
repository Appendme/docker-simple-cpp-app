#include <iostream>
#include <restinio/all.hpp>

namespace rr = restinio::router;
using router_t = rr::express_router_t<>;

auto handler() {
	auto router = std::make_unique<router_t>();

	router->http_get("/", [](auto req, auto params) {
		constexpr std::string_view message =
			"<html><body>"
			"Hello world"
			"</body></html>";

		req->create_response().set_body(message).done();

		return restinio::request_accepted();
	});

	router->non_matched_request_handler([](auto req) {
		return req->create_response(restinio::status_not_found())
				.append_header_date_field()
				.connection_close()
				.done();
	});

	return router;
}

int main()
{
	using traits_t =
	  restinio::traits_t<
		 restinio::asio_timer_manager_t,
		 restinio::single_threaded_ostream_logger_t,
		 router_t>;

	try {
		restinio::run(
		restinio::on_this_thread<traits_t>()
			.port(20100)
			.address("0.0.0.0")
			.request_handler(handler()));
	} catch(const std::exception& e) {
		std::cerr << e.what() << std::endl;
	}
	
	return 0;
}