// Place your Spring DSL code here
beans = {
	groovyPageResourceLoader(com.cadrlife.jhaml.grailsplugin.HamlGroovyPageResourceLoader) {
	  baseResource = "file:."
	  pluginSettings = new grails.util.PluginBuildSettings(grails.util.BuildSettingsHolder.settings)
	}
}
