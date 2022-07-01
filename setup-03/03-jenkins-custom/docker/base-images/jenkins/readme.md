# Jenkins docker image information

## How to get the list of installed plugins from a active Jenkins instance

The code example below comes from (1).

````
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
plugins.each {println "${it.getShortName()}:${it.getVersion()}"}
````

(1) https://stackoverflow.com/a/44979051

## How to get depdency graph for plugins

````shell
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
println "digraph test {"
plugins.each {
    def plugin = it.getShortName()
    println "\"${plugin}\";"
    def deps =  it.getDependencies()
    deps.each {
      def s = it.shortName
      println "\"${plugin}\" -> \"${s}\";"
    }
} 
println "}"
````

(1) https://stackoverflow.com/a/37757232
