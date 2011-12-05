class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

		// Create RESTful mappings for the BaristaController
		"/barista" (controller: "barista") { 
			action = [POST: "save", GET: "list"]
			}
		"/barista/$id" (controller: "barista") {
			action = [GET: "show", PUT: "update", DELETE: "delete"]
		}
		"/barista/create" (controller: "barista", action: "create")
		
		"/coffeeDrink" (controller: "coffeeDrink", action:"list")
		
		"/"(view:"/index")
		"500"(view:'/error')
	}
}
