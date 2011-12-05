modules = {
    application {
        resource url:'js/application.js'
    }
	// Here's what's needed for Backbone.js
	backbone {
		dependsOn 'jquery'

		resource url:'/js/underscore.js', disposition:'head'
		resource url:'/js/backbone.js', disposition:'head'
	}
}
