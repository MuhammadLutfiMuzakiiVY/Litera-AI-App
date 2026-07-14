import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    extra.set("compileSdkVersion", 34)
    extra.set("targetSdkVersion", 34)
    extra.set("minSdkVersion", 21)
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureSubproject = {
        val androidExtension = extensions.findByType<BaseExtension>()
        if (androidExtension != null) {
            // Force compileSdkVersion to 36 for all library subprojects to resolve modern library dependencies mismatch
            if (project.name != "app") {
                androidExtension.compileSdkVersion(36)
            }
            
            // Set namespace if not defined
            if (androidExtension.namespace == null) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val matcher = java.util.regex.Pattern.compile("package=\"([^\"]+)\"").matcher(manifestContent)
                    if (matcher.find()) {
                        androidExtension.namespace = matcher.group(1)
                    } else {
                        androidExtension.namespace = project.group.toString()
                    }
                } else {
                    androidExtension.namespace = project.group.toString()
                }
            }
        }
    }

    if (state.executed) {
        configureSubproject()
    } else {
        afterEvaluate {
            configureSubproject()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
